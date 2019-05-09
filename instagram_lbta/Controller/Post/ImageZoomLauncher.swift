//
//  ImageZoomLauncher.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 6.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

class ImageZoomLauncher: NSObject {
    
    let blackView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    var originalImageView: UIImageView
    
    let zoomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var originalImage: UIImage
    
    init(imageView: UIImageView) {
        originalImageView = imageView
        originalImage = originalImageView.image!
    }
    
    func handleImageZoom(sender: UIPinchGestureRecognizer) {
        
        if sender.state == .began {
            if let keyWindow = UIApplication.shared.keyWindow {
                
                blackView.frame = keyWindow.frame
                blackView.alpha = 0.25
                
                guard let imageView = sender.view as? UIImageView, let image = imageView.image else { return }
                
                let globalFrame = imageView.convert(imageView.frame, to: keyWindow)
                
                zoomImageView.frame = globalFrame
                zoomImageView.frame.origin.y -= 46
                zoomImageView.image = image
                
                imageView.image = nil
                
                [blackView, zoomImageView].forEach{keyWindow.addSubview($0)}
                
            }
        }
        
        if sender.state == .changed {
            
            if sender.scale > 1 {
                zoomImageView.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
                blackView.alpha = sender.scale * 0.25
            }
        }
        
        if sender.state == .ended || sender.state == .cancelled {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.zoomImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.blackView.alpha = 0
            }, completion: { (completed) in
                self.zoomImageView.removeFromSuperview()
                self.originalImageView.image = self.originalImage
                self.blackView.removeFromSuperview()
            })
        }
        
    }
    
}
