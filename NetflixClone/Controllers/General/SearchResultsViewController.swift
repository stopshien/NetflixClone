//
//  SearchResultsViewController.swift
//  NetflixClone
//
//  Created by stopshien on 2022/8/15.
//

import UIKit

//collectionView中要實作點擊Cell後的動作，先進行協定一個變數來自於TitlePreviewModel的viewModel的func
protocol SearchResultsViewControllerDelegate : AnyObject {
    
    func searchResultsViewControllerDidTapItem(_ viewModel:TitlePreviewViewModel)
    
}

class SearchResultsViewController: UIViewController {

    //因為要提供給SearchViewController中串連，故從原本的private更改為public
    
    public var titles : [Title] = [Title]()
    
    //制定一個變數稱作delegate並且宣告為遵從上方的SearchResultsViewControllerDelegate的協定
    public weak var delegate : SearchResultsViewControllerDelegate?
    
    public let searchResultsCollectionView : UICollectionView = {
        
        /*
         建立collectionView，其中需要layout故設定一個參數layout，並且運用TitleCollectionViewCell中的資料。
         */
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10, height: 200)
        //設定cell彼此的間隔，在這邊有加跟沒加一樣。
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.backgroundColor = .systemBackground
        view.addSubview(searchResultsCollectionView)
        
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsCollectionView.frame = view.bounds
    }

   

}


extension SearchResultsViewController: UICollectionViewDelegate,UICollectionViewDataSource{
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else{return UICollectionViewCell()}
        
        
        let title = titles[indexPath.row]
        cell.configure(with: title.poster_path ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
       
        let title = titles[indexPath.row]
        guard let titleName = title.original_title else{return}
        
        APICaller.shared.getMovie(with: titleName) { [weak self] results in
            switch results{
            case.success(let videoElement):
                /*
                 若在這邊不使用DispatchQueue的話，在後續SearchViewController的實作中則一定要加入，否則無法正常作動
                 DispatchQueue.main.async {
                     self?.delegate?.searchResultsViewControllerDidTapItem(TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
                 }
                 */

            self?.delegate?.searchResultsViewControllerDidTapItem(TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))

            case.failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    
}
