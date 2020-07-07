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
                print("results",results)
            }
            
            
        }catch {
            
            print("Couldn't fetch results")
            
        }
            // Do any additional setup after loading the view.
        }
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subCategoryTableView.dequeueReusableCell(withIdentifier: "SubCategoryTableViewCell", for: indexPath) as! SubCategoryTableViewCell
        cell.subCategoryName.text = subCategoryArray[indexPath.row].value(forKey: "name") as? String ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
    
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
}

class SubCategoryTableViewCell: UITableViewCell{
    
    @IBOutlet weak var subCategoryName: UILabel!
}
