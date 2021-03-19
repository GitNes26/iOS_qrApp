//
//  ScannerViewController.swift
//  qrApp
//
//  Created by Mac22 on 19/03/21.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set background-color
        view.backgroundColor = .darkGray
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDecice = AVCaptureDevice.default(for: .video) else {return}
        let videoInput:AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDecice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        //Start capture session
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Not supported", message: "Tu dispositivo no es compatible con esta función", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OKi", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    // si esta correindo y nos salimos, paramos la accion
    override func viewWillDisappear(_ animated: Bool) {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readable = metadataObject as? AVMetadataMachineReadableCodeObject else {return}
            guard let stringValue = readable.stringValue else {return}
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundTextFromQR(stringValue)
        }
    }
    
    func foundTextFromQR(_ stringValue:String) {
        print(stringValue)
        
        if let data = stringValue.data(using: .utf8) {
            do {
                let message:Message = try! JSONDecoder().decode(Message.self, from: data)
                let ac = UIAlertController(title: "Contenido del QR", message: message.token, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                print(message.token)
            }
        } else {
            print("Error de serealización")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
