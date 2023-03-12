//
//  ViewController.swift
//  MAPD724-W2023-ICE6
//
//  Created by Po Lam Wong on 12/3/2023.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btn_takePicture: UIButton!
    @IBOutlet weak var btn_fromLibrary: UIButton!
    
    @objc var avPlayerViewController: AVPlayerViewController!
    @objc var image: UIImage?
    @objc var movieURL: URL?
    @objc var lastChosenMediaType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if (!UIImagePickerController.isSourceTypeAvailable(.camera)) {
                    btn_takePicture.isHidden = true
                }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDisplay()
    }
    
    @IBAction func takePhotoOrVideo(_ sender: Any) {
        pickMediaFromSource(.camera)
    }
    
    @IBAction func pickFromLibrary(_ sender: Any) {
        pickMediaFromSource(.photoLibrary)
    }
    
    @objc func updateDisplay()
    {
        if let mediaType = lastChosenMediaType
        {
            if mediaType == UTType.image.identifier
            {
                imageView.image = image!
                imageView.isHidden = false
                if avPlayerViewController != nil
                {
                    avPlayerViewController!.view.isHidden = true
                }
            }
            else if mediaType == UTType.movie.identifier
            {
                if avPlayerViewController == nil
                {
                    avPlayerViewController = AVPlayerViewController()
                    let avPlayerView = avPlayerViewController!.view
                    avPlayerView?.frame = imageView.frame
                    avPlayerView?.clipsToBounds = true
                    view.addSubview(avPlayerView!)
                    setAVPlayerViewLayoutConstraints()
                }
                if let url = movieURL
                {
                    imageView.isHidden = true
                    avPlayerViewController.player = AVPlayer(url: url)
                    avPlayerViewController!.view.isHidden = false
                    avPlayerViewController!.player!.play()
                }
            }
        }
    }
    
    @objc func setAVPlayerViewLayoutConstraints() {
            let avPlayerView = avPlayerViewController!.view
            avPlayerView?.translatesAutoresizingMaskIntoConstraints = false
            let views = ["avPlayerView": avPlayerView!,
                            "btn_takePicture": btn_takePicture!]
            view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[avPlayerView]|", options: .alignAllLeft,
                            metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "V:|[avPlayerView]-0-[takePictureButton]",
                            options: .alignAllLeft, metrics:nil, views:views))
        }
    
    @objc func pickMediaFromSource(_ sourceType:UIImagePickerController.SourceType) {
            let mediaTypes =
                  UIImagePickerController.availableMediaTypes(for: sourceType)!
            if UIImagePickerController.isSourceTypeAvailable(sourceType)
                        && mediaTypes.count > 0 {
                let picker = UIImagePickerController()
                picker.mediaTypes = mediaTypes
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = sourceType
                present(picker, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title:"Error accessing media",
                                message: "Unsupported media source.",
                                                        preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK",
                                             style: UIAlertAction.Style.cancel, handler: nil)
                                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        lastChosenMediaType = info[UIImagePickerController.InfoKey.mediaType] as? String
        if let mediaType = lastChosenMediaType
        {
            if mediaType == UTType.image.identifier
            {
                image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            }
            else if mediaType == UTType.movie.identifier
            {
                movieURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            }
        }
        picker.dismiss(animated: true, completion: updateDisplay)
    }
}

