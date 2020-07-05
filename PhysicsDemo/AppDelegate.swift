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
    func sceneMenuLoadExampleScene(fileName: String)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet private var exampleScenesMenu: NSMenu!
    
    let exampleNamesAndFiles: [(String, String)] = [
        ("Golf on the moon", "MoonGolf"),
        ("Just lines", "Lines"),
        ("Snooker", "Snooker"),
        ("Tipping Point", "TippingPoint"),
    ]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        populateExampleScenesMenu()
    }
    
    private func populateExampleScenesMenu() {
        print("menu title: \(exampleScenesMenu.title)")
        
        for (name, _) in exampleNamesAndFiles {
            let item = NSMenuItem(title: name, action: #selector(exampleSceneSelected), keyEquivalent: "")
            exampleScenesMenu.addItem(item)
        }
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
    
    @objc private func exampleSceneSelected(item: NSMenuItem) {
        
        let exampleSceneName = item.title
        print("Example scene selected: \(exampleSceneName)")
        
        guard let example = exampleNamesAndFiles.first(where: { $0.0 == exampleSceneName }) else {
            fatalError("Unable to find scene named: \(item.title)")
        }
        
        NotificationDispatcher.shared.notify(SceneMenuListener.self) {
            $0.sceneMenuLoadExampleScene(fileName: example.1)
        }
    }
}

