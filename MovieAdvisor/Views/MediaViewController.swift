//
//  ViewController.swift
//  TMDB my self
//
//  Created by Леонід Шевченко on 03.08.2021.
//

import UIKit
import Alamofire
import RealmSwift

class MediaViewController: UIViewController {
    
    var tvShows: [TVShow] = []
    var movies: [Movie] = []
    
    
    
    let realm = try? Realm()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var TVMovieSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tvTableViewCellIdentifier = String(describing: TVShowTableViewCell.self)
        self.tableView.register(UINib(nibName: tvTableViewCellIdentifier, bundle: nil),
                                 forCellReuseIdentifier: tvTableViewCellIdentifier)
        
        let movieTableViewCellIdentifier = String(describing: MovieTableViewCell.self)
        self.tableView.register(UINib(nibName: movieTableViewCellIdentifier, bundle: nil),
                                 forCellReuseIdentifier: movieTableViewCellIdentifier)
        
        
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.ui.defaultCellIdentifier)
        
        
        self.title = Constants.viewControllerTitles.media
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.requestTrendingTVShows()
        self.requestTrendingMovies()
        
    }
    
    
    
    //MARK: - Network request for reloading TVs
    func requestTrendingTVShows() {
        
        let url = "https://api.themoviedb.org/3/trending/tv/week?api_key=\(Constants.network.apiKey)"
        AF.request(url).responseJSON { responce in
            
            let decoder = JSONDecoder()
            
            if let data = try? decoder.decode(PopularTVShowResult.self, from: responce.data!){
                self.tvShows = data.tvShows ?? []
                self.tableView.reloadData()
            }
            
        }
    }
    
    //MARK: - Network request for reloading movies
    func requestTrendingMovies() {
        
        let url = "https://api.themoviedb.org/3/trending/movie/week?api_key=\(Constants.network.apiKey)"
        AF.request(url).responseJSON { responce in
            
            let decoder = JSONDecoder()
            
            if let data = try? decoder.decode(PopularMovieResult.self, from: responce.data!){
                self.movies = data.movies ?? []
                self.tableView.reloadData()
            }
            
        }
    }
    
    
}

//MARK: - DataSource for tableView
extension MediaViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedIndex = self.TVMovieSegmentedControl.selectedSegmentIndex
        switch selectedIndex
        {
        case 0:
            return tvShows.count
        case 1:
            return movies.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectedIndex = self.TVMovieSegmentedControl.selectedSegmentIndex
        switch selectedIndex {
        case 0:
            let tvShowCell = tableView.dequeueReusableCell(withIdentifier: "TVShowTableViewCell", for: indexPath) as! TVShowTableViewCell
            
            // UI for TVShows
            let tvMedia = self.tvShows[indexPath.row]
            let tvShowImagePathString = Constants.network.defaultImagePath + tvMedia.posterPath!
            tvShowCell.tvConfigureWith(imageURL: URL(string: tvShowImagePathString),
                                   TVName: tvMedia.name,
                                   desriptionText: tvMedia.overview)
            
            return tvShowCell
        case 1:
     
            let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell

            // UI for Movies
            let moviesMedia = self.movies[indexPath.row]
            let movieImagePathString = Constants.network.defaultImagePath + moviesMedia.posterPath!
            movieCell.movieConfigureWith(imageURL: URL(string: movieImagePathString),
                                          movieName: moviesMedia.name,
                                          desriptionText: moviesMedia.overview)
            return movieCell
        default:
            return UITableViewCell()
        }
        

        

        
        
    }
    
    @IBAction func TVMovieSegmentedChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
}
//MARK: - Delegate for tableView
extension MediaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let selectedIndex = self.TVMovieSegmentedControl.selectedSegmentIndex
        
        switch selectedIndex {
        case 0:
            let TVidentifier = String(describing: TVShowDetailsViewController.self)
            
            if let detailViewController = storyboard.instantiateViewController(identifier: TVidentifier) as? TVShowDetailsViewController {
                detailViewController.tvShow = self.tvShows[indexPath.row]
                
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
        case 1:
            let movieidentifier = String(describing: MovieDetailsViewController.self)
            
            if let detailViewController = storyboard.instantiateViewController(identifier: movieidentifier) as? MovieDetailsViewController {
                detailViewController.movie = self.movies[indexPath.row]
                
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
            
        default:
            let TVidentifier = String(describing: TVShowDetailsViewController.self)
            
            if let detailViewController = storyboard.instantiateViewController(identifier: TVidentifier) as? TVShowDetailsViewController {
                detailViewController.tvShow = self.tvShows[indexPath.row]
                
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  540
    }
    //Appearing cells animation
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectedIndex = self.TVMovieSegmentedControl.selectedSegmentIndex
        
        switch selectedIndex {
        case 0:
            let TVidentifier = String(describing: TVShowDetailsViewController.self)
            
            if storyboard.instantiateViewController(identifier: TVidentifier) is TVShowDetailsViewController {
                
                let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 50, 0)
                cell.layer.transform = rotationTransform
                cell.alpha = 0.5
                
            }
           
        case 1:
            let movieidentifier = String(describing: MovieDetailsViewController.self)
            
            if storyboard.instantiateViewController(identifier: movieidentifier) is MovieDetailsViewController {
                let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, +500, 50, 0)
                cell.layer.transform = rotationTransform
                cell.alpha = 0.5
            }
           
        default:
            let TVidentifier = String(describing: TVShowDetailsViewController.self)
            
            if storyboard.instantiateViewController(identifier: TVidentifier) is TVShowDetailsViewController {
                
                let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 50, 0)
                cell.layer.transform = rotationTransform
                cell.alpha = 0.5
                
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
    }
    
    
}
