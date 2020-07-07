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
    
    
    //    var manageObjects: NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var categoriesTableView: UITableView!
    
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
                if let categories : [AnyObject] = ((json as AnyObject).value(forKey: "categories") as AnyObject).mutableCopy() as? [AnyObject] {
                    for i in 0...categories.count - 1{
                        if let childCategories = categories[i]["child_categories"] as? [AnyObject]{
                            if childCategories.count > 0{
                                for i in 0...childCategories.count - 1{
                                    self.childCategoryIdArray.append(childCategories[i])
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
                                if let products = categories[i]["products"] as? [AnyObject]{
                                    
                                    let context = self.appDelegate.persistentContainer.viewContext
                                    let productEntity = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context)
                                    for j in 0...products.count - 1{
                                        productEntity.setValue(categories[i]["id"] as? Int32 ?? 0, forKey: "id")
                                        productEntity.setValue(products[j]["id"] as? Int32 ?? 0, forKey: "productId")
                                        productEntity.setValue(products[j]["name"] as? String ?? "", forKey: "productName")
                                        productEntity.setValue(categories[i]["name"] as? String ?? "", forKey: "name")
                                        productEntity.setValue(products[j]["date_added"] as? String ?? "", forKey: "date")
                                        do {
                                            let context = self.appDelegate.persistentContainer.viewContext
                                            try context.save()
                                           
                                        } catch let error {
                                            print(error)
                                        }
                                        self.fetchProductData()
                                    }
                                    self.addProduct = true
                                    self.addCategorySubCategory = true
                                    break;
                                }
                                
                                
                            }
//                            self.fetchSubCategoryData()
                             
                           
                        }
                        if(self.addCategorySubCategory == true){
                            if(self.addProduct == false){
                                print("Save subCategory")
                                let context = self.appDelegate.persistentContainer.viewContext
                                
                                // Create User
                                let subcategoryEntity = NSEntityDescription.entity(forEntityName: "SubCategory", in: context)
                                let newSubcategory = SubCategory(entity: subcategoryEntity!, insertInto: context)
                                newSubcategory.setValue(categories[i]["id"] as? Int32 ?? 0, forKey: "id")
                                newSubcategory.setValue(categories[i]["name"] as? String ?? "", forKey: "name")
                                newSubcategory.setValue(categories[i]["child_categories"] as? [AnyObject] ?? [], forKey: "childCategory")
                                
                            }
                        }else{
                            self.addProduct = false
                            let context = self.appDelegate.persistentContainer.viewContext
                            let categoryEntity = NSEntityDescription.insertNewObject(forEntityName: "Category", into: context)
                            categoryEntity.setValue(categories[i]["id"] as? Int32 ?? 0, forKey: "id")
                            categoryEntity.setValue(categories[i]["name"] as? String ?? "", forKey: "name")
                         categoryEntity.setValue(categories[i]["child_categories"] as? [AnyObject] ?? [], forKey: "childCategory")
                            
                            do {
                                let context = self.appDelegate.persistentContainer.viewContext
                                try context.save()
                            } catch let error {
                                print(error)
                                
                                print("Save Category")
                            }
                            
                        }
                    }
                }else{
                    
                }
                
            } catch {
                print(error)
            }
            self.fetchCategoryData()
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
                //            print("Product",result)
            }
        } catch {
            
            print("Failed")
        }
    }
    
    
    
    
    
    // MARK: - fetch SubCategory data from core data
    func fetchSubCategoryData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SubCategory")
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
                print("SubCategory",result)
            }
        } catch {
            
            print("Failed")
        }
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
    
    
    
    
    // MARK: - Save Data in core data object by object.
    //    func saveDataInCoreDataWith(array: [AnyObject], entityName: String) {
    //        for _ in array {
    //            //            _ = self.createPhotoEntityFrom(dictionary: dict, entityName:entityName)
    //            let context = self.appDelegate.persistentContainer.viewContext
    //            let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    //            if(entityName == "Product"){
    //                entity?.setValue(array["id"] as? Int32 ?? 0, forKey: "id")
    //                entity?.setValue(array["name"] as? String ?? "", forKey: "name")
    //                entity?.setValue(array["date_added"] as? String ?? "", forKey: "date")
    //            }
    //            do {
    //                let context = self.appDelegate.persistentContainer.viewContext
    //                try context.save()
    //            } catch let error {
    //                print(error)
    //            }
    //        }
    //
    //    }
    
    // MARK: - Save data in particular key of an entity of every object.
    //    func createPhotoEntityFrom(dictionary: [String: AnyObject], entityName: String) -> NSManagedObject? {
    //           let context = self.appDelegate.persistentContainer.viewContext
    //          let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    //        if(entityName == "Users"){
    //           let userEntity = NSManagedObject(entity: entity!, insertInto: context)
    //           userEntity.setValue(dictionary["about"] as? String ?? "", forKey: "userDescription")
    //           userEntity.setValue(dictionary["name"] as? String ?? "", forKey: "userName")
    //           userEntity.setValue(dictionary["lastname"] as? String ?? "", forKey: "userLastName")
    //           userEntity.setValue(dictionary["designation"] as? String ?? "", forKey: "userDesignation")
    //           userEntity.setValue(dictionary["city"] as? String ?? "", forKey: "userCity")
    //           userEntity.setValue(dictionary["avatar"] as? String ?? "", forKey: "userProfilePicture")
    //           return userEntity
    //        }else{
    //                let articleEntity = NSManagedObject(entity: entity!, insertInto: context)
    //                articleMediaArray = dictionary["media"] as? [AnyObject] ?? []
    //                articleUserArray = dictionary["user"] as? [AnyObject] ?? []
    //                articleEntity.setValue(dictionary["comments"] as? Int32 ?? 0, forKey: "comments")
    //                articleEntity.setValue(dictionary["content"] as? String ?? "", forKey: "content")
    //                articleEntity.setValue(dictionary["createdAt"] as? String ?? "", forKey: "createdAt")
    //                articleEntity.setValue(dictionary["likes"] as? Int32 ?? 0, forKey: "likes")
    //                if(articleMediaArray.count > 0){
    //                    articleEntity.setValue(articleMediaArray[0]["image"] as? String ?? "", forKey: "mediaImage")
    //                }else{
    //                    articleEntity.setValue("", forKey: "mediaImage")
    //                }
    //                articleEntity.setValue(articleUserArray[0]["city"] as? String ?? "", forKey: "userCity")
    //                articleEntity.setValue(articleUserArray[0]["lastname"] as? String ?? "", forKey: "userLastName")
    //                articleEntity.setValue(articleUserArray[0]["designation"] as? String ?? "", forKey: "userDesignation")
    //                articleEntity.setValue(articleUserArray[0]["name"] as? String ?? "", forKey: "userName")
    //                articleEntity.setValue(articleUserArray[0]["avatar"] as? String ?? "", forKey: "userProfilePicture")
    //                articleEntity.setValue(articleUserArray[0]["about"] as? String ?? "", forKey: "userProfileDescription")
    //                do {
    //                    try context.save()
    //                } catch let error {
    //                    print(error)
    //                }
    //                return articleEntity
    //            }
    //        }
    
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
