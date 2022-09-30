//
//  UpComingViewController.swift
//  NetflixClone
//
//  Created by 潘立婷 on 2022/7/27.
//

import UIKit

class UpComingViewController: UIViewController {
    
    private var titles : [Title] = [Title]()
    
    private let upComingTable : UITableView = {
        
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "UpComing"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always //應該是在往下捲動時Title不要縮小
        
        view.addSubview(upComingTable)
        upComingTable.delegate = self
        upComingTable.dataSource = self

        fetchUpComing()

    }
    
    
    //要加入layoutSubview才會出現設定好的cell
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upComingTable.frame = view.bounds
    }
    
    private func fetchUpComing(){
        APICaller.shared.getUpComingMovies { [weak self] results in
            switch results{
            case.success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.upComingTable.reloadData()
                }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

extension UpComingViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else{return UITableViewCell()}
        
//        cell.textLabel?.text = titles[indexPath.row].original_title ?? "Unknow" 這行改道configure裡面了。
        //本來影片中有放三個 ?? 有一個是original name, 但是這邊沒有這個model所以就沒放了。
        //在做好TitleTableViewCell以及TitleViewModel之後，將這邊的設定替換過去。
        
        let title = titles[indexPath.row]
        
        cell.configure(with: TitleViewModel(titleName: title.original_title ?? "unknow", posterURL: title.poster_path ?? "poeterURL notFound"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let title = titles[indexPath.row]
        
        guard let titleName = title.original_title else{ return }
        
        APICaller.shared.getMovie(with: titleName) { result in
            switch result {
            case.success(let videosElement):
            DispatchQueue.main.async { [weak self] in
                let vc = TitlePreviewViewController()
                vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videosElement, titleOverview: title.overview ?? ""))
                self?.navigationController?.pushViewController(vc, animated: true)//也不知道為何要用self?，因為上面用了weak self所以這邊一定要加入self才能運作。
            }
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
