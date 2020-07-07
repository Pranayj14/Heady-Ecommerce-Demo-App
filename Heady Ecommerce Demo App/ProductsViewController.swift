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
                    print("results",results)
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
                    print("results",results)
                }
                
                
            }catch {
                
                print("Couldn't fetch results")
                
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return procuctsArray.count
    }
    
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
    
    // MARK: - fetch Product data from core data
    func fetchProductData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        request.returnsObjectsAsFaults = false
        do {
            let context = self.appDelegate.persistentContainer.viewContext
            let result = try context.fetch(request)
            if(result.isEmpty){
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "Check your internet connection or contact the Administrator.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                        
                    }))
                    self.present(alert, animated: false, completion: nil)
                }
            }else{
                print("Product",result)
            }
        } catch {
            
            print("Failed")
        }
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

class ProductsTableViewCell: UITableViewCell{
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var productName: UILabel!
}
