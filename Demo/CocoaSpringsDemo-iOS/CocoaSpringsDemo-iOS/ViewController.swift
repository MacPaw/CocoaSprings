//
//  ViewController.swift
//  CocoaSpringsDemo-iOS
//
//  Created by Anton Barkov on 09.04.2023.
//

import UIKit
import CocoaSprings

final class ViewController: UIViewController {

    @IBOutlet weak var springMotionView: SpringMotionView!
    @IBOutlet weak var springMotionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var springMotionViewLeftConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Here we set up how the view should update its position
        // depending on the provided `point` parameter.
        springMotionView.onPositionUpdate = { [weak self] point in
            guard let self else { return }
            let size = self.springMotionView.frame.size
            self.springMotionViewLeftConstraint.constant = point.x - size.width / 2
            self.springMotionViewTopConstraint.constant = point.y - size.height / 2
        }
    }

    // UITapGestureRecognizer action
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        // Start moving to the tapped location
        springMotionView.move(to: sender.location(in: view))
    }
}

