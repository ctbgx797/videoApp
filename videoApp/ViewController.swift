//
//  ViewController.swift
//  videoApp
//
//  Created by 西谷恭紀 on 2019/06/16.
//  Copyright © 2019 西谷恭紀. All rights reserved.
//  アプリ ID  ca-app-pub-8492943857167230~6771649760
//  広告ユニットID ca-app-pub-8492943857167230/6416426544


import UIKit
import AVFoundation  // <-追加
import Photos       // <-追加
import GoogleMobileAds

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    //設定に必要なもの
    //    設定に使用
    var captureSession = AVCaptureSession()
    
    //    カメラ設定に使用
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice? //今現在のカメラの向きはどっちか
    
    //    オーディオ設定に使用
    var audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    
    //    ファイルの管理に使用
    var videoFileOutput:AVCaptureMovieFileOutput?
    
    //    プレビューに使用
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    //    ボタンを押した時に使用
    var isRecording = false
    
    @IBOutlet weak var bannerView: GADBannerView!  //<-追加

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        setupRunningCaptureSession()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"    //<-追加
        bannerView.rootViewController = self   //<-追加
        bannerView.load(GADRequest())   //<-追加

        
    }
    
    //    録画完了時に自動的に呼ばれる・AVCaptureFileOutputRecordingDelegate が実装を必須にしているモノ
    //    フォトライブラリーに保存
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { (completed, error) in
            if completed{
                print("保存したよ！")
            }
        }
    }
    
    
    
    /*
     カメラタイプをwideanglecamera
     メディアタイプをビデオ
     ポジション指定はなし
     */
    
    //カメラの基本設定
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        //今回はバックカメラのみなのでこんな感じ
        for device in devices {
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    //    キャプチャの品質レベルの設定
    func setupCaptureSession(){
        //    高品質のビデオおよびオーディオ出力
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }
    //出入力
    func setupInputOutput(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            captureSession.addInput(audioInput)
            
            videoFileOutput = AVCaptureMovieFileOutput()
            captureSession.addOutput(videoFileOutput!)
        } catch {
            print(error)
        }
    }
    //表示
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    //一覧
    func setupRunningCaptureSession(){
        captureSession.startRunning()
    }
    @IBOutlet var recordButton: UIButton!
    
    @IBAction func captureAction(_ sender: UIButton) {
        
        if !isRecording{
            isRecording = true
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat,.autoreverse, .allowUserInteraction], animations: { () -> Void in
                self.recordButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: nil)
            
            let outputPath = NSTemporaryDirectory() + "output.mp4"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
            
        } else {
            isRecording = false
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: { () -> Void in
                self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
            
            recordButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
            
            let title = "動画が保存されました"
            let message = "ふぁっ!!!"
            let okText = "OK"
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okayButton = UIAlertAction(title: okText, style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okayButton)
            
            present(alert, animated: true, completion: nil)
            
        }
    }
}






