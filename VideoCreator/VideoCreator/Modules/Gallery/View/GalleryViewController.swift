//
//  GalleryViewController.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import UIKit

class GalleryViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find photos"
        configureSearchController()
    }

    private func configureSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
}

// MARK: - UISearchControllerDelegate

extension GalleryViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        self.searchText = ""
//        isFiltered = false
//        self.tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension GalleryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard !searchText.isEmpty else {
//            self.searchText = ""
//            isFiltered = false
//            self.tableView.reloadData()
//            return
//        }
//        self.searchText = searchText
//        isFiltered = true
//        self.tableView.reloadData()
    }
}
