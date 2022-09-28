
import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    var memberList: [Member]?
    var searchedList: [Member]?
    
    var anyCancellables = Set<AnyCancellable>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        searchBar.delegate = self
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "nameCell")
        
        CombineNetworkService().getPublisherForResponse(endpoint: "https://gorest.co.in/public/v1/users").sink { _ in
            // no-op
        } receiveValue: { (response: MemberResponse) in
            print(response)
            self.memberList = response.data
            self.reloadTableData()
        }.store(in: &anyCancellables)
        
    }
    
    
    func reloadTableData() {
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchedList?.count  ?? 0 : memberList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = isSearching ? searchedList?[indexPath.row].name : memberList?[indexPath.row].name
        return cell
    }
}
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedList = memberList?.filter({$0.name?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased()})
        isSearching = true
        //Need to reload data with new search list
        reloadTableData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        //Need to reload data  here
        reloadTableData()
    }
    
}



