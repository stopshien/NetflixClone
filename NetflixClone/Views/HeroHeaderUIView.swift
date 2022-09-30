//
//  HeroHeaderUIView.swift
//  NetflixClone
//
//  Created by 潘立婷 on 2022/7/31.
//

import UIKit

class HeroHeaderUIView: UIView {

    private let heroImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Dune")
        //加入完圖片後需將HomeViewController內的tableHeaderView更改成為這個設定，否則不會成功顯示
        return imageView
    }()
    
    private let playButton : UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let downloadButton : UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5

        return button
    }()
    
    func addGradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    //要先加下面這兩個東西，目前不知道實際作用
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(heroImageView)
      //  heroImageView.frame = bounds 不是加在這裡，是在下面新增layoutSubViews的override後的裡面
       
        addGradient()
        //不能把下面這行移到上面，因為layout的順序會導致看不到按鈕，圖層被移到下面去了。
        addSubview(playButton)
        
        addSubview(downloadButton)
        applyConstraints()
    }

    
    override func layoutSubviews() {
        heroImageView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func applyConstraints(){
         //記得從要從後面計算距離的要用負的
        let playButtonConstraints = [
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor , constant: 70),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            playButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        let downloadButtonConstraints = [
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            downloadButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        //將constraint加入
        NSLayoutConstraint.activate(playButtonConstraints)
        NSLayoutConstraint.activate(downloadButtonConstraints)
        
    }
    
    public func configure(with model : TitleViewModel){
        
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else{return}
        heroImageView.sd_setImage(with: url,completed: nil)
        
    }
}
