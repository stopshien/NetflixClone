//
//  DataPersistenceManager.swift
//  NetflixClone
//
//  Created by stopshien on 2022/8/27.
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager{
    
    enum DataBaseError : Error{
        
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    static let shared = DataPersistenceManager()
    //看了老半天還是看不懂什麼意思
    func downloadTitleWith(model: Title , completion: @escaping(Result<Void , Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        
        let context = appDelegate.persistentContainer.viewContext
        
        let item = TitleItem(context: context) //也是不知道TitleItem從哪裡來的
        
        item.original_title = model.original_title
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.id = Int64(model.id)
        item.media_type = model.media_type
        item.original_language = model.original_language
        item.release_date = model.release_date
        item.vote_average = model.vote_average
        item.vote_count = Int64(model.vote_count)
        
        do {
            
            try context.save()
            completion(.success(()))
            
        } catch {
            completion(.failure(DataBaseError.failedToSaveData))
        }
    }
    
    func fetchingTitlesFromDataBase(completion : @escaping (Result<[TitleItem], Error>) -> Void){
        
        /*
         轉換成Core Data架構，https://medium.com/@cwlai.unipattern/app開發-使用swift-19-core-data-e6dd348ab445
         從appDelegate到context的定義感覺蠻制式化且固定的
         */
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        
        let context = appDelegate.persistentContainer.viewContext //(context:背景 情況 persistent:持續的 container:容器)
        
        let request : NSFetchRequest<TitleItem>
        
        request = TitleItem.fetchRequest()
        
        do{
            let titles = try context.fetch(request)
            completion(.success(titles))
            
        }catch{
            completion(.failure(DataBaseError.failedToFetchData))
        }
        
    }
    
    func deleteTitleWith(model : TitleItem , completion: @escaping(Result<Void , Error>) -> Void){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        
        let context = appDelegate.persistentContainer.viewContext //(context:背景 情況 persistent:持續的 container:容器)
     
        context.delete(model) //詢問data base manager 刪除
        
        do{
            try context.save()
            completion(.success(()))
        }catch{
            completion(.failure(DataBaseError.failedToDeleteData))
        }
    }
    
}
