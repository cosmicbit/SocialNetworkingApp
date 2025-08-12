//
//  ShareViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//

import UIKit
import CoreImage


enum ShareBackgroundState: Int, CaseIterable, CustomStringConvertible{
    
    case color = 0, emoji, selfie, image
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
        case .emoji:
            return "emoji"
        case .selfie:
            return "selfie"
        case .image:
            return "image"
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
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var customizeImageButton: UIButton!
    
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
            print("currentBackgroundState changed from ", oldValue, " to ", currentBackgroundState)
            changeBackgroundButtonTitle()
            changeBackground()
            changeRetakeButtonVisibility()
            changeCustomizeImageButtonVisibility()
        }
    }
    
    private let emojiPickerVC: EmojiPickerViewController = {
        let view = EmojiPickerViewController()
        return view
    }()
    
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
    
    func changeRetakeButtonVisibility(){
        switch currentBackgroundState {
        case .color:
            retakeButton.isHidden = true
        case .emoji:
            retakeButton.isHidden = true
        case .selfie:
            retakeButton.isHidden = false
        case .image:
            retakeButton.isHidden = true
        }
    }
    
    func changeCustomizeImageButtonVisibility(){
        switch currentBackgroundState {
        case .color:
            customizeImageButton.isHidden = true
        case .emoji:
            customizeImageButton.isHidden = true
        case .selfie:
            customizeImageButton.isHidden = true
        case .image:
            customizeImageButton.isHidden = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUserProfile()
        addBackgroundTaps()
        emojiPickerVC.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        qrCodeContainerView.layer.cornerRadius = 12
        qrCodeContainerView.layer.shadowColor = UIColor.black.cgColor
        qrCodeContainerView.layer.shadowOpacity = 0.5
        qrCodeContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        qrCodeContainerView.layer.shadowRadius = 4
        functionsContainerView.layer.cornerRadius = 12
        functionsContainerView.layer.shadowColor = UIColor.black.cgColor
        functionsContainerView.layer.shadowOpacity = 0.5
        functionsContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        functionsContainerView.layer.shadowRadius = 4
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
        emojiView.backgroundColor = .white
        emojiView.collectionView.dataSource = self
        emojiView.collectionView.delegate = self
        backgroundViews.append(emojiView)
        let selfieView = SelfieShareView(frame: view.bounds)
        selfieView.backgroundColor = .white
        selfieView.collectionView.dataSource = self
        selfieView.collectionView.delegate = self
        backgroundViews.append(selfieView)
        let imageView = ImageShareView(frame: view.bounds)
        imageView.backgroundColor = .white
        backgroundViews.append(imageView)
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
    
    func showEmojiPicker(){
        emojiPickerVC.modalPresentationStyle = .pageSheet
        if let sheet = emojiPickerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .large
        }
        present(emojiPickerVC, animated: true, completion: nil)
    }
    
    @objc func handleSingleTap(){
        switch currentBackgroundState {
        case .color:
            let view = currentBackgroundView as! ColorShareView
            view.currentColor.toNextColor()
        case .emoji:
            if let vc = self.presentedViewController{
                vc.dismiss(animated: true)
            }else{
                showEmojiPicker()
            }
        default:
            print()
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any){
        dismiss(animated: true)
    }
    
    @IBAction func backgroundButtonTapped(_ sender: Any){
        print("backgroundButton Tapped")
        backgroundButton.bounceEffect(withScale: 0.95, withDuration: 0.5)
        currentBackgroundState.toNextState()
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
    
    @IBAction func retakeButtonTapped(_ sender: Any){
        let vc = SelfieRetakeViewController()
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @IBAction func customizeImageButtonTapped(_ sender: Any){
        let optionsVC = OptionsViewController(title: "Options", options: ["Change Background", "Blur"])
        optionsVC.delegate = self
        if let sheet = optionsVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("small")) { context in
                return 180
            }
            sheet.detents = [customDetent]
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = true
        }
        present(optionsVC, animated: true, completion: nil)
    }
}

// MARK: - QR Code Generation
extension ShareViewController{
    // A helper method to generate a QR code image from a given string.
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        guard let ciImage = qrFilter.outputImage else {
            return nil
        }
        let scaleX = 200 / ciImage.extent.size.width
        let scaleY = 200 / ciImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = ciImage.transformed(by: transform)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

//MARK: - Picker Delegate
extension ShareViewController: PickerDelegate{
    func didSelect(this: Any) {
        switch currentBackgroundState {
        case .emoji:
            let emoji = this as! String
            let view = currentBackgroundView as! EmojiShareView
            view.changeCurrentEmoji(with: emoji)
        default:
            print()
            
        }
        
    }
}

//MARK: - UICollectionViewDataSource
extension ShareViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentBackgroundState {
        case .emoji, .selfie:
            return 1000
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemsPerColumn = 9
        let row = indexPath.item % itemsPerColumn
        let column = indexPath.item / itemsPerColumn
        let degrees:[CGFloat] = [45, 0, -45]
        switch currentBackgroundState {
        case .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            let view = currentBackgroundView as! EmojiShareView
            if (row % 2 == 0 && column % 2 == 0) || (row % 2 != 0 && column % 2 != 0) {
                cell.label.text = view.currentEmoji
                if let randomDegree = degrees.randomElement(){
                    cell.label.rotate(by: randomDegree)
                }
            }
            else{
                cell.label.text = " "
            }
            
            return cell
        case .selfie:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelfieCell.identifier, for: indexPath) as! SelfieCell
            let view = currentBackgroundView as! SelfieShareView
            if (row % 2 == 0 && column % 2 == 0) || (row % 2 != 0 && column % 2 != 0) {
                cell.imageView.image = view.currentSelfie
                if let randomDegree = degrees.randomElement(){
                    cell.imageView.rotate(by: randomDegree)
                }
                
            }
            else{
                cell.imageView.image = UIImage()
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension ShareViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerScreen: CGFloat = 9 // This value is the key! It makes 3.5 cells visible.
        let spacing: CGFloat = 10
        
        // Calculate the item width based on how many you want to see on screen at once
        let itemHeight = (collectionView.bounds.height - (itemsPerScreen - 1) * spacing) / itemsPerScreen
        return CGSize(width: itemHeight, height: itemHeight)
    }
}

extension ShareViewController: SelfieRetakeDelegate{
    func didTapOnBackgroundButton() {
        currentBackgroundState.toNextState()
    }
    
    func didFinishCapture(withShot snapshot: UIImage) {
        
        if currentBackgroundState == .selfie{
            let view = currentBackgroundView as! SelfieShareView
            view.changeCurrentSelfie(with: snapshot)
        }
    }
}

extension ShareViewController: OptionsViewControllerDelegate{
    func optionsViewController(_ controller: OptionsViewController, didSelectOption option: String) {
        switch option {
            case "Change Background":
                print("Change Background")
            case "Blur":
                print("Blur")
            default:
                break
            }
    }
}

extension UIImagePickerControllerDelegate{
    
}
