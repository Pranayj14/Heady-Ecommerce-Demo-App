//
//  HomeViewController.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 03/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoriesTableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var categoryArray = [AnyObject]()
    var childCategoryIdArray = [AnyObject]()
    var addCategorySubCategory = false
    var addProduct = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Heady Ecommerce App"
        // MARK: - Api Call to get data.
        Services.init().getApiResponseGetMethod(apiUrl: "https://stark-spire-93433.herokuapp.com/json") { json, resoponse, error in
            
            guard let json = json,error == nil else {    DispatchQueue.main.async {
                self.fetchCategoryData()
                }; return }
            
            DispatchQueue.main.async {
                CoreDataModel.init().clearData(entityName:"Category")
                CoreDataModel.init().clearData(entityName:"SubCategory")
                CoreDataModel.init().clearData(entityName:"Product")
                CoreDataModel.init().clearData(entityName: "Ranking")
                if let categories : [AnyObject] = ((json as AnyObject).value(forKey: "categories") as AnyObject).mutableCopy() as? [AnyObject] {
                    for i in 0...categories.count - 1{
                        if let childCategories = categories[i]["child_categories"] as? [AnyObject]{
                            if childCategories.count > 0{
                                for i in 0...childCategories.count - 1{
                                    self.childCategoryIdArray.append(childCategories[i])
                                }
                            }
                        }
                        
                        if let products = categories[i]["products"] as? [AnyObject]{
                            
                            
                            if(products.count > 0){
                                for j in 0...products.count - 1{
                                    CoreDataModel.init().addDataForEntityAttributes(dict: categories[i] as! NSDictionary, dict2: products[j] as! NSDictionary, entityName: "Product")
                                }
                            }
                            
                        }
                    }
                    
                    for i in 0...categories.count - 1{
                        for j in 0...self.childCategoryIdArray.count - 1{
                            self.addProduct = false
                            let childCategoryArray = categories[i]["child_categories"] as? [AnyObject]
                            if categories[i]["id"] as? Int ?? 0 == self.childCategoryIdArray[j] as? Int ?? 0 && childCategoryArray?.count ?? 0 > 0{
                                self.addCategorySubCategory = true
                                break;
                            }else if categories[i]["id"] as? Int ?? 0 != self.childCategoryIdArray[j] as? Int ?? 0 && childCategoryArray?.count ?? 0 > 0{
                                self.addCategorySubCategory = false
                            }else{
                                self.addProduct = true
                                self.addCategorySubCategory = true
                                break;
                            }
                            
                            
                        }
                        if(self.addCategorySubCategory == true){
                            if(self.addProduct == false){
                                CoreDataModel.init().addDataForEntityAttributes(dict: categories[i] as! NSDictionary, dict2: [:], entityName: "SubCategory")
                            }
                        }else{
                            self.addProduct = false
                            CoreDataModel.init().addDataForEntityAttributes(dict: categories[i] as! NSDictionary, dict2: [:], entityName: "Category")
                        }
                    }
                }
                if let ranking : [AnyObject] = ((json as AnyObject).value(forKey: "rankings") as AnyObject).mutableCopy() as? [AnyObject] {
                    for i in 0...ranking.count - 1 {
                        if let products = ranking[i]["products"] as? [AnyObject]{
                            if(products.count > 0){
                                for j in 0...products.count - 1{
                                    CoreDataModel.init().addDataForEntityAttributes(dict: ranking[i] as! NSDictionary, dict2: products[j] as! NSDictionary, entityName: "Ranking")
                                }
                            }
                        }
                    }
                }
                self.fetchCategoryData()
            }
        }
    }
    
    // MARK: - tableview function to show number of rows in the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // MARK: - tableview function to display the elements in the cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath) as! CategoeyTableViewCell
        cell.categoryName.text = categoryArray[indexPath.row].value(forKey: "name") as? String ?? ""
        return cell
    }
    
    // MARK: - tableview function to redirect or perform some function when user taps on particular cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SubCategoryViewController") as! SubCategoryViewController
        vc.subCategoryIds = categoryArray[indexPath.row].value(forKey: "childCategory") as? [AnyObject] ?? []
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - fetch Category data from core data.
    func fetchCategoryData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
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
                categoryArray = result as [AnyObject]
                DispatchQueue.main.async {
                    self.categoriesTableView.reloadData()
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    // MARK: - This action will redirect to product page and will display Most Viewed Products list.
    @IBAction func mostViewedProducts(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
        vc.ranking = "Most Viewed Products"
        vc.title = "Most Viewed Products"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - This action will redirect to product page and will display Most OrdeRed Products.
    @IBAction func mostOrderedProducts(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
        vc.ranking = "Most OrdeRed Products"
        vc.title = "Most Ordered Products"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - This action will redirect to product page and will display Most ShaRed Products.
    @IBAction func mostSharedProducts(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
        vc.ranking = "Most ShaRed Products"
        vc.title = "Most Shared Products"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - tableviewcell to access the elements of the cell.
class CategoeyTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryName: UILabel!
    
}
