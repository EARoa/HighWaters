//
//  AnnotationView.swift
//  HighWaters
//
//  Created by Efrain Ayllon on 7/30/16.
//  Copyright © 2016 Efrain Ayllon. All rights reserved.
//

import UIKit
import MapKit

class AnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupAnnotationView()
    }
    
    private func setupAnnotationView() {
        self.frame.size = CGSize(width: 60, height: 60)
        self.centerOffset = CGPoint(x: -5, y: -5)
        let imageView = UIImageView(image: UIImage(named: "caution"))
        imageView.frame = self.frame
        self.addSubview(imageView)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
