//
//  TableViewController.swift
//  Bodhi
//
//  Created by Cas van der Hoven on 18/01/2017.
//  Copyright © 2017 Cas van der Hoven. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, AddCompanyViewControllerDelegate {

    var items: [CompanyItem]
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBAction func cancel() {
        dismiss(animated:true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        items = [CompanyItem]()
        
        super.init(coder: aDecoder)
        print("Documents folder: \(documentsDirectory())")
        loadBoycottListItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "companyItem", for: indexPath)

        let item = items[indexPath.row]
        
        // Configure the cell...
        
        configureText(for: cell, with: item)

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)

        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        
        saveBoycottListItem()
    }
    
    func configureText(for cell: UITableViewCell, with item: CompanyItem) {
    let label = cell.viewWithTag(1000) as! UILabel
    
    label.text = item.brand
    
    }
    
    func addCompanyViewControllerDidCancel(_ controller: CompanyDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func companyDetailViewController(_ controller: CompanyDetailViewController, didFinishAdding item: CompanyItem) {
        let newRowIndex = items.count
        items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        dismiss(animated: true, completion: nil)
        
        saveBoycottListItem()
    }
    
    func companyDetailViewController(_ controller: CompanyDetailViewController, didFinishEditing item: CompanyItem) {
        if let index = items.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        dismiss(animated: true, completion: nil)
        
        saveBoycottListItem()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCompany" {
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! CompanyDetailViewController
            
            controller.delegate = self
        } else if segue.identifier == "EditCompany" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! CompanyDetailViewController
            
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(                for: sender as! UITableViewCell) {
                controller.itemToEdit = items[indexPath.row]
            }
        }
    }
    
    // Functions for saving boycott list
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("BoycottList.plist")
    }
    
    func saveBoycottListItem() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(items, forKey: "BoycottList")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    
    func loadBoycottListItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            items = unarchiver.decodeObject(forKey: "BoycottList") as! [CompanyItem]
            
            unarchiver.finishDecoding()
        }
    }
    
    
}
