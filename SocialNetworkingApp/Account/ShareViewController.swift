//
//  ShareViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//

import UIKit
import CoreImage

enum ShareBackgroundState: Int, CaseIterable, CustomStringConvertible{
    
    case color = 0, image, emoji, selfie
    var nextState: ShareBackgroundState {
        guard let state = ShareBackgroundState(rawValue: (self.rawValue + 1) % ShareBackgroundState.allCases.count) else { return .color}
        return state
    }
    mutating func toNextState(){
        self = self.nextState
    }
    var description: String{
        switch self {
        case .color:
            return "color"
        case .image:
            return "image"
        case .emoji:
            return "emoji"
        case .selfie:
            return "selfie"
        }
    }
}

class ShareViewController: UIViewController {
    
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var qrCodeContainerView: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var functionsContainerView: UIView!
    @IBOutlet weak var shareProfileButton: UIButton!
    @IBOutlet weak var copyLinkButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var userProfile: UserProfile!{
        didSet{
            generateRequiredProperties()
        }
    }
    
    var profileURL: URL?
    var webURL: URL?
    var qrCodeImage: UIImage?
    private var currentBackgroundState: ShareBackgroundState = .color {
        didSet{
            changeBackgroundButtonTitle()
            changeBackground()
        }
    }
    
    private var backgroundViews: [UIView] = []
    private var currentBackgroundView: UIView = UIView()
    
    func changeBackgroundButtonTitle(){
        
        var config = backgroundButton.configuration ?? UIButton.Configuration.plain()
        var newTitle = AttributedString(currentBackgroundState.description.uppercased())
        newTitle.font = .boldSystemFont(ofSize: 10)
        config.attributedTitle = newTitle
        backgroundButton.configuration = config
    }
    
    func changeBackground(){
        currentBackgroundView.removeFromSuperview()
        currentBackgroundView = backgroundViews[currentBackgroundState.rawValue]
        view.insertSubview(currentBackgroundView, at: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUserProfile()
        addBackgroundTaps()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        qrCodeContainerView.layer.cornerRadius = 12
        functionsContainerView.layer.cornerRadius = 12
        backgroundButton.layer.cornerRadius = 12
        backgroundButton.layer.borderColor = UIColor.white.cgColor
        backgroundButton.layer.borderWidth = 1
    }
    
    func setupView(){
        setupBackgroundViews()
        qrCodeImageView.image = qrCodeImage
        qrCodeImageView.contentMode = .scaleAspectFill
        var config = UIButton.Configuration.plain()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        config.preferredSymbolConfigurationForImage = largeConfig
        config.imagePlacement = .top
        config.imagePadding = 8
        config.baseForegroundColor = .black
        var attributedTitle: AttributedString
        for (button, imageName, title) in [(shareProfileButton, "square.and.arrow.up.circle", "Share Profile"),
                                           (copyLinkButton, "link.circle", "Copy Link"),
                                           (downloadButton, "arrow.down.to.line","Download")]{
            config.image = UIImage(systemName: imageName)
            attributedTitle = AttributedString(title)
            attributedTitle.font = .systemFont(ofSize: 10, weight: .regular)
            config.attributedTitle = attributedTitle
            button?.configuration = config
        }
    }
    
    func setupBackgroundViews(){
        let colorView = ColorShareView(frame: view.bounds)
        backgroundViews.append(colorView)
        let emojiView = EmojiShareView(frame: view.bounds)
        emojiView.backgroundColor = .red
        backgroundViews.append(emojiView)
        let selfieView = SelfieShareView(frame: view.bounds)
        selfieView.backgroundColor = .yellow
        backgroundViews.append(selfieView)
        let imageView = ImageShareView(frame: view.bounds)
        imageView.backgroundColor = .blue
        backgroundViews.append(imageView)
        currentBackgroundView = colorView
        currentBackgroundState = .color
    }
    
    func setupUserProfile(){
        nameLabel.text = "@"+userProfile.name.uppercased().replacingOccurrences(of: " ", with: "_")
    }
    
    private func addBackgroundTaps(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        view.addGestureRecognizer(singleTap)
    }
    
    private func generateRequiredProperties(){
        guard let username = userProfile?.username else { return }
        let profileURLString = "my-app://profiles/\(username)"
        guard let profileURL = URL(string: profileURLString) else {
            print("Error: Invalid profile URL.")
            return
        }
        self.profileURL = profileURL
        let webURLString = "https://www.instagram.com/philips_j0se/"
        guard let webURL = URL(string: webURLString) else {
            print("Error: Invalid web URL string.")
            return
        }
        self.webURL = webURL
        guard let qrCodeImage = generateQRCode(from: profileURLString) else {
            print("Error: Could not generate QR code image.")
            return
        }
        self.qrCodeImage = qrCodeImage
    }
    
    @objc func handleSingleTap(){
        switch currentBackgroundState {
        case .color:
            let view = currentBackgroundView as! ColorShareView
            view.currentColor.toNextColor()
        default:
            print()
//        case .image:
//
//        case .emoji:
//            
//        case .selfie:
            
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any){
        dismiss(animated: true)
    }
    
    @IBAction func backgroundButtonTapped(_ sender: Any){
        backgroundButton.bounceEffect(withScale: 0.95, withDuration: 0.5)
        currentBackgroundState = currentBackgroundState.nextState
    }
    
    @IBAction func shareProfileButtonTapped(_ sender: Any){
        guard let profileURL = profileURL,
        let webURL = webURL,
        let qrCodeImage = qrCodeImage
        else { return }
        let shareText = "Check out my profile on MyAwesomeApp!"
        let items: [Any] = [shareText, profileURL, webURL, qrCodeImage]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - QR Code Generation
extension ShareViewController{
    // A helper method to generate a QR code image from a given string.
    private func generateQRCode(from string: String) -> UIImage? {
        // 1. Get the data from the string.
        let data = string.data(using: String.Encoding.ascii)
        
        // 2. Create a QR code filter.
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        // 3. Set the input message and error correction level.
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        // 4. Get the output image from the filter.
        guard let ciImage = qrFilter.outputImage else {
            return nil
        }
        
        // 5. Scale the QR code to a larger, more usable size.
        let scaleX = 200 / ciImage.extent.size.width
        let scaleY = 200 / ciImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let scaledImage = ciImage.transformed(by: transform)
        
        // 6. Convert the CIImage to a UIImage.
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
