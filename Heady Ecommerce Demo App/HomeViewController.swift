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
        fetchData {
            print("Api Called")
        }
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Api Call to get data
    func fetchData(completed: @escaping () -> ()){
        self.clearData(entityName:"Category")
        self.clearData(entityName:"SubCategory")
        self.clearData(entityName:"Product")
        let url = URL(string:"https://stark-spire-93433.herokuapp.com/json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { print(error!); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as AnyObject
                //                                print(json)
                DispatchQueue.main.async {
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
                                        
                                        let context = self.appDelegate.persistentContainer.viewContext
                                        let productEntity = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context)
                                        productEntity.setValue(categories[i]["id"] as? Int32 ?? 0, forKey: "id")
                                        productEntity.setValue(products[j]["id"] as? Int32 ?? 0, forKey: "productId")
                                        productEntity.setValue(products[j]["name"] as? String ?? "", forKey: "productName")
                                        productEntity.setValue(categories[i]["name"] as? String ?? "", forKey: "name")
                                        productEntity.setValue(products[j]["date_added"] as? String ?? "", forKey: "date")
                                        do {
                                            try context.save()
                                            
                                        } catch let error {
                                            print(error)
                                        }
                                        
                                        
                                        
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
                                    print("Save Product")
                                    
                                    self.addProduct = true
                                    self.addCategorySubCategory = true
                                    break;
                                }
                                
                                
                            }
                            if(self.addCategorySubCategory == true){
                                if(self.addProduct == false){
                                    print("Save subCategory")
                                    let context = self.appDelegate.persistentContainer.viewContext
                                    let subCategory = NSEntityDescription.insertNewObject(forEntityName: "SubCategory", into: context)
                                    subCategory.setValue(categories[i]["id"] as? Int32 ?? 0, forKey: "id")
                                    subCategory.setValue(categories[i]["name"] as? String ?? "", forKey: "name")
                                    subCategory.setValue(categories[i]["child_categories"] as? [AnyObject] ?? [], forKey: "childCategory")
                                    
                                }
                            }else{
                                self.addProduct = false
                                let context = self.appDelegate.persistentContainer.viewContext
                                let categoryEntity = NSEntityDescription.insertNewObject(forEntityName: "Category", into: context)
                                categoryEntity.setValue(categories[i]["id"] as? Int32 ?? 0, forKey: "id")
                                categoryEntity.setValue(categories[i]["name"] as? String ?? "", forKey: "name")
                                categoryEntity.setValue(categories[i]["child_categories"] as? [AnyObject] ?? [], forKey: "childCategory")
                                
                                do {
                                    try context.save()
                                } catch let error {
                                    print(error)
                                    
                                    print("Save Category")
                                }
                                
                            }
                        }
                        
                    }
                    if let ranking : [AnyObject] = ((json as AnyObject).value(forKey: "rankings") as AnyObject).mutableCopy() as? [AnyObject] {
                        for i in 0...ranking.count - 1 {
                            if let products = ranking[i]["products"] as? [AnyObject]{
                                if(products.count > 0){
                                    for j in 0...products.count - 1{
                                        let context = self.appDelegate.persistentContainer.viewContext
                                        let rankingEntity = NSEntityDescription.insertNewObject(forEntityName: "Ranking", into: context)
                                        var rankingName = ranking[i]["ranking"] as? String ?? ""
                                        rankingEntity.setValue(ranking[i]["ranking"] as? String ?? "", forKey: "productRanking")
                                        rankingEntity.setValue(products[j]["id"] as? Int32 ?? 0, forKey: "id")
                                        if rankingName == "Most Viewed Products" {
                                            rankingEntity.setValue(products[j]["view_count"] as? Int32 ?? 0, forKey: "count")
                                        }else if rankingName == "Most OrdeRed Products" {
                                            rankingEntity.setValue(products[j]["order_count"] as? Int32 ?? 0, forKey: "count")
                                        }else {
                                            rankingEntity.setValue(products[j]["shares"] as? Int32 ?? 0, forKey: "count")
                                        }
                                        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
                                        //                                           
                                        request.predicate = NSPredicate(format: "productId = %d", products[j]["id"] as? Int ?? 0)
                                        request.returnsObjectsAsFaults = false
                                        
                                        do {
                                            
                                            let results = try context.fetch(request)
                                            
                                            if results.count > 0 {
                                                //                                                        procuctsArray = results as [AnyObject]
                                                //                                                        productsTableView.reloadData()
                                                print((results[0] as AnyObject).value(forKey: "productName")!)
                                                rankingEntity.setValue((results[0] as AnyObject).value(forKey: "productName")! as? String ?? "", forKey: "productName")
                                                do {
                                                    try context.save()
                                                } catch let error {
                                                    print(error)
                                                    
                                                    print("Save Category")
                                                }
                                            }
                                            
                                            
                                        }catch {
                                            
                                            print("Couldn't fetch results")
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                            
                        }
                    }
                    
                    self.fetchCategoryData()
                }
            } catch {
                print(error)
            }
            
        }
        task.resume()
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath) as! CategoeyTableViewCell
        cell.categoryName.text = categoryArray[indexPath.row].value(forKey: "name") as? String ?? ""
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SubCategoryViewController") as! SubCategoryViewController
        vc.subCategoryIds = categoryArray[indexPath.row].value(forKey: "childCategory") as? [AnyObject] ?? []
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - fetch Category data from core data
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
                print("Category",result)
                DispatchQueue.main.async {
                    self.categoriesTableView.reloadData()
                }
            }
        } catch {
            
            print("Failed")
        }
    }
    
    
    @IBAction func mostViewedProducts(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
        vc.ranking = "Most Viewed Products"
        vc.title = "Most Viewed Products"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func mostOrderedProducts(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
        vc.ranking = "Most OrdeRed Products"
        vc.title = "Most Ordered Products"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mostSharedProducts(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
        vc.ranking = "Most ShaRed Products"
        vc.title = "Most Shared Products"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    func clearData(entityName:String) {
        let context = self.appDelegate.persistentContainer.viewContext
        //        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                try context.save()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
}

class CategoeyTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryName: UILabel!
    
}
