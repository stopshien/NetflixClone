//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by stopshien on 2022/7/26.
//

import UIKit

enum Sections: Int{
    case TrendingMoives = 0
    case TrendingTvs = 1
    case Popular = 2
    case UpComing = 3
    case TopRates = 4
}

class HomeViewController: UIViewController {
    
    
    private var randomTrendingMovie : Title?
    private var headerView : HeroHeaderUIView?
    
    let sectionTitles : [String] = ["熱門電影","熱門影集","最受歡迎的","即將上映電影","熱門排行"]

    private let homeFeedTable : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped) // .zero還不知道實際作用，上方會出現一段黑色區塊，放置電影封面
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavbar()
        configureHeroHeaderView()
        
        //使用tableHeaderView的方式加入上方展示圖，在Views群組在新建一個coco檔案製作這個View
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView // 不重新設定代數直接用上面那一串也可以，用代數之後其他地方要使用會比較方便

    //    fetchData() 測試完就刪掉了
        
        
    }
    
    private func configureHeroHeaderView(){
        
        /*
         進行headerView的配置需要使用titleViewModel內的變數，並且是使用
         在使用getTrendingMovies的API中，會有兩種result結果，若成功則讓getTrendingMovies中的headerView設定配置使用titleViewModel中的變數， 失敗則印出error，因想要讓變數隨機選取，故設定一個變數selectedTitle並且給予randomElement的屬性。
         教學影片中有提供最上面宣告為Title的變數randomTrendingMovie = selectedTitle 但實際上不使用也能正常運作。
         影片中的self皆為optional，有加？，在result前加上[weak self]，但不加[weak self]以及？也能正常運作，需注意若加上[weak self]，則self必須加上？才能正常運作。
         */
        APICaller.shared.getTrendingMovies { [weak self] result in
            switch result{
            case.success(let titles):
                let selectedTitle = titles.randomElement()
                self?.randomTrendingMovie = selectedTitle
                self?.headerView?.configure(with: TitleViewModel(titleName: selectedTitle?.original_title ?? "unknow", posterURL: selectedTitle?.poster_path ?? "unknow"))
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    private func configureNavbar(){
        
    //因為原本找的logo圖尺寸太大，執行時會位置會偏移到幾乎中間，所以需要利用重新調整size的func來更正
        let image = UIImage(named: "netflixLogo")
        var newImage = resizeImage(image: image!, width: 20)
        newImage = newImage.withRenderingMode(.alwaysOriginal)

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: newImage, style: .done, target: self, action: nil)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        
        navigationController?.navigationBar.tintColor = .white
      
}
    //其他網站找的func，原本教學裡沒有使用，可以重新調整圖片大小
  private func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
            let size = CGSize(width: width, height:
                image.size.height * width / image.size.width)
            let renderer = UIGraphicsImageRenderer(size: size)
            let newImage = renderer.image { (context) in
                image.draw(in: renderer.format.bounds)
            }
            return newImage
    }
    
//建立func加入在APICaller中已經製作好的func，並在上方override呼叫，這是一個測試用的Func，測試APICaller能否正確執行，測試完後教學影片就把它刪掉了
//    private func fetchData(){
////        APICaller.shared.getTrendingMovies { results in
////            switch results {
////            case .success(let movies):
////                print(movies)
////            case .failure(let error):
////                print(error)
////            }
////        }

////        APICaller.shared.getTrendingTvs { results in
////            //
////        }
//
////        APICaller.shared.getUpComingMovies { _ in
////
////        }
//
////        APICaller.shared.getPopular { _ in
////
////        }
//        APICaller.shared.getTopRate { _ in
//
//        }
//        }
    
    
    
    //將frame的那段移到上面viewDidLoad裡，這整段刪掉看起來也可以正常運作，還不知道為何要另外拉出來。
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        homeFeedTable.frame = view.bounds
    }
  
}



extension HomeViewController: UITableViewDelegate , UITableViewDataSource{
    //要有幾個section
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    //每一個section裡面有幾個cell，在views那邊的collectionView會加入決定的collectionView數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else{
            return UITableViewCell()
        }
        
        cell.delegate = self //在設定好CollectionViewTableViewCellDelegate後加入
        
        switch indexPath.section{
            
        case Sections.TrendingMoives.rawValue:
            APICaller.shared.getTrendingMovies { results in
                switch results {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        case Sections.TrendingTvs.rawValue:
            APICaller.shared.getTrendingTvs { results in
                switch results{
                case.success(let titles):
                    cell.configure(with: titles)
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        case Sections.Popular.rawValue:
            APICaller.shared.getPopular { results in
                switch results{
                case.success(let titles):
                    cell.configure(with: titles)
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.UpComing.rawValue:
            APICaller.shared.getUpComingMovies { results in
                switch results{
                case.success(let titles):
                    cell.configure(with: titles)
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TopRates.rawValue:
            
            APICaller.shared.getTopRate { results in
                switch results{
                case.success(let titles):
                    cell.configure(with: titles)
                case.failure(let error):
                    print(error)
                }
            }
            
        default:
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //想要加入heander的時候使用
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    //客製化section中的文字大小粗度等，以及決定文字擺放位置的基準點和frame大小
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else{return}
        header.textLabel?.font = .systemFont(ofSize: 18 , weight: .semibold)
        //看似調整文字的起始點以及frame大小，但是有加沒加或是更改裡面的數值都沒有變化，還沒有搞懂為何。
//        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 400, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        
 //       header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter() 在extension中有制定一個大小寫函數，我打中文所以不需要使用
    }
    
    
    //上方navigationBar想要在上滑時定住，頁面往下拉時能夠收合看不到。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffSet = view.safeAreaInsets.top
        let offSet = scrollView.contentOffset.y + defaultOffSet
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offSet))
    }
    
    
    
    
}

extension HomeViewController : CollectionViewTableViewCellDelegate{
    
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewMdoel: TitlePreviewViewModel) {
        
        /*
         非同步執行(Async)：指的是不需要等待任何任務，任務之間的開始與結束不互相依賴，設定為Sync的Queue在每一次收到一個task後，將收到的任務丟到獨立的thread執行，任務之間非同步進行，並依照不同任務完成的先後，無特定順序的完成所有任務。
         */
        //加了DispatchQueue這串後就可以正確執行，但不知道為何，也看不懂為何要加入weak self 以及使用 in 這些鬼東西。
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewMdoel)
            self?.navigationController?.pushViewController(vc, animated: true)//也不知道為何要用self? 因為上面有用weak self，所以這邊需要指定self才能正常使用。
        }
       
    }
     
}
