//
//  ShareViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//

import UIKit
import CoreImage

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUserProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        qrCodeContainerView.layer.cornerRadius = 12
        functionsContainerView.layer.cornerRadius = 12
        backgroundButton.layer.cornerRadius = 12 //backgroundButton.bounds.height / 2
        backgroundButton.layer.borderColor = UIColor.white.cgColor
        backgroundButton.layer.borderWidth = 1
    }
    
    func setupView(){
        view.backgroundColor = .blue
        backgroundButton.titleLabel?.font = .boldSystemFont(ofSize: 10)
        qrCodeImageView.image = qrCodeImage
        qrCodeImageView.contentMode = .scaleAspectFill
        var config = UIButton.Configuration.plain()
        //config.title = "Share Profile"
        var attributedTitle = AttributedString("Share Profile")
        attributedTitle.font = .systemFont(ofSize: 13, weight: .regular)
        config.attributedTitle = attributedTitle
        if let starSymbol = UIImage(systemName: "square.and.arrow.up.circle.fill") {
            config.image = starSymbol
        } else {
            print("Error: Could not find SF Symbol 'star.fill'.")
        }
        config.imagePlacement = .top
        config.imagePadding = 8
        config.baseForegroundColor = .black
        shareProfileButton.configuration = config
    }
    
    func setupUserProfile(){
        nameLabel.text = "@"+userProfile.name.uppercased().replacingOccurrences(of: " ", with: "_")
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
    
    @IBAction func closeButtonTapped(_ sender: Any){
        dismiss(animated: true)
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

// MARK: - SVG and UIImage Conversion
// This SVG represents three circles connected by lines in a triangle-like structure.
let threeCirclesTriangleSVG = """
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="5" r="3"/>
    <circle cx="5" cy="19" r="3"/>
    <circle cx="19" cy="19" r="3"/>
    <line x1="12" y1="8" x2="5.5" y2="16"/>
    <line x1="12" y1="8" x2="18.5" y2="16"/>
    <line x1="5.5" y1="16" x2="18.5" y2="16"/>
</svg>
"""

let filledStarSVG = """
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="#FFFFFF">
    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 18.06l-6.18 3.26L7 14.14 2 9.27l6.91-1.01L12 2z"/>
</svg>
"""
let filledStarSVGPath = "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 18.06l-6.18 3.26L7 14.14 2 9.27l6.91-1.01L12 2z"
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
