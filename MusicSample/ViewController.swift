//
//  ViewController.swift
//  MusicSample
//
//  Created by Akihiko Okubo on 2018/03/08.
//  Copyright © 2018年 akihiko.okubo. All rights reserved.
//

import UIKit
import MediaPlayer

/**
 DataSource用の構造体
 */
struct Track {
    let id: String
    let trackTitle: String?
    let artwork: MPMediaItemArtwork?
    let album: String?
    let artistName: String?
}

/**
 ViewController
 */
class ViewController: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let player = MPMusicPlayerController.systemMusicPlayer
    var track: Track?
    var tableViewDataSource: [Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMusicDidChangedNotification()
        showMusicInfo()
        tableView.tableFooterView = UIView()
    }

    /// 再生中の曲が変わった場合に通知を受ける
    private func setMusicDidChangedNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(showMusicInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        player.beginGeneratingPlaybackNotifications()
    }
    
    /// Viewへの反映
    @objc private func showMusicInfo() {
        if let item = player.nowPlayingItem {
            //MPMediaItem#playbackStoreIDにそのTrackのApple MusicでのユニークIDが入っている。このIDがあれば再生できる
            track = Track(id: item.playbackStoreID,
                  trackTitle: item.title,
                  artwork: item.artwork,
                  album: item.albumTitle,
                  artistName: item.artist)
        }
        DispatchQueue.main.async {
            self.artwork.image = self.track?.artwork?.image(at: CGSize(width: 200, height: 200))
            self.trackTitle.text = self.track?.trackTitle
            self.album.text = self.track?.album
            self.artistName.text = self.track?.artistName
        }
    }

    /// TableViewのデータソースに積む
    @IBAction func bookmark(_ sender: Any) {
        if let t = track {
            tableViewDataSource.append(t)
            tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.render(track: tableViewDataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tableViewDataSource[indexPath.row]
        //playerにApple MusicのTrackIDを入れると再生できる(もちろんサブクリプションしている場合のみ)
        player.setQueue(with: [track.id])
        player.play()
    }
    
}

/**
 セルの実装
 */
class TrackCell: UITableViewCell {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    func render(track: Track) {
        artwork.image = track.artwork?.image(at: CGSize(width: 40, height: 40))
        trackTitle.text = track.trackTitle
        artistName.text = track.artistName
    }
}
