//
//  VideoContainerView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 31/07/25.
//

import UIKit
import AVFoundation

class VideoContainerView: UIView {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    // MARK: - Player Observers (Recommended for Robustness)

    var playerItemStatusObservation: NSKeyValueObservation?
    var playerDidEndObservation: NSObjectProtocol? // For NotificationCenter
    
    func setupVideoPlayer(with videoURL: URL){
        guard let path = Bundle.main.path(forResource: "sample_video", ofType: "mp4") else {
            print("❌ Error: Video file 'sample_video.mp4' not found in bundle.")
            return
        }
        let videoURL = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        playerLayer?.frame = bounds
        addPlayerObservers()
        player?.play()
    }
    
    func addPlayerObservers() {
        guard let player = player else { return }
        playerItemStatusObservation = player.currentItem?.observe(\.status, options: [.new, .old], changeHandler: { (playerItem, change) in
            switch playerItem.status {
            case .readyToPlay:
                break
                //print("✅ PlayerItem is ready to play.")
            case .failed:
                //print("❌ PlayerItem failed to load: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                break
            case .unknown:
                //print("❔ PlayerItem status is unknown.")
                break
            @unknown default:
                fatalError("Unknown AVPlayerItem status")
            }
        })

        playerDidEndObservation = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            print("🔄 Video finished playing. Looping...")
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }

    func removePlayerObservers() {
        playerItemStatusObservation?.invalidate()
        playerItemStatusObservation = nil

        if let observation = playerDidEndObservation {
            NotificationCenter.default.removeObserver(observation)
            playerDidEndObservation = nil
        }
    }
}
