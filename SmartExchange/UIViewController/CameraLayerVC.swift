//
//  CameraLayerVC.swift
//  InstaCash
//
//  Created by Sameer Khan on 10/09/22.
//  Copyright © 2022 Prakhar Gupta. All rights reserved.
//

import UIKit
import AVFoundation

class CameraLayerVC: UIViewController, AVCapturePhotoCaptureDelegate {

    var isBackClicked = false
    var isFrontClicked = false
    var isBothCameraClicked : (() -> Void)?
    
    var stillImageOutput: AVCapturePhotoOutput!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeImage = UIImage(named: "cross")
        let closeTintedImage = closeImage?.withRenderingMode(.alwaysTemplate)
        self.closeButton.setImage(closeTintedImage, for: .normal)
        self.closeButton.tintColor = .white
        
        
        let captureImage = UIImage(named: "capture_photo")
        let captureTintedImage = captureImage?.withRenderingMode(.alwaysTemplate)
        self.captureButton.setImage(captureTintedImage, for: .normal)
        self.captureButton.tintColor = .white

        self.openCamera()
        
    }
    
    private func openCamera() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // the user has already authorized to access the camera.
            print("the user has already authorized to access the camera.")
            
            DispatchQueue.main.async {
                self.configureBack()
            }
            
            
        case .notDetermined:
            // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    
                    DispatchQueue.main.async {
                        self.configureBack()
                    }
                    
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
            
        case .denied:
            print("the user has denied previously to access the camera.")
            self.handleDismiss()
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.handleDismiss()
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func configureBack() {
        
        let captureSession = AVCaptureSession()
        
        var backFacingCamera: AVCaptureDevice?
        var frontFacingCamera: AVCaptureDevice?
        var currentDevice: AVCaptureDevice!
                
        var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
        
        
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        
        //MARK: 2 Get the front and back-facing camera for taking photos
        let deviceDiscoverySessionWideAngleCamera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        //print("deviceDiscoverySessionWideAngleCamera.devices.count", deviceDiscoverySessionWideAngleCamera.devices.count)
        
        for device in deviceDiscoverySessionWideAngleCamera.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        
        //currentDevice = backFacingCamera
        
        if let backCam = backFacingCamera {
            currentDevice = backCam
        }
        
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            handleDismiss()
            return
        }
        
        
        // Configure the session with the output for capturing still images
        stillImageOutput = AVCapturePhotoOutput()
        
        
        // Configure the session with the input and the output devices
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
        
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        
        // Bring the camera button to front
        view.bringSubview(toFront: overlayView)
        view.bringSubview(toFront: closeButton)
        
        DispatchQueue.global(qos: .background).async {
            // Perform any necessary setup before starting the capture session

            // Call startRunning on the AVCaptureSession instance
            captureSession.startRunning()

            // Perform any additional tasks related to the capture session

            // Update the UI or perform any other UI-related operations on the main thread if needed
            //DispatchQueue.main.async {
                // Update UI or handle any UI-related tasks
            //}
            
        }
    
        
    }
    
    private func configureFront() {
        
        let captureSession = AVCaptureSession()
        
        var backFacingCamera: AVCaptureDevice?
        var frontFacingCamera: AVCaptureDevice?
        var currentDevice: AVCaptureDevice!
                
        var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
        
        
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    
        
        //MARK: 2 Get the front and back-facing camera for taking photos
        let deviceDiscoverySessionWideAngleCamera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        //print("deviceDiscoverySessionWideAngleCamera.devices.count", deviceDiscoverySessionWideAngleCamera.devices.count)
        
        for device in deviceDiscoverySessionWideAngleCamera.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        
        //currentDevice = frontFacingCamera
        
        if let frontCam = frontFacingCamera {
            currentDevice = frontCam
        }
        
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            handleDismiss()
            return
        }
        
        
        // Configure the session with the output for capturing still images
        stillImageOutput = AVCapturePhotoOutput()
        
        
        // Configure the session with the input and the output devices
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
        
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        
        // Bring the camera button to front
        view.bringSubview(toFront: overlayView)
        view.bringSubview(toFront: closeButton)
        
        DispatchQueue.global(qos: .background).async {
            // Perform any necessary setup before starting the capture session

            // Call startRunning on the AVCaptureSession instance
            captureSession.startRunning()

            // Perform any additional tasks related to the capture session

            // Update the UI or perform any other UI-related operations on the main thread if needed
            //DispatchQueue.main.async {
                // Update UI or handle any UI-related tasks
            //}
            
        }
    
        
    }
    
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: IBActions
    @IBAction func cameraDismiss(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func handleTakePhoto(_ sender: UIButton) {
        
        // Set photo settings
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        //photoSettings.isHighResolutionPhotoEnabled = true
        //photoSettings.flashMode = .auto
        
        //stillImageOutput.isHighResolutionCaptureEnabled = true
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    //MARK: AVCapturePhotoOutput Delegate
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCaptureFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("didFinishProcessingPhoto")
        
        guard error == nil else {
            handleDismiss()
            return
        }
        
        if self.isBackClicked {
            self.isFrontClicked = true
        }
                
        self.isBackClicked = true
        
      
        if self.isBackClicked == true && self.isFrontClicked == true {
            
            guard let isBothCameraClicked = self.isBothCameraClicked else { return }
            isBothCameraClicked()
            
        }else {
            
            DispatchQueue.main.async {
                self.configureFront()
            }
            
        }
        
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}




/* MARK: Sam on 26/6/23 due to crashing -> Firebase Crashlytics
class CameraLayerVC: UIViewController, AVCapturePhotoCaptureDelegate {

    var isBackClicked = false
    var isFrontClicked = false
    var isBothCameraClicked : (() -> Void)?
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    
    //private let photoOutput = AVCapturePhotoOutput()
    
    //MARK: 10/10/22
    var cameraLayer : AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    var cameraDevice: AVCaptureDevice?
    var photoOutput : AVCapturePhotoOutput?
    
    var photoSettings : AVCapturePhotoSettings? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeImage = UIImage(named: "cross")
        let closeTintedImage = closeImage?.withRenderingMode(.alwaysTemplate)
        self.closeButton.setImage(closeTintedImage, for: .normal)
        self.closeButton.tintColor = .white
        
        
        let captureImage = UIImage(named: "capture_photo")
        let captureTintedImage = captureImage?.withRenderingMode(.alwaysTemplate)
        self.captureButton.setImage(captureTintedImage, for: .normal)
        self.captureButton.tintColor = .white

        self.openCamera()
        
    }
    
    func startSession() {
        if let videoSession = self.captureSession {
            if !videoSession.isRunning {
                DispatchQueue.global(qos: .background).async {
                    videoSession.startRunning()
                }
            }
        }
    }
    
    func stopSession() {
        if let videoSession = self.captureSession {
            if videoSession.isRunning {
                videoSession.stopRunning()
            }
        }
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            print("the user has already authorized to access the camera.")
            
            DispatchQueue.main.async {
                self.setupCaptureSession()
                self.startSession()
            }
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.startSession()
                    }
                    
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
            
        case .denied:
            print("the user has denied previously to access the camera.")
            self.handleDismiss()
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.handleDismiss()
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {
                
        self.photoOutput = AVCapturePhotoOutput()
        self.captureSession = AVCaptureSession()
        
        //self.captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if ((self.captureSession?.canAddInput(input)) != nil) {
                    self.captureSession?.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if ((self.captureSession?.canAddOutput(self.photoOutput ?? AVCapturePhotoOutput())) != nil) {
                self.captureSession?.addOutput(self.photoOutput ?? AVCapturePhotoOutput())
            }
            
            
            self.cameraLayer = AVCaptureVideoPreviewLayer(session: self.captureSession ?? AVCaptureSession())
            self.cameraLayer?.frame = self.view.frame
            self.cameraLayer?.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.cameraLayer ?? AVCaptureVideoPreviewLayer())
            
            self.view.bringSubview(toFront: self.overlayView)
            self.view.bringSubview(toFront: self.closeButton)
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession?.startRunning()
            }
            //self.setupUI()
        }
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: IBActions
    @IBAction func cameraDismiss(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func handleTakePhoto(_ sender: UIButton) {
        
        /*
        let photoSettings = AVCapturePhotoSettings()
        self.photoOutput?.capturePhoto(with: photoSettings, delegate: self)
        */
        
        self.photoSettings = AVCapturePhotoSettings()
        if let phSetting = self.photoSettings {
            self.photoOutput?.capturePhoto(with: phSetting, delegate: self)
        }
        
        
        /*
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            //photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
        */
        
    }
    
    //MARK: AVCapturePhotoOutput Delegate
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCaptureFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("didFinishProcessingPhoto")
        
        if self.isBackClicked {
            self.isFrontClicked = true
        }
        
        self.photoSettings = nil
        
        self.isBackClicked = true
        
        /*
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        
        let photoPreviewContainer = PhotoPreviewView(frame: self.view.frame)
        photoPreviewContainer.photoImageView.image = previewImage
        self.view.addSubviews(photoPreviewContainer)
        */
        
        //captureSession.stopRunning()
        
        if self.isBackClicked == true && self.isFrontClicked == true {
            
            //DispatchQueue.main.async {
                guard let isBothCameraClicked = self.isBothCameraClicked else { return }
                isBothCameraClicked()
                //self.dismiss(animated: true, completion: nil)
            //}
            
        }else {
                                    
            self.photoOutput = AVCapturePhotoOutput()
            self.captureSession = AVCaptureSession()
            
            //self.captureSession?.sessionPreset = AVCaptureSession.Preset.photo
            
            
            if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                
                do {
                    let input = try AVCaptureDeviceInput(device: captureDevice)
                    if ((self.captureSession?.canAddInput(input)) != nil) {
                        self.captureSession?.addInput(input)
                    }
                } catch let error {
                    print("Failed to set input device with error: \(error)")
                }
                
                /*
                if ((self.captureSession?.canAddOutput(self.photoOutput)) != nil) {
                    self.captureSession?.addOutput(self.photoOutput)
                }
                */
                
                if ((self.captureSession?.canAddOutput(self.photoOutput ?? AVCapturePhotoOutput())) != nil) {
                    self.captureSession?.addOutput(self.photoOutput ?? AVCapturePhotoOutput())
                }
                
                self.cameraLayer = AVCaptureVideoPreviewLayer(session: self.captureSession ?? AVCaptureSession())
                self.cameraLayer?.frame = self.view.frame
                self.cameraLayer?.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(self.cameraLayer ?? AVCaptureVideoPreviewLayer())
                
                self.view.bringSubview(toFront: self.overlayView)
                self.view.bringSubview(toFront: self.closeButton)
                
                DispatchQueue.global(qos: .background).async {
                    self.captureSession?.startRunning()
                }
                //self.setupUI()
            }
            
        }
        
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
*/
