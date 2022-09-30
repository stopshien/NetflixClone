//
//  ViewController.swift
//  NetflixClone
//
//  Created by 潘立婷 on 2022/7/26.
//
//
import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemYellow
        
        let vc1 = UINavigationController(rootViewController : HomeViewController())
        let vc2 = UINavigationController(rootViewController: UpComingViewController())
        let vc3 = UINavigationController(rootViewController: SearchViewController())
        let vc4 = UINavigationController(rootViewController: DownloadViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "play.circle")
        vc3.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        vc4.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")
        
        vc1.title = "首頁"
        vc2.title = "熱播新片"
        vc3.title = "搜尋"
        vc4.title = "下載"

        //讓下方圖示能夠隨著模擬器的深淺色模式做更換，command + shift + A = 在模擬器切換深色模式
        tabBar.tintColor = .label
        
        setViewControllers([vc1,vc2,vc3,vc4], animated: true)
    }


}

