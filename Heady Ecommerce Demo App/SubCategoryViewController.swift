//
//  SubCategoryViewController.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 07/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//

import UIKit
import CoreData

class SubCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var subCategoryTableView: UITableView!
    var subCategoryIds = [AnyObject]()
    var subCategoryArray = [AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sub-Category"
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SubCategory")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        request.predicate = NSPredicate(format: "id in %@", subCategoryIds)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                subCategoryArray = results as [AnyObject]
                subCategoryTableView.reloadData()
            }
        }catch {
            print("Couldn't fetch results")
        }
    }
    
    // MARK: - tableview function to show number of rows in the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategoryArray.count
    }
    
    // MARK: - tableview function to display the elements in the cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subCategoryTableView.dequeueReusableCell(withIdentifier: "SubCategoryTableViewCell", for: indexPath) as! SubCategoryTableViewCell
        cell.subCategoryName.text = subCategoryArray[indexPath.row].value(forKey: "name") as? String ?? ""
        return cell
    }
    
    // MARK: - tableview function to redirect or perform some function when user taps on particular cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
        vc.procuctsIds = subCategoryArray[indexPath.row].value(forKey: "childCategory") as? [AnyObject] ?? []
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - tableviewcell to access the elements of the cell.
class SubCategoryTableViewCell: UITableViewCell{
    @IBOutlet weak var subCategoryName: UILabel!
}
