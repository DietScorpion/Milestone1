//
//  MasterViewController.swift
//  Milestone1
//
//  Created by Alistair Brice on 9/4/19.
//  Copyright © 2019 Alistair Brice. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects: [ObjectDefinition] = []
    var newItem = false


    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelPressed), name: NSNotification.Name(rawValue: "cancel"), object: nil)
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNew(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        getFromStorage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc func cancelPressed(){
        if newItem == true{
            objects.removeLast()
            newItem = false
        }
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
    
    @objc func loadList(){
        tableView.reloadData()
        storage()
        print("stored")
    }
    
    @objc
    func insertNew(_ sender: Any) {
        newItem = true
        let objNum = objects.count
        objects.append(ObjectDefinition(name: "Blank", address: "", latitude: 0.0, longitude: 0.0))
        let indexPath = IndexPath(row: objNum, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        performSegue(withIdentifier: "showDetail", sender: indexPath)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let indexPath: IndexPath
            if let i = sender as? IndexPath {
                indexPath = i
            } else if let cell = sender as? UITableViewCell,
                let i = tableView.indexPath(for: cell) {
                indexPath = i
            } else { return }
            
            let object = objects[indexPath.row]
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = object
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }

    func insertNewObject(){
        tableView.reloadData()
        
    }
    
    func storage() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let encoder = JSONEncoder()
        do{
            let JSON = try encoder.encode(objects)
            let fileURL = docs.appendingPathComponent("JSON")
            try JSON.write(to: fileURL, options: .atomic)
        } catch{
            print("Error: \(error)")
        }
    }
    
    func getFromStorage(){
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let decoder = JSONDecoder()
        do{
            let fileURL = docs.appendingPathComponent("JSON")
            let data = try Data(contentsOf: fileURL)
            let places = try decoder.decode([ObjectDefinition].self, from : data)
            print("Got \(places.count)")
            objects = []
            for place in places{
                objects.append(place)
            }
        } catch{
            print("Error: \(error)")
        }
    }

//    func emptyString(){
//        if objects.last?.name == "" || objects.last?.address == ""{
//            objects.removeLast()
//        }
//    }
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let object = objects.remove(at: sourceIndexPath.row)
        objects.insert(object, at: destinationIndexPath.row)
    }

}


