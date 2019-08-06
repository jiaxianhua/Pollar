//
//  MainViewController.swift
//  Polarr
//
//  Created by developer on 8/5/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit
import MetalKit
import AVFoundation
import Photos

class MainViewController: UIViewController {

    // MARK: IBOutlet
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet var contrastSlider: UISlider!
    @IBOutlet var saturationSlider: UISlider!
    @IBOutlet var brightnessSlider: UISlider!
    @IBOutlet var metalView: MTKView!

    // MARK: Property
    private var cameraController: CameraController?
    private var metalController: MetalController?
    private var recordingController: RecordingController?

    private let contrastFilter = ContrastFilter()
    private let saturationFilter = SaturationFilter()
    private let brightnessFilter = BrightnessFilter()
    private var pipeline: FilteringPipeline!

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        contrastSlider.value = contrastFilter.contrast
        saturationSlider.value = saturationFilter.saturation
        brightnessSlider.value = brightnessFilter.brightness

        // Setup the controllers
        metalController = MetalController()
        cameraController = CameraController()
        metalController?.view = metalView

        // Add filters to pipline
        pipeline = FilteringPipeline(contrastFilter, saturationFilter, brightnessFilter)
        metalController?.filteringPipeline = pipeline

        // chain the controllers
        cameraController?.output = metalController?.input
        _ = cameraController?.start()
    }


    // MARK: Actions
    @IBAction func contrastValueChanged(_ slider: UISlider) {
        contrastFilter.contrast = slider.value
    }

    @IBAction func saturationValueChanged(_ slider: UISlider) {
        saturationFilter.saturation = slider.value
    }

    @IBAction func brightnessValueChanged(_ slider: UISlider) {
        brightnessFilter.brightness = slider.value
    }

    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        if let recorder = recordingController {
            recorder.stopRecording { [weak self] (url) in
                self?.recordingController = nil

                self?.checkLibraryAuth { (allowed) in
                    guard allowed else {
                        return
                    }

                    sender.isSelected = !sender.isSelected
                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(MainViewController.video(_: didFinishSavingWithError: contextInfo:)), nil)
                }
            }

        } else {
            if let recorder = RecordingController() {
                self.recordingController = recorder
                metalController?.output = recorder.input
                recorder.startRecording()
                sender.isSelected = !sender.isSelected
            }
        }
    }

    // MARK: Callbacks
    @objc func video(_ videoPath: NSString?, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let alertController = UIAlertController(title: "Saved!", message: "Your video has been saved to iOS Photo Library", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))

        present(alertController, animated: true)
    }

    // MARK: Private
    private func checkLibraryAuth(completion: @escaping ((_ authorized: Bool) -> Void)) {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completion(true)
            return
        }

        guard PHPhotoLibrary.authorizationStatus() != .denied else {
            completion(false)
            return
        }

        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        })
    }
}

