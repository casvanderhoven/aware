//
//  ScannerViewController.swift
//  Aware
//
//  Created by Cas van der Hoven on 15/01/2017.
//  Copyright © 2017 Cas van der Hoven. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var barCodeFrameView:UIView?
    var companyItems: [CompanyItem] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var blurEffectView: UIVisualEffectView!
    @IBOutlet var gridImage: UIImageView!
    @IBOutlet var gridSwitchButton: UIButton!
    
    @IBAction func gridSwitchFunc(sender: UIButton) {
        if gridImage.isHidden == true {
            gridImage.isHidden = false
            gridSwitchButton.setTitle("       GRID ON", for: .normal)
            print("Button pressed")
            return
        } else {
            gridImage.isHidden = true
            gridSwitchButton.setTitle("       GRID OFF", for: .normal)
            print("Button 2 pressed")
            return
        }
    }
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            startCapture()
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var decodedBarcode: String
        var result: CompanyItem
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "Looking for a barcode..."
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                decodedBarcode = metadataObj.stringValue
                messageLabel.text = "Barcode detected! Searching..."
                self.captureSession?.stopRunning()
                barCodeFrameView?.frame = CGRect.zero
                let url = outpanURL(searchText: decodedBarcode)
                
                if let jsonString = performOutpanRequest(with: url) {
                    if let jsonDictionary = parse(json: jsonString) {
                        result = parse(dictionary: jsonDictionary)
                        
                        alert(searchResult: result)
                        
                        return
                    }
                }
                
                showNetworkError()
            }
            
            
        }
    }
    
    func outpanURL(searchText: String) -> URL {
        let urlString = String(format:
        "https://api.outpan.com/v2/products/%@?apikey=5136476b989206d8c03ca8d526a84038", searchText)
        
        let url = URL(string: urlString)
        return url!
    }
    
    func performOutpanRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download error: \(error)")
            return nil
        }
    }
    
    func parse(json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8, allowLossyConversion: false)
            else { return nil }
        do {
            return try JSONSerialization.jsonObject(
                with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parse(dictionary: [String: Any]) -> CompanyItem {
        // Loop through the array elements in turn
        var companyInfo: [String: String] = [:]
        
        // Initialise SearchResult object
        var searchResult: CompanyItem!

        if let keyLookUp = dictionary["attributes"] as? [String: String]  {
    
            // Get attributes dictionary
            companyInfo = keyLookUp
            
            // Use parse function to obtain SearchResult object with information
            searchResult = parse(brand: companyInfo)
            } else {
            searchResult = noInfo()
        }
        return searchResult
    }

    
    func parse(brand dictionary: [String: Any]) -> CompanyItem {
        let searchResult = CompanyItem()
        
        searchResult.brand = dictionary["Brand"] as! String
        
        return searchResult
    }
    
    func noInfo() -> CompanyItem {
        let searchResult = CompanyItem()
        
        searchResult.status = "This product is not yet in our database."
        
        return  searchResult
    }
    
    func alert(searchResult: CompanyItem) {
        
        let action = UIAlertAction(title: "OK", style: .default, handler:
            {
                (alertAction:UIAlertAction!) in
                
                self.startCapture()
                
            })
        
        if searchResult.brand == "" {
            let alert = UIAlertController(title: "No company found",
                                          message: "We were unable to found a match for this barcode.",
                                          preferredStyle: .alert)
            

            
            alert.addAction(action)
            self.messageLabel.text = ""
            
            present(alert, animated:true, completion: nil)
        } else {
            let alert = UIAlertController(title: "This product is from '\(searchResult.brand)'.",
                message: "Click OK to continue",
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(action)
            self.messageLabel.text = ""
            
            present(alert, animated:true, completion:nil)
        }
    }
    
    // Error functions
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message:
            "There was an error reading retrieving the barcode information. Please try again.",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Function to start new captureSession
    
    func startCapture() {
        // Start video capture.
        captureSession?.startRunning()
        
        // Set status bar
        
        
        // Blur the background of message label
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = messageLabel.frame
        view.addSubview(blurEffectView)
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: gridSwitchButton)
        view.bringSubview(toFront: gridImage)
        gridImage.isHidden = false
        
        // Reset barcode frame borders and message label text
        barCodeFrameView?.bounds = CGRect.zero
        messageLabel.text = "Looking for a barcode..."
        
        // Initialize Barcode Frame to highlight the QR code
        barCodeFrameView = UIView()
        
        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.layer.borderColor = UIColor.green.cgColor
            barCodeFrameView.layer.borderWidth = 2
            view.addSubview(barCodeFrameView)
            view.bringSubview(toFront: barCodeFrameView)
        }

    }
}
