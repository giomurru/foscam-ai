//
//  AppDelegate.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 26/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("app did become active")
        DispatchQueue.main.async {
            if let mvc = (NSApplication.shared.mainWindow?.windowController?.contentViewController as? MainViewController) {
                mvc.startStreaming()
            } else {
                print("can't retrieve mainviewcontroller")
            }
        }
        
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("app will resign active")
        if let mvc = (NSApplication.shared.mainWindow?.windowController?.contentViewController as? MainViewController) {
            mvc.stopStreaming()
        } else {
            print("can't retrieve mainviewcontroller")
        }
    }
    

}

