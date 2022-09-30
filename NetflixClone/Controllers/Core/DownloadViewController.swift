//
//  DownloadViewController.swift
//  NetflixClone
//
//  Created by stopshien on 2022/7/27.
//

import UIKit

class DownloadViewController: UIViewController {
    
    //不知道為何是用TitleItem，也不知道TitleItem是從哪裡來的，貌似是DataBase自己生成的，我們自己並沒有定義過
    private var titles : [TitleItem] = [TitleItem]()

    
    private let DownloadTabel : UITableView = {
        
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Download"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always //應該是在往下捲動時Title不要縮小
        
        view.addSubview(DownloadTabel)
        
        DownloadTabel.delegate = self
        DownloadTabel.dataSource = self
        
        fetchLocalStorageForDownload()
        
        //因相同的命名而被觸發
        NotificationCenter.default.addObserver(forName: Notification.Name("Downloaded"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForDownload()
        }
    }
    
//儲存下載的影片的func
    private func fetchLocalStorageForDownload(){
        DataPersistenceManager.shared.fetchingTitlesFromDataBase { [weak self] result in
            switch result{
            case.success(let titles):
                self?.titles = titles
                self?.DownloadTabel.reloadData()
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DownloadTabel.frame = view.bounds
    }

}

extension DownloadViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
            }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else{
            return UITableViewCell()
        }
        
        let title = titles[indexPath.row]
        
        cell.configure(with: TitleViewModel(titleName: title.original_title ?? "unknow" , posterURL: title.poster_path ?? ""))
        
        return cell
        
        
        /*
         1. 先設一個cell來自於之前創立好的titletableViewCell中已定義好的identifier
         2. 將cell進行配置設定模型中的參數
         3. 又因參數中需要抓取titles中的變數，故另外設置title為titles矩陣內的東西，以便在呼叫時的簡潔
         
         */
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    //實作一個向左滑刪除的功能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        switch editingStyle{
        case.delete:
            
            DataPersistenceManager.shared.deleteTitleWith(model: titles[indexPath.row]) { [weak self] result in
                switch result{
                case.success():
                    print("Delete from the Database")
                case.failure(let error):
                    print(error.localizedDescription)
                }
                self?.titles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        default: return
        }
        
        /*
         打這樣就好也可以順利執行刪除動作，但刪除的動作無法儲存，重開模擬器後刪除的東西會再出現，下列網頁為參考
         https://medium.com/@cwlai.unipattern/app開發-使用swift-9-swipe-向左滑動-a0e286660211
         if editingStyle == .delete {
             titles.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .fade)
         }
         */
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
