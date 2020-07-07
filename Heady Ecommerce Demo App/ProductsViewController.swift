//
//  ProductsViewController.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 07/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//

import UIKit
import CoreData

class ProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ranking: String?
    var procuctsIds = [AnyObject]()
    var procuctsArray = [AnyObject]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var productsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if ranking != "" && ranking != nil{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ranking")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            request.predicate = NSPredicate(format: "productRanking = %@", ranking!)
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    procuctsArray = results as [AnyObject]
                    productsTableView.reloadData()
                }
            }catch {
                print("Couldn't fetch results")
            }
        }else{
            self.title = "Products"
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            request.predicate = NSPredicate(format: "id in %@", procuctsIds)
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    procuctsArray = results as [AnyObject]
                    productsTableView.reloadData()
                }
            }catch {
                print("Couldn't fetch results")
            }
        }
        
    }
    
    // MARK: - tableview function to show number of rows in the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return procuctsArray.count
    }
    
    // MARK: - tableview function to display the elements in the cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTableView.dequeueReusableCell(withIdentifier: "ProductsTableViewCell", for: indexPath) as! ProductsTableViewCell
        if ranking != "" && ranking != nil{
            cell.categoryName.text =  "Count: " + String(procuctsArray[indexPath.row].value(forKey: "count") as? Int ?? 0)
            cell.productName.text = procuctsArray[indexPath.row].value(forKey: "productName") as? String ?? ""
        }else{
            cell.categoryName.text = procuctsArray[indexPath.row].value(forKey: "name") as? String ?? ""
            cell.productName.text = procuctsArray[indexPath.row].value(forKey: "productName") as? String ?? ""
        }
        
        return cell
    }
}

// MARK: - tableviewcell to access the elements of the cell.
class ProductsTableViewCell: UITableViewCell{
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var productName: UILabel!
}
