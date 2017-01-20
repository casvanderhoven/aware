//
//  CompanyDetailViewController.swift
//  Bodhi
//
//  Created by Cas van der Hoven on 18/01/2017.
//  Copyright © 2017 Cas van der Hoven. All rights reserved.
//

import Foundation
import UIKit

protocol AddCompanyViewControllerDelegate: class {
    func addCompanyViewControllerDidCancel(_ controller: CompanyDetailViewController)
    func companyDetailViewController(_ controller: CompanyDetailViewController,
                                  didFinishAdding item: CompanyItem)
    func companyDetailViewController(_ controller: CompanyDetailViewController, didFinishEditing item: CompanyItem)
}

class CompanyDetailViewController: UITableViewController, UITextFieldDelegate {
    
    weak var delegate: AddCompanyViewControllerDelegate?
    
    var itemToEdit: CompanyItem?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    @IBAction func cancel() {
        delegate?.addCompanyViewControllerDidCancel(self)
    }
    @IBAction func done() {
        if let item = itemToEdit {
            item.brand = textField.text!
            delegate?.companyDetailViewController(self, didFinishEditing: item)
        } else {
        
        let item = CompanyItem()
        item.brand = textField.text!
        
        delegate?.companyDetailViewController(self, didFinishAdding: item)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = itemToEdit {
            title = "Edit Company"
            textField.text = item.brand
            doneBarButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        return true
    }

}
