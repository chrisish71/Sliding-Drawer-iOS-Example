//
//  MenuViewController.swift
//  Sliding-Drawer-iOS-Example
//
//  Created by Christophe ISHIMWE NGABO on 11/11/2021.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet private weak var menuTableView: UITableView!
    
    public var menuDelegate: MenuDelegate?
    
    private let menuIconItems: [String] = ["house.fill", "bookmark.fill", "envelope.fill"]
    private let menuLabelItems: [String] = ["Home", "Bookmarks", "Messages"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.tableFooterView = UIView()
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(menuIconItems.count, menuLabelItems.count)
    }
    
    // MARK: - Populate MenuTableView
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let menuViewCell = menuTableView.dequeueReusableCell(withIdentifier: "Menu-Cell", for: indexPath) as? MenuViewCell {
            menuViewCell.icon.image = UIImage(systemName: menuIconItems[indexPath.row])
            menuViewCell.label.text = menuLabelItems[indexPath.row]
            menuViewCell.selectedBackgroundView?.backgroundColor = .gray
            return menuViewCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        menuDelegate?.menuItemDidClicked(index: indexPath.row, value: menuLabelItems[indexPath.row])
    }
}
