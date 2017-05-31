//
//  ViewController.swift
//  voiceRecordingExample
//

import UIKit
import AVFoundation

// unused
enum EncryptionError:Error {
    case Empty
    case Short
}

class ViewController: UIViewController,AVAudioRecorderDelegate {
    
    // MARK: - outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // members
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var audioRecordingFile:String! = "audioRecording.caf"
    
    // MARK: - dids
    override func viewDidLoad() {
        super.viewDidLoad()
        disableButton(button:self.playButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // disable button
    func disableButton(button:UIButton){
        button.isEnabled = false
    }
    
    
    // MARK - Record/Play methods
    private func record(){
        
        if((self.audioPlayer != nil) && self.audioPlayer.isPlaying){
            self.audioPlayer.stop()
            self.audioPlayer = nil
        }
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission{
            
            (hasPermission) -> Void in
            
            guard hasPermission else {
                
                print("permission not granted")
                
                self.recordButton.setTitle("Record",for:UIControlState.normal)
                return
                
            }
            
            do{
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
            }catch{
                print(error)
            }
            
            // directory docs
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            let fullPath = (documentsDirectory as NSString).appendingPathComponent(self.audioRecordingFile)
            let url = NSURL.fileURL(withPath: fullPath)
            
            let settings = [
                AVFormatIDKey:Int(kAudioFormatAppleIMA4),
                AVSampleRateKey:44100.0,
                AVNumberOfChannelsKey:2,
                AVEncoderBitRateKey:12800,
                AVLinearPCMBitDepthKey:16,
                AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue
            ] as [String : Any]
            
            // record
            do
            {
                self.audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                self.audioRecorder?.record()
            }catch let error as NSError{
                print(error)
            }
        }
        
    }
    
    private func play(){
        
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError
        {
            print(error)
        }
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fullPath = (documentsDirectory as NSString).appendingPathComponent(self.audioRecordingFile)
        
        let url = NSURL.fileURL(withPath: fullPath)
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    // MARK: - Button actions
    @IBAction func onRecordButtonTapped(_ sender: UIButton) {
        
        if(sender.currentTitle=="Stop"){
            self.audioRecorder.stop()
            self.audioRecorder = nil
            sender.setTitle("Record",for:UIControlState.normal)
            self.playButton.isEnabled = true
        }else{
            self.record()
            sender.setTitle("Stop",for:UIControlState.normal)
            self.disableButton(button: self.playButton)
        }
        
    }
    
    @IBAction func onPlayButtonTapped(_ sender: Any) {
        disableButton(button:self.playButton)
        self.play()
    }
    
    // MARK: - unused utils
    func writeFile(){
        
        let str = "a b c d"
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fullPath = (documentsDirectory as NSString).appendingPathComponent("text.txt")
        
        do {
            
            try str.write(toFile: fullPath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            
            print("not saved")
            
        }
    }
    
    func listFiles() {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let manager = FileManager.default
        do{
            let allItems = try manager.contentsOfDirectory(atPath: documentDirectory)
            print(allItems)
        }catch let error{
            print(error.localizedDescription)
        }
        
        
    }
    
}
