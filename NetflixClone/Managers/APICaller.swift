//
//  APICaller.swift
//  NetflixClone
//
//  Created by stopshien on 2022/8/2.
//

import Foundation

struct constants{
    static let API_Key = "1ae4669859f2f194f5543ecb3a3153cb" //自己在TMDB裡的API Key
    static let baseURL = "https://api.themoviedb.org"      //TMDB中API網址的最前面
    static let YoutubeAPI_Key = "AIzaSyA5ZOzjoO3wCYipn-s-uoQtH8CiOvruEJo"
    static let YoutubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
    
    
}
//有關為何需要這個enum以及下列有關Result,success等用法可參考網誌https://reurl.cc/zNW6dV
enum APIError : Error{
    case failedToGetData
}

class APICaller{
    
    static let shared = APICaller()
    
    
    
    //escaping 讓函數裡的內部變數能夠在外部使用，但所有變數前都需加上self才可運作。
    //Result<[Movie], Error> 沒有很懂，ˇ已知Result宣告為Movie的型別(最後把所有型別統一為Title了)，Error不知道是怎樣。
    func getTrendingMovies(completion : @escaping (Result<[Title], Error>) -> Void){
        
        guard let url = URL(string: "\(constants.baseURL)/3/trending/movie/day?api_key=\(constants.API_Key)") else{return}
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else{return}
       //如果符合上面guard條件(data = data, error == nil)，則執行下面程序
       // do-catch: do用來製作要執行的動作，catch用來執行出現錯誤的處理方式(可以有很多種不同的處理方式)，詳見 https://itisjoe.gitbooks.io/swiftgo/content/ch2/error-handling.html
            
            do{
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data )
                completion(.success(results.results)) //這邊還是看不懂
//                print(results) 確認過console有成功導入矩陣後就可以不用了
                //JSONSerialization這邊都只是在還沒製作Model前拿來檢查的部分
//                try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(results) 將Movie中的Model做好之後把原本的這串刪掉更換成Model
            }catch{
                
                completion(.failure(APIError.failedToGetData))
                //print(error.localizedDescription) 製作完Model確認沒問題後替換成completion(.failure(error))，還不是很懂什麼意思，貌似是強制閃退。
                //最後將error部分再次替換成Enum設定的部分
            }
        }
        task.resume()
    }
    
    //[]中若還沒建立參數Tv時直接輸入會報錯，可先用String代替
    func getTrendingTvs(completion : @escaping (Result<[Title], Error>) -> Void){
        
        guard let url = URL(string: "\(constants.baseURL)/3/trending/tv/day?api_key=\(constants.API_Key)") else{return}

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else{return}
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    
    
    func getUpComingMovies(completion : @escaping (Result<[Title], Error>) -> Void){

        guard let url = URL(string:"\(constants.baseURL)/3/movie/upcoming?api_key=\(constants.API_Key)&language=en-US&page=1") else{return}

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {return}
            //直接使用TrendingMoviesResponse的Model
            do{
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                //JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                completion(.success(results.results))
             } catch {
                completion(.failure(APIError.failedToGetData))
            }

        }
        task.resume()
    }

    func getPopular(completion : @escaping (Result<[Title], Error>) -> Void){
        
        guard let url = URL(string: "\(constants.baseURL)/3/movie/popular?api_key=\(constants.API_Key)&language=en-US&page=1") else{return}

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else{return}
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    
    func getTopRate(completion : @escaping (Result<[Title], Error>) -> Void){
        
        guard let url = URL(string: "\(constants.baseURL)/3/movie/top_rated?api_key=\(constants.API_Key)&language=en-US&page=1") else{return}

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else{return}
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getDiscoverMovie(completion : @escaping (Result<[Title], Error>) -> Void){
        
     
        guard let url = URL(string: "\(constants.baseURL)/3/discover/movie?api_key=\(constants.API_Key)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate)") else{return}

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else{return}
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
        
    }
    
    func search(with query : String, completion : @escaping (Result<[Title], Error>) -> Void){
        
        //將url轉碼，詳見https://ithelp.ithome.com.tw/articles/10260448
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else{return}
        
        //使用tmdb裡的Search & Query For Details的API，需要再設一個query將其URL轉碼
        guard let url = URL(string: "\(constants.baseURL)/3/search/movie?api_key=\(constants.API_Key)&query=\(query)") else{return}
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else{return}
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
        
    }
    
    //建立從youtube API抓取的影片的func
    //VideosElement裡面只有一個變數 id，故不用使用矩陣[]
    func getMovie(with query: String, completion : @escaping (Result< VideosElement, Error>) -> Void){
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else{return}
        guard let url = URL(string: "\(constants.YoutubeBaseURL)q=\(query)&key=\(constants.YoutubeAPI_Key)") else{return}
        //直接從上面那一串複製過來，但completion會出現error，暫時用print(results)消除error後到HomeViewController的override加入func
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else{return}
            
            do {
                let results = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                //成功執行後取用矩陣中的第一項。然後到collectionView加入點選影片後也會出現搜尋結果的實作。
                completion(.success(results.items[0]))
            }
            catch{
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}


/*
網友建議：
打印error.localizedDescription具有誤導性，因為它只顯示一條毫無意義的通用錯誤消息。
所以永遠不要localizedDescription在Decodablecatch 塊中使用。
以簡單的形式
print(error)
它顯示了完整的錯誤，包括關鍵信息debugDescription和context. Decodable錯誤非常全面。

 //下方列出有可能會遇到的錯誤，使出現錯誤時更好看出問題的所在。
} catch let DecodingError.dataCorrupted(context) {
 print(context)
} catch let DecodingError.keyNotFound(key, context) {
 print("Key '\(key)' not found:", context.debugDescription)
 print("codingPath:", context.codingPath)
} catch let DecodingError.valueNotFound(value, context) {
 print("Value '\(value)' not found:", context.debugDescription)
 print("codingPath:", context.codingPath)
} catch let DecodingError.typeMismatch(type, context)  {
 print("Type '\(type)' mismatch:", context.debugDescription)
 print("codingPath:", context.codingPath)
} catch {
 print("error: ", error)
}
 
 */



/*
 要建立Youtube所使用的API
 1. 搜尋google developer console
 2. 登入後建立憑證
 3. 建立API金鑰
 4. 至<已啟用的API和服務> 按下<＋啟用API和服務>
 5. 將頁面往下滑找到Youtube Data API v3 點進去後選取啟用
 6. 回到憑證複製個人API 回來加入程式中
 --------------------------------
 7.然後再去google youtube api
 8.選取Search for content
 9.右邊視窗下滑到最底有一個show code，點進去後選HTTP，複製https://youtube.googleapis.com/youtube/v3/search?q=harry&key=[YOUR_API_KEY]，回來加到程式碼。
 
 */
