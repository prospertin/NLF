//
//  PopupViewController.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 3/16/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import UIKit

public class PopoverViewController: UITableViewController {
    
    public var elementList:[String] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        // #warning Incomplete implementation, return the number of rows
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil )
        });
        // Selection of the cell and dismissing interfere with each other when running on the same thread?
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popoverCell", for: indexPath)
        
        let content = elementList[indexPath.row]
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = content
        }
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementList.count
    }
}
