//
//  TitleCollectionViewCell.swift
//  NetflixClone
//
//  Created by 潘立婷 on 2022/8/12.
//

import UIKit
import SDWebImage // 步驟詳見最下層

class TitleCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TitleCollectionViewCell"
    
    //為了匯入posterImage，建立ImageView
    private let posterImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView) // 加入posterImageView
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //製作Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }
    
    //製作Poster需要的Model的Func，會抓出poster所需要的圖片檔名，然後再將檔名導入url。
    //url 檔名前面的網域再到tmdb裡面的Image找。
    public func configure(with model : String){
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model)") else{return}
        posterImageView.sd_setImage(with: url, completed: nil)
    }
    
    
}

/*
 使用第三方網站 https://github.com/SDWebImage/SDWebImage
 在裡面找到Code按鍵後複製裡面網址，再回到Xcode這邊，
 從File -> add Package -> 將網址貼上後選取並確認。
 最後記得需要進行Import
 */
