//
//  AppDelegate.swift
//  Kill Mouse Acceleration
//
//  Created by Seph Soliman on 29/05/16.
//  Copyright © 2016 Seph Soliman. All rights reserved.
//

import Cocoa
import IOKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var statusItemMenu: NSMenu!
    
    var statusItem: NSStatusItem!
    @IBOutlet var accelerationStatusLabel: NSMenuItem!
    
    var orgaccel: Double = 0.0
    var orgaccelset: Bool = false
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        myPopup.addButtonWithTitle("Cancel")
        let res = myPopup.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }
    
    func rememberAccel() {
        let handle:io_connect_t = NXOpenEventStatus();
        if(handle != 0) {
            IOHIDGetAccelerationWithKey(handle, kIOHIDMouseAccelerationType, &orgaccel)
            NXCloseEventStatus(handle);
        }
        orgaccelset = true;
    }
    
    func setAccel(type: String, acceleration: Double) -> Int {
        var success:Int = 0
        let handle:io_connect_t = NXOpenEventStatus()
        if(handle != 0) {
            success = Int(IOHIDSetAccelerationWithKey(handle, type, acceleration))
            NXCloseEventStatus(handle)
        }
        return success
    }
    
    @IBAction func killMouseAccel(_: AnyObject) {
        if(!orgaccelset) {
            rememberAccel()
        }
    
        if(self.setAccel(kIOHIDMouseAccelerationType, acceleration: -1.0) == 0) {
            dialogOKCancel("Error", text: "Cannot set acceleration")
        }
    }
    
    @IBAction func restoreMouseAccel(_: AnyObject) {
        if(self.setAccel(kIOHIDMouseAccelerationType, acceleration: orgaccel) == 0) {
            dialogOKCancel("Failed", text: "Cannot restore acceleration")
        } else {
            orgaccelset = false
            rememberAccel()
        }
    }
    
    func toggleMenuItem() {
        let bar:NSStatusBar = NSStatusBar.systemStatusBar()
        if(self.statusItem != nil) {
            bar.removeStatusItem(statusItem)
            statusItem = nil
        } else {
            statusItem = bar.statusItemWithLength(NSVariableStatusItemLength)
            statusItem.highlightMode = true
            statusItem.menu = statusItemMenu
            statusItem.highlightMode = true
            statusItem.image = NSBundle.mainBundle().imageForResource("menuicon.png")
            statusItem.alternateImage = NSBundle.mainBundle().imageForResource("menuicon-invert.png")
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Save acceleration before we start changing it around
        rememberAccel()
        // Enable menu UI
        toggleMenuItem()
        
        // Hide Dock icon
        NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        toggleMenuItem()
    }
}

