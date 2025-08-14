//
//  ShareViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//

import UIKit
import CoreImage
import Photos


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
    
    var tintColor: UIColor{
        switch self {
        case .color, .image:
            return .white
        case .emoji, .selfie:
            return .black
        }
    }
}

class ShareViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var qrCodeScannerButton: UIButton!
    @IBOutlet weak var qrCodeContainerView: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var functionsContainerView: UIView!
    @IBOutlet weak var shareProfileButton: UIButton!
    @IBOutlet weak var copyLinkButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var customizeImageButton: UIButton!
    
    var userProfile: UserProfile!
    
    private let gradientLayer = CAGradientLayer()
    private var includeBackground: Bool = false
    private var degreeIndex: Int = 0
    var profileURL: URL?
    var webURL: URL?
    var qrCodeImage: UIImage?{
        didSet{
            qrCodeImageView.image = qrCodeImage
        }
    }
    
    private var currentBackgroundState: ShareBackgroundState = .color {
        didSet{
            print("currentBackgroundState changed from ", oldValue, " to ", currentBackgroundState)
            changeBackgroundButtonTitle()
            changeBackground()
            changeQRCodeColor()
            changeUIAppearance()
        }
    }
    
    private let emojiPickerVC: EmojiPickerViewController = {
        let view = EmojiPickerViewController()
        return view
    }()
    
    private var backgroundViews: [UIView] = []
    private var currentBackgroundView: UIView = UIView()
    
    lazy var permanentProfileURL: String = {
        guard let userId = userProfile.id else {return ""}
        let username = userProfile.username
        let baseURL = "https://www.socialnetworkingapp.com/"
        let urlString = baseURL + username + "/" + userId
        return urlString
    }()
    
    lazy var qrCodeImageWithBackground: UIImage = {
        let qrCodeImageWidth = qrCodeContainerView.bounds.width
        let qrCodeImage = qrCodeContainerView.asImage()
        let containerWidth = currentBackgroundView.bounds.width
        let containerHeight = containerWidth * 1.4
        let containerRect = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight) // altering the container into a square
        let containerImage = currentBackgroundView.asImage(ofBounds: containerRect)
        let overlayXPos = containerWidth/2 - qrCodeImageWidth/2 // placing the position of the overlay at center of the container
        let overlayYPos = containerHeight/2 - qrCodeImageWidth/2 // since the overlay has to be square
        let overlayRect = CGRect(x: overlayXPos, y: overlayYPos, width: qrCodeImageWidth, height: qrCodeImageWidth)
        let combinedImage = containerImage.overlayWith(overlayImage: qrCodeImage, in: overlayRect)
        return combinedImage
    }()
    
    lazy var qrCodeImageWithoutBackground: UIImage = {
        let qrCodeImageWidth = qrCodeContainerView.bounds.width
        let qrCodeImage = qrCodeContainerView.asImage()
        let containerWidth = currentBackgroundView.bounds.width
        let containerHeight = containerWidth * 1.4
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
        containerView.backgroundColor = .black
        let containerImage = containerView.asImage()
        let overlayXPos = containerWidth/2 - qrCodeImageWidth/2 // placing the position of the overlay at center of the container
        let overlayYPos = containerHeight/2 - qrCodeImageWidth/2 // since the overlay has to be square
        let overlayRect = CGRect(x: overlayXPos, y: overlayYPos, width: qrCodeImageWidth, height: qrCodeImageWidth)
        let combinedImage = containerImage.overlayWith(overlayImage: qrCodeImage, in: overlayRect)
        return combinedImage
    }()
    
    func changeBackgroundButtonTitle(withColor strokeColor: UIColor = .black){
        var config = backgroundButton.configuration ?? UIButton.Configuration.plain()
        var newTitle = AttributedString(currentBackgroundState.description.uppercased())
        newTitle.font = .boldSystemFont(ofSize: 10)
        config.attributedTitle = newTitle
        config.baseForegroundColor = strokeColor
        backgroundButton.configuration = config
    }
    
    func changeBackground(){
        currentBackgroundView.removeFromSuperview()
        currentBackgroundView = backgroundViews[currentBackgroundState.rawValue]
        view.insertSubview(currentBackgroundView, at: 0)
    }
    
    func changeQRCodeColor(){
        switch currentBackgroundState {
        case .color:
            let view = currentBackgroundView as! ColorShareView
            qrCodeImage = permanentProfileURL.generateGradientQRCode(
                colors: view.currentGradient.uiColors,
                startPoint: view.currentGradient.startPoint,
                endPoint: view.currentGradient.endPoint)
        case .emoji:
            let view = currentBackgroundView as! EmojiShareView
            if let emojiImage = view.currentEmoji.image(),
                let dominantColor = emojiImage.dominantColor() {
                qrCodeImage = permanentProfileURL.generateQRCode(withColor: dominantColor)
            }
        case .selfie:
            qrCodeImage = permanentProfileURL.generateQRCode(withColor: .black)
        case .image:
            qrCodeImage = permanentProfileURL.generateQRCode(withColor: .black)
        }
    }
    
    func changeUIAppearance(){
        let color = currentBackgroundState.tintColor
        closeButton.tintColor = color
        changeBackgroundButtonTitle(withColor: color)
        qrCodeScannerButton.tintColor = color
        customizeImageButton.tintColor = color
        switch currentBackgroundState {
        case .color:
            customizeImageButton.isHidden = true
            gradientLayer.isHidden = true
            retakeButton.isHidden = true
            backgroundButton.backgroundColor = .black.withAlphaComponent(0.25)
        case .emoji:
            customizeImageButton.isHidden = true
            gradientLayer.isHidden = true
            retakeButton.isHidden = true
            backgroundButton.backgroundColor = .white
        case .selfie:
            customizeImageButton.isHidden = true
            gradientLayer.isHidden = true
            retakeButton.isHidden = false
            backgroundButton.backgroundColor = .white
        case .image:
            customizeImageButton.isHidden = false
            gradientLayer.isHidden = false
            retakeButton.isHidden = true
            backgroundButton.backgroundColor = .black.withAlphaComponent(0.25)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        generateRequiredProperties()
        setupView()
        setupGradientLayer()
        setupUserProfile()
        addBackgroundTaps()
        emojiPickerVC.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = self.view.bounds
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
        backgroundButton.layer.borderWidth = 1
        backgroundButton.layer.borderColor = currentBackgroundState.tintColor.cgColor
    }
    
    func setupView(){
        setupBackgroundViews()
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
    
    func setupGradientLayer(){
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        let clearColor = UIColor.clear.cgColor
        let blackColor = UIColor.black.withAlphaComponent(0.5).cgColor
        gradientLayer.colors = [blackColor, clearColor, clearColor, blackColor]
        gradientLayer.locations = [0.0, 0.2, 0.8, 1.0]
    }
    
    
    func setupBackgroundViews(){
        let colorView = ColorShareView(frame: view.bounds)
        colorView.currentGradient = GradientPreset.greenToBlue
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
        self.qrCodeImage = permanentProfileURL.generateQRCode()
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
            view.changeColorGradient()
            changeQRCodeColor()
        case .emoji:
            if let vc = self.presentedViewController{
                vc.dismiss(animated: true)
            }else{
                showEmojiPicker()
            }
        case .selfie:
            let view = currentBackgroundView as! SelfieShareView
            view.changeFilter()
        default:
            print()
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any){
        dismiss(animated: true)
    }
    
    @IBAction func backgroundButtonTapped(_ sender: Any){
        backgroundButton.bounceEffect(withScale: 0.95, withDuration: 0.5)
        currentBackgroundState.toNextState()
    }
    
    @IBAction func qrCodeScannerButtonTapped(_ sender: Any){
        let qrScanVC = QRCodeScannerViewController()
        qrScanVC.modalPresentationStyle = .overFullScreen
        qrScanVC.modalTransitionStyle = .crossDissolve
        present(qrScanVC, animated: true)
    }
    
    @IBAction func shareProfileButtonTapped(_ sender: Any){
        let imageToShare = qrCodeImageWithBackground
        let items: [Any] = [permanentProfileURL, imageToShare]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func copyLinkButtonTapped(_ sender: Any){
        UIPasteboard.general.string = permanentProfileURL
        showToast(message: "Link copied")
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any){
        let downloadVC = OptionsViewController(title: "Download", options: [
            "Include background",
            "Save image",
            "Download as PDF"
        ])
        downloadVC.delegate = self
        if let sheet = downloadVC.sheetPresentationController{
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("small")) { context in
                return 220
            }
            sheet.detents = [customDetent]
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = true
        }
        present(downloadVC, animated: true)
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any){
        let vc = SelfieRetakeViewController()
        vc.delegate = self
        let view = currentBackgroundView as! SelfieShareView
        vc.currentFilter = view.currentFilter
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
    private func generateQRCode(from string: String, withColor color: UIColor = .black) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        guard let ciImage = qrFilter.outputImage else {
            return nil
        }
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(ciImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(color: color), forKey: "inputColor0") // The foreground color
        colorFilter?.setValue(CIColor(color: UIColor.clear), forKey: "inputColor1") // The background color
        guard let outputImage = colorFilter?.outputImage else { return nil }
        let scaleX = 200 / outputImage.extent.size.width
        let scaleY = 200 / outputImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = outputImage.transformed(by: transform)
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
        if currentBackgroundState == .emoji{
            let emoji = this as! String
            let view = currentBackgroundView as! EmojiShareView
            view.changeCurrentEmoji(with: emoji)
            changeQRCodeColor()
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
        let degrees:[CGFloat] = [45, -45]
        
        switch currentBackgroundState {
        case .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            let view = currentBackgroundView as! EmojiShareView
            if (row % 2 == 0 && column % 2 == 0) || (row % 2 != 0 && column % 2 != 0) {
                cell.label.text = view.currentEmoji
                let degree = degrees[degreeIndex]
                degreeIndex = (degreeIndex + 1) % 2
                cell.label.rotate(by: degree)
            }
            else{
                cell.label.text = " "
            }
            return cell
        case .selfie:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelfieCell.identifier, for: indexPath) as! SelfieCell
            let view = currentBackgroundView as! SelfieShareView
            if (row % 2 == 0 && column % 2 == 0) || (row % 2 != 0 && column % 2 != 0) {
                cell.imageView.image = view.currentSelfieWithFilter
                let degree = degrees[degreeIndex]
                degreeIndex = (degreeIndex + 1) % 2
                cell.imageView.rotate(by: degree)
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

//MARK: - UICollectionViewDelegateFlowLayout
extension ShareViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerScreen: CGFloat = 9
        let spacing: CGFloat = 10
        let itemHeight = (collectionView.bounds.height - (itemsPerScreen - 1) * spacing) / itemsPerScreen
        return CGSize(width: itemHeight, height: itemHeight)
    }
}

//MARK: - SelfieRetakeDelegate
extension ShareViewController: SelfieRetakeDelegate{
    func didFinishCapture(withCombinedShot snapshot: UIImage, withCapturedImage image: UIImage, withFilter filter : Filters) {
        if currentBackgroundState == .selfie{
            let view = currentBackgroundView as! SelfieShareView
            view.changeCurrentSelfie(with: image, withFilter: filter)
        }
    }
    
    func didTapOnBackgroundButton() {
        currentBackgroundState.toNextState()
    }
}

//MARK: - OptionsViewControllerDelegate
extension ShareViewController: OptionsViewControllerDelegate{
    
    func optionsViewController(_ controller: OptionsViewController, didSelectOption option: String) {
        if controller.titleLabel.text == "Options"{
            controller.dismiss(animated: true){
                switch option {
                case "Change Background":
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary // Specify the source as the photo library
                    
                    self.present(imagePicker, animated: true, completion: nil)
                case "Blur":
                    if self.currentBackgroundState == .image{
                        let view = self.currentBackgroundView as! ImageShareView
                        view.isBlurred.toggle()
                    }
                default:
                    break
                }
            }
        }else if controller.titleLabel.text == "Download"{
            switch option{
            case "Include background":
                includeBackground.toggle()
            case "Save image":
                controller.dismiss(animated: true){
                    let imageToSave = self.includeBackground ? self.qrCodeImageWithBackground : self.qrCodeImageWithoutBackground
                    UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(self.handleSaveImageToAlbum(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            case "Download as PDF":
                controller.dismiss(animated: true){
                    let imageToSave = self.includeBackground ? self.qrCodeImageWithBackground : self.qrCodeImageWithoutBackground
                    guard let pdfData = imageToSave.pdfData() else {
                        print("Failed to generate PDF data.")
                        self.showToast(message: "Failed to generate PDF")
                        return
                    }
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("qrcode_\(Int.random(in: 1...1_000_000))")
                        .appendingPathExtension("pdf")
                    do {
                        try pdfData.write(to: tempURL)
                        print("PDF saved temporarily to: \(tempURL.path)")
                        let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                        activityViewController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
                            if completed {
                                if let activity = activityType {
                                    print("Activity completed: \(activity.rawValue)")
                                }
                                self.showToast(message: "Saved")
                            }
                        }
                        self.present(activityViewController, animated: true, completion: nil)
                        
                    } catch {
                        print("Error saving PDF: \(error.localizedDescription)")
                        self.showToast(message: "Failed to save PDF")
                    }
                }
            default:
                break
            }
        }
    }
    
    @objc func handleSaveImageToAlbum(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
            showToast(message: "Failed to save")
        } else {
            print("Image saved successfully!")
            showToast(message: "Saved")
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ShareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true){
            if let selectedImage = info[.originalImage] as? UIImage {
                if self.currentBackgroundState == .image{
                    let view = self.currentBackgroundView as! ImageShareView
                    view.changeBackgroundImage(with: selectedImage)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
