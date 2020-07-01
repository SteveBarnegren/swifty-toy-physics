//
//  AppDelegate.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Cocoa
import SBSwiftUtils

protocol SceneMenuListener {
    func sceneMenuSaveSceneSelected()
    func sceneMenuLoadSceneSelected()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Menu actions
    
    @IBAction private func loadScene(sender: NSMenuItem) {
        print("Load scene")
        NotificationDispatcher.shared.notify(SceneMenuListener.self) {
            $0.sceneMenuLoadSceneSelected()
        }
    }
    
    @IBAction private func saveScene(sender: NSMenuItem) {
        print("Save scene")
        NotificationDispatcher.shared.notify(SceneMenuListener.self) {
            $0.sceneMenuSaveSceneSelected()
        }
    }
}

