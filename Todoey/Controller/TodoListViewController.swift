//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    //MARK: - USER DEFAULTS and NSCoder
    
    /*
//    let defaults = UserDefaults.standard
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    var itemArray = [Item]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
//        User Defaults is used with predefined DataTypes. User-defined data type wont work
//        if let items = defaults.array(forKey: "TodoArrayKey") as? [Item] {
//            itemArray = items
//        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todo Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let titleText = textField.text {
                let newAddedItem = Item()
                newAddedItem.title = titleText
                
                self.itemArray.append(newAddedItem)
                self.saveItems()
                
//                App will crash because user defaults is used with user-defined data type
//                self.defaults.set(self.itemArray, forKey: "TodoArrayKey")
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let encodedData = try encoder.encode(itemArray)
            try encodedData.write(to: dataFilePath!)
        } catch {
            print("Error encoding Item Array, \(error)")
        }
        tableView.reloadData()
    }
    
    private func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding Item Array, \(error)")
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let currentItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = currentItem.title
        cell.accessoryType = currentItem.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
//        Bug - When the cells are reused, checkmarks appears for some new cells as well
//        Hence a model is needed with a boolean attribute to set or unset these checkmarks
//        if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
    }
    */
    
    
    //MARK: - CORE DATA
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [ToDoItem]();
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    private func loadItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        //Only load the data from Selected Category
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fectching Data \(error)")
        }
        
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Todo Item".uppercased(), message: "Add new Todo Item", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add".uppercased(), style: .default) { action in
            if let titleText = textField.text {
                
                let newAddedItem = ToDoItem(context: self.context)
                newAddedItem.title = titleText
                newAddedItem.done = false
                newAddedItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newAddedItem)
                self.saveItems()
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let currentItem = itemArray[indexPath.row]
        cell.textLabel?.text = currentItem.title
        cell.accessoryType = currentItem.done ? .checkmark : .none
        cell.textLabel?.textColor = UIColor.white

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
    }
}

extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text ?? "")
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        loadItems(with: request, predicate: predicate)
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

