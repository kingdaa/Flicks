//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Qin Huang on 7/16/16.
//  Copyright © 2016 walmartlabs. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!

    var endpoint: String!
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self

        networkRequest()

        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.networkRequest(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControl, atIndex: 0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }


    func networkRequest(refreshControl: UIRefreshControl? = nil) {
        let apiKey = "7e717fcd43e2a662c91cf1f7cedfafb5"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")

        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                   delegate:nil,
                                   delegateQueue:NSOperationQueue.mainQueue())

        if refreshControl == nil {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }

        let task: NSURLSessionDataTask = session.dataTaskWithRequest(
            request, completionHandler: {(dataOrNil, response, error) in

                guard error == nil else {
                    self.networkErrorView.hidden = false
                    if let refreshControl = refreshControl {
                        refreshControl.endRefreshing()
                    } else {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                    return
                }

                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data,
                        options:[]) as? NSDictionary {
                        print("response: \(responseDictionary)")
                        self.movies = responseDictionary["results"] as? [NSDictionary]

                        if let refreshControl = refreshControl {
                            refreshControl.endRefreshing()
                        } else {
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                        }

                        self.tableView.reloadData()
                    }
                } else {
                    print("There was a network error")
                }
        })

        task.resume()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String

        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            // set image in MovieCell
            cell.posterView.setImageWithURL(imageUrl!)
        }

        print("row \(indexPath.row)")
        // Set cell selection style
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 255/255, green: 193/255, blue: 37/255, alpha: 0.8)
        cell.selectedBackgroundView = backgroundView
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }

}
