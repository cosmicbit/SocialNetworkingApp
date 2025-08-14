//
//  SelfieRetakeViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 11/08/25.
//

import UIKit
import AVFoundation

enum Filters: Int, CaseIterable{
    case specs = 0, hearts, mustache
    
    mutating func toNextState(){
        self = self.nextFilter
    }
    
    var nextFilter: Filters{
        guard let filter = Filters(rawValue: (self.rawValue + 1) % Filters.allCases.count) else { return .specs}
        return filter
    }
    
    func getImage() -> UIImage?{
        switch self {
        case .specs:
            UIImage(named: "spectacles")
        case .hearts:
            UIImage(named: "hearts")
        case .mustache:
            UIImage(named: "mustache")
        }
    }
}

protocol SelfieRetakeDelegate: AnyObject{
    func didTapOnBackgroundButton()
    func didFinishCapture(withCombinedShot snapshot: UIImage, withCapturedImage image: UIImage, withFilter filter : Filters)
}

class SelfieRetakeViewController: UIViewController {
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    weak var delegate: SelfieRetakeDelegate?
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cameraView: OvalView = {
        let view = OvalView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var filterImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let backgroundButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SELFIE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 10)
        
        return button
    }()
    
    let captureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentFilterImage: UIImage?{
        didSet{
            filterImageView.image = currentFilterImage
        }
    }
    private var filterImages = [
        UIImage(named: "spectacles"),
        UIImage(named: "hearts"),
        UIImage(named: "mustache")
    ]
    var currentFilter = Filters.mustache{
        didSet{
            changeFilterImage()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        currentFilter = .hearts
        containerView.addSubview(cameraView)
        containerView.addSubview(filterImageView)
        captureButton.backgroundColor = .white
        backgroundButton.backgroundColor = .black.withAlphaComponent(0.25)
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 100),
            cameraView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cameraView.widthAnchor.constraint(equalToConstant: 200),
            cameraView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 100),
            cameraView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -100),
            cameraView.heightAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 1.25),
            cameraView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -100),
            filterImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            filterImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            filterImageView.heightAnchor.constraint(equalTo: cameraView.heightAnchor, multiplier: 1.25),
            filterImageView.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 1.25),
        ])
        view.addSubview(cancelButton)
        view.addSubview(backgroundButton)
        view.addSubview(containerView)
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            backgroundButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backgroundButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundButton.heightAnchor.constraint(equalToConstant: 25),
            backgroundButton.widthAnchor.constraint(equalToConstant: 60),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.heightAnchor.constraint(equalToConstant: 60),
            captureButton.widthAnchor.constraint(equalTo: captureButton.heightAnchor, multiplier: 1),
        ])
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        backgroundButton.addTarget(self, action: #selector(backgroundButtonTapped), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        addBackgroundTaps()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.layer.cornerRadius = captureButton.bounds.width / 2
        captureButton.layer.borderColor = UIColor.systemGray5.cgColor
        captureButton.layer.borderWidth = 5
        backgroundButton.layer.cornerRadius = 12
        backgroundButton.layer.borderColor = UIColor.white.cgColor
        backgroundButton.layer.borderWidth = 1
        if let videoPreviewLayer = videoPreviewLayer {
            videoPreviewLayer.frame = cameraView.layer.bounds
        }
    }
    
    @objc func cancelButtonTapped(){
        dismiss(animated: true)
    }
    
    @objc func backgroundButtonTapped(){
        backgroundButton.bounceEffect(withScale: 0.95, withDuration: 0.5)
        dismiss(animated: true){
            self.delegate?.didTapOnBackgroundButton()
        }
    }
    
    @objc func captureButtonTapped(){
        captureButton.bounceEffect(withScale: 0.9, withDuration: 0.5)
        let selfieShot = containerView.asImage()
        let image = cameraView.asImage()
        dismiss(animated: true) {
            self.delegate?.didFinishCapture(withCombinedShot: selfieShot, withCapturedImage: image, withFilter: self.currentFilter)
        }
    }
    
    @objc func handleSingleTap(){
        currentFilter.toNextState()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        guard let frontCamera = discoverySession.devices.first else {
            print("Unable to access the front camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            captureSession.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = cameraView.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer)
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        } catch let error {
            print("Error initializing camera: \(error.localizedDescription)")
        }
    }
    
    private func changeFilterImage(){
        currentFilterImage = filterImages[currentFilter.rawValue]
    }
    
    func addBackgroundTaps(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        view.addGestureRecognizer(singleTap)
    }
}
