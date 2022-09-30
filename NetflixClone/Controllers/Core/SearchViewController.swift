//
//  SearchViewController.swift
//  NetflixClone
//
//  Created by stopshien on 2022/7/27.
//

import UIKit

class SearchViewController: UIViewController {

    
    private var titles : [Title] = [Title]()

    private let discoverTable : UITableView = {
        
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
        
    }()
    
    private let searchController : UISearchController = {
        //searchResultsController將另一個頁面SearchResultsViewController()導入
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        //文字輸入匡內預設的文字
        controller.searchBar.placeholder = "Search for a Movie or TV show"
        //minimal,在往下拉時搜尋列表會跟著往上移動至消失
        controller.searchBar.searchBarStyle = .minimal
        
        return controller
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always //應該是在往下捲動時Title不要縮小

        view.backgroundColor = .systemBackground
        
        view.addSubview(discoverTable)
        
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        navigationItem.searchController = searchController
        //將搜尋列旁的取消字樣改顏色
        navigationController?.navigationBar.tintColor = .white
        
        fetchDiscoverMovies()
        
        searchController.searchResultsUpdater = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        discoverTable.frame = view.bounds
        
    }
    
    private func fetchDiscoverMovies(){
        APICaller.shared.getDiscoverMovie { [weak self] results in
            switch results{
            case.success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}


extension SearchViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else{return UITableViewCell()}
        
        /*需要設定cell.configure，其中需要導入來自titleViewModel的變數，故建立一個來自於TitleViewModel的變數取名為model，
         又因model中的變數需要使用到Models中Title的變數矩陣，故再設立一個名為title的變數，其中包含的是titles內的變數，
         又因title需要導入其他分頁(Title)中的變數，故在最上方有先建立好變數titles宣告為Title的型別了。
         */
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: title.original_title ?? "Unknow Name", posterURL: title.poster_path ?? "Unknow")
        cell.configure(with: model)
        
        return cell
    }
    
    //加入高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let title = titles[indexPath.row]
        
        let titleName = title.original_title ?? ""
        
        APICaller.shared.getMovie(with: titleName) { result in
            switch result {
            case.success(let VideosElement):
            DispatchQueue.main.async { [weak self] in
                let vc = TitlePreviewViewController()
                vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: VideosElement, titleOverview: title.overview ?? ""))
                self?.navigationController?.pushViewController(vc, animated: true)//也不知道為何要用self?，因為上面用了weak self所以這邊一定要加入self才能運作。
            }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating,SearchResultsViewControllerDelegate{
  

        func updateSearchResults(for searchController: UISearchController) {
            let searchBar = searchController.searchBar
            
            guard let query = searchBar.text,
                    !query.trimmingCharacters(in: .whitespaces).isEmpty, //移除字串前後的空白，但加上isEmpty不知道想做啥，貌似是要排除在扣除空白鍵後不是空集合的狀態。
                  query.trimmingCharacters(in: .whitespaces).count >= 3,//數入的文字要大於三個才會開始搜尋
                  let resultsController = searchController.searchResultsController as? SearchResultsViewController else{return}
            
            resultsController.delegate = self
            
            APICaller.shared.search(with: query) { result in
                DispatchQueue.main.async {
                    switch result{
                    case.success(let titles):
                        resultsController.titles = titles
                        resultsController.searchResultsCollectionView.reloadData()
                    case.failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    
    //加入實作的部分，其中加入前往TitlePreviewViewController的設定
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)

        }
    }
    /*
        如果在SearchResultsViewController中的didSelect的實作中，就已經有加入DispatchQueue的話，這邊可以不用再使用，以下方程式呈現即可正常使用。
         let vc = TitlePreviewViewController()
         vc.configure(with: viewModel)
         navigationController?.pushViewController(vc, animated: true)
        
     */

}

