//
//  TitleTableViewCell.swift
//  NetflixClone
//
//  Created by 潘立婷 on 2022/8/14.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    static let identifier = "TitleTableViewCell"
    
    private let playButton : UIButton = {
        
        let button = UIButton()
        let image = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        
        return button
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titlePosterUIImageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        “translatesAutoresizingMaskIntoConstraints”
//        這 property 的用途是告訴 iOS 自動建立放置位置的約束條件，而第一步是須明確告訴它不要這樣做，因此需設為false。
        imageView.clipsToBounds = true
        return imageView
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titlePosterUIImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
        
        applyConstraints()
        
    }//建完這一串，如果沒有加上required那段會報錯，一定要加。
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    private func applyConstraints(){
        let titlePosterUIImageViewConstraints = [
            titlePosterUIImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titlePosterUIImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titlePosterUIImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            titlePosterUIImageView.widthAnchor.constraint(equalToConstant: 100)
        ]
        
        let titleLabelConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: titlePosterUIImageView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        let playButtonConstraints = [
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(titlePosterUIImageViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(playButtonConstraints)
    }
    
    public func configure(with model : TitleViewModel){
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else{return}
        titlePosterUIImageView.sd_setImage(with: url, completed:  nil)
        titleLabel.text = model.titleName
    }
    
}










/*
 這一大串感覺像是在真正開始建立東西時所需要的必要準備動作，不知道可不可以要用的時候就無腦加上去然後再開始打。
 class TitleTableViewCell: UITableViewCell {

     static let identifier = "TitleTableViewCell"
     
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
     }//建完這一串，如果沒有加上required那段會報錯，一定要加。
     
     required init?(coder: NSCoder) {
         fatalError()
     }
     
 }
 
 加完之後開始加入ImageView的設定
 */
