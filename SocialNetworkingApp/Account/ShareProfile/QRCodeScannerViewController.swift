//
//  QRCodeScannerViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 13/08/25.
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {

    // MARK: - Properties
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let coverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PinkToPurple1")?.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // A view to highlight the detected QR code.
    private let qrCodeFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.layer.bounds
        qrCodeFrameView.layer.frame = CGRect(x: view.bounds.midX - 150, y: view.bounds.midY - 150, width: 300, height: 300)
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(qrCodeFrameView)
        view.addSubview(coverView)
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            coverView.topAnchor.constraint(equalTo: view.topAnchor),
            coverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coverView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        print(view.bounds)
        qrCodeFrameView.frame = CGRect(x: view.bounds.midX - 150, y: view.bounds.midY - 150, width: 300, height: 300)
        qrCodeFrameView.layer.addCornerOverlay(withWidth: 5, withColor: .white, withLength: 30, isRounded: true)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func backButtonTapped(_ sender: Any){
        dismiss(animated: true)
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if granted {
                        self.configureCaptureSession()
                    } else {
                        self.handlePermissionDenied()
                    }
                }
            }
        case .denied, .restricted:
            handlePermissionDenied()
        @unknown default:
            handlePermissionDenied()
        }
    }
    
    private func configureCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device.")
            return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input: \(error)")
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add video input to the session.")
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output to the session.")
            return
        }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        view.bringSubviewToFront(coverView)
        view.bringSubviewToFront(qrCodeFrameView)
        view.bringSubviewToFront(backButton)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    private func handlePermissionDenied() {
        showToast(message: "Camera permission denied. Please enable it in Settings.")
        dismiss(animated: true)
    }
    
    private func highlightQRCode(_ metadataObject: AVMetadataMachineReadableCodeObject) {
        if let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject) {
            qrCodeFrameView.frame = barCodeObject.bounds
        }
    }
    
    private func removeHighlight() {
        
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            highlightQRCode(readableObject)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("QR Code Scanned: \(stringValue)")
        } else {
            removeHighlight()
        }
    }
}
