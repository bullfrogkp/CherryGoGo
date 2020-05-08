//
//  SidebarMenu.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-09.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

extension UIViewController {

    func addSideBarMenu(leftMenuButton: UIBarButtonItem?, rightMenuButton: UIBarButtonItem? = nil) {
        if revealViewController() != nil {

            if let menuButton = leftMenuButton {
                menuButton.target = revealViewController()
                menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            }

            if let extraButton = rightMenuButton {
                revealViewController().rightViewRevealWidth = 150
                extraButton.target = revealViewController()
                extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            }

            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
}
