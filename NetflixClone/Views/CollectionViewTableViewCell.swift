//
//  CollectionViewTableViewCell.swift
//  NetflixClone
//
//  Created by stopshien on 2022/7/28.
//

// 疑問 reuseIdentifier required fatalError()-app強制退出指令


import UIKit

//不知道什麼意思，應該是按下Cell之後要做的事情的協定吧，用好後在下方class中加入此協定 var delegate
protocol CollectionViewTableViewCellDelegate : AnyObject{
    func collectionViewTableViewCellDidTapCell(_ cell : CollectionViewTableViewCell, viewMdoel : TitlePreviewViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {

    static let identifier = "CollectionViewTableViewCell"
    
    private var titles : [Title] = [Title]()
    
    //不知道為何要用weak
    weak var delegate : CollectionViewTableViewCellDelegate?
    
    private let collectionView : UICollectionView = {
        //設定collection裡的物件，取名為layout
        let layout = UICollectionViewFlowLayout()
        //設定其中內容視圖的長寬大小
        layout.itemSize = CGSize(width: 140, height: 200)
        
        layout.scrollDirection = .horizontal
        let collectionViewInside = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //UICollectionViewCell.self看不懂-> 已經被刪掉了，只是一個暫時替代的畫面，建立TitleCollectionViewCell後即可被取代。
        collectionViewInside.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionViewInside
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemPink
        
        contentView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //將要放入照片的小視窗加入collectionView的cell裡面，並且在上方layout那邊設定長寬大小。
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with titles : [Title]){
        self.titles = titles
        //Dispatch queues 是 Grand Central Dispatch（GCD）的其中一個工具。它讓你可以以非同步（asynchronously）或同步（synchronously）的方式執行一段程式碼。這也就是所謂的並行（concurrency）處理。 總之貌似是一個讓資源順利分配的系統。
        DispatchQueue.main.async {
            [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    
    private func downloadTitleAt(indexPath : IndexPath){
        
        DataPersistenceManager.shared.downloadTitleWith(model: titles[indexPath.row]) { result in
            switch result{
                
            case.success():
                /*
                讓download的動作立刻執行到下載頁面，不然都需要重新開啟模擬器才會出現上一次下載的項目，需要在DownloadViewController的override那邊加入觀察者
                Notification若命名相同的名稱(Key)，則視為相同事件，將會同是被觸發，故這邊被觸發，觀察者那邊也會跟著被觸發。(應該是)
                 http://aiur3908.blogspot.com/2020/06/ios-swift-notificationcenter.html
                 */
               
                NotificationCenter.default.post(name: Notification.Name("Downloaded"), object: nil)
            case.failure(let error):
                print(error.localizedDescription)
                
            }
        }
        
       // print("Download \(titles[indexPath.row].original_title ?? "") ")
        
    }
    
}




extension CollectionViewTableViewCell : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else{
            return UICollectionViewCell()
        }
        guard let model = titles[indexPath.row].poster_path else{return UICollectionViewCell()}
        cell.configure(with: model) //在TitleCollectionViewCell裡面的一個Func
        return cell
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        cell.backgroundColor = .green
//        return cell
//        原本用來顯示綠色框框的Cell，用正式的Cell取代。
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //取消選擇
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title else{return}
 
        //因為我們要搜尋預告片，所以加上trailer。
        APICaller.shared.getMovie(with: titleName + "trailer") { [weak self] result in
            switch result{
                
            case.success(let videoElement):
                let title = self?.titles[indexPath.row]
                guard let titleOverView = title?.overview else {return}
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: titleOverView)
                
                guard let strongsSelf = self else{return}
                
                self?.delegate?.collectionViewTableViewCellDidTapCell(strongsSelf, viewMdoel: viewModel)
                
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
        
        /*
         教學影片中有加入了很多東西，好像不加也可以，很多東西也寫得不一樣，所以下面的是我的版本，一樣可以正常運作，上面是影片中完整版本
         
         APICaller.shared.getMovie(with: titleName + "trailer") { result in
             switch result{
                 
             case.success(let videoElement):
                 
                 let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? "")
                 
                 self.delegate?.collectionViewTableViewCellDidTapCell(self, viewMdoel: viewModel)
                 
             case.failure(let error):
                 print(error.localizedDescription)
             }
         }
         
         */
    
    }
    //加入長按後會出現選單的視窗的功能(在這邊是為了加入download的功能選項)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
       
        
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { [weak self]  _ in   //上面downloadTitleAt func 使用private 這邊一定要使用[weak self]不然無法使用
                let downloadAction = UIAction(title: "Download", subtitle: nil, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { _ in   //教學中將attributes直接刪掉了，應該是改變按鈕樣式的，和Button變藍變紅一樣，現在這樣是紅色。
                    self?.downloadTitleAt(indexPath: indexPath)
                }
                
                return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction])
        }
        
        return config
        
        /*
         用下面方式打也可以，可參考網站https://www.gushiciku.cn/pl/gafH/zh-tw
         let favorite = UIAction(title: "Favorite", image: UIImage(systemName: "heart.fill")) { action in
                 print("favorite")
             }
         return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(title: "Actions", children: [favorite])
            }
         */
    }
}
