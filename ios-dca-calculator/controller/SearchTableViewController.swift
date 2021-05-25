//
//  ViewController.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 15.05.2021.
//

import UIKit
import Combine

class SearchTableViewController: UITableViewController, UIAnimatable {
    
    private enum Mode {
        case onboarding
        case search
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?
    @Published private var mode: Mode = .onboarding
    @Published private var searchQuery: String? = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupTableView()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
    }
    
    private func observeForm() {
        $searchQuery.debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] query in
                
                // check emptiness and whitespaces of the query
                let q = query?.trimmingCharacters(in: .whitespacesAndNewlines)
                if(q != nil) {
                    if (q == "") {
                        if (searchResults != nil) {
                            searchResults = nil
                            self.tableView.reloadData()
                        }
                    } else {
                        showLoadingAnimation()
                        self.performSearch(for: q!)
                    }
                    
                }
            }
            .store(in: &subscribers)
        
        $mode.sink { mode in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
                
            case .search:
                self.tableView.backgroundView = nil
            }
        }
        .store(in: &subscribers)
    }
    
    private func performSearch(for keyword: String) {
        apiService.fetchSymbolsPublisher(keywords: keyword).sink { completion in
            
            self.hideLoadingAnimation()
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            }
            
        } receiveValue: { searchResults in
            
            self.searchResults = searchResults
            self.tableView.reloadData()
            
        }.store(in: &subscribers)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchTableViewCell
        
        if let searchResults = self.searchResults {
            let resultItem = searchResults.items[indexPath.row]
            cell.configure(with: resultItem)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showCalculator", sender: nil)
    }

}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        // print(searchController.searchBar.text)
        self.searchQuery = searchController.searchBar.text
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        mode = .onboarding
    }
    
}
