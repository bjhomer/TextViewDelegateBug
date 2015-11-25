//
//  ViewController.swift
//  TextViewDelegateBug
//
//  Created by BJ Homer on 11/25/15.
//  Copyright © 2015 BJ Homer. All rights reserved.
//

import Cocoa
class ViewController: NSViewController {
    let textStorage = NSTextStorage()
    let layoutManager = NSLayoutManager()
    var textView1: NSTextView?
    var textView2: NSTextView?
    
    @IBOutlet var containerView: NSView!
    @IBOutlet var textChangedLabel: NSTextField!
    @IBOutlet var delegateConnectedLabel: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textStorage.addLayoutManager(layoutManager)
        
        setupViews()
    }
    
    func setupViews() {
        let height = containerView.bounds.height
        let width = containerView.bounds.width / 2 - 15
        let size = NSMakeSize(width, height)
        
        let tc1 = NSTextContainer(containerSize: size)
        tc1.widthTracksTextView = true
        tc1.heightTracksTextView = true
        
        let tc2 = NSTextContainer(containerSize: size)
        tc2.widthTracksTextView = true
        tc2.heightTracksTextView = true

        layoutManager.addTextContainer(tc1)
        layoutManager.addTextContainer(tc2)
        
        
        textView1 = NSTextView(frame: NSRect(origin: CGPointZero, size: size), textContainer: tc1)
        textView2 = NSTextView(frame: NSRect(origin: CGPointMake(width + 30, 0), size: size), textContainer: tc2)
        
        textView1!.autoresizingMask = [.ViewMaxXMargin, .ViewHeightSizable, .ViewWidthSizable]
        textView2!.autoresizingMask = [.ViewMinXMargin, .ViewHeightSizable, .ViewWidthSizable]
        
        containerView.addSubview(textView1!)
        containerView.addSubview(textView2!)
        
        
        var content = ""
        for _ in 1...30 {
            content += "Type here to trigger delegate calls.\n"
        }
        textStorage.setAttributedString(NSAttributedString(string: content))
        
        textView1!.delegate = self
        textChangedLabel.alphaValue = 0.1
        delegateConnectedLabel.alphaValue = 0.1
    }
    
    
    @IBAction func clickedTriggerBug(sender: NSButton) {
        if let textView2 = textView2,
            c2 = textView2.textContainer,
            c2Index = layoutManager.textContainers.indexOf(c2)
        {
            layoutManager.removeTextContainerAtIndex(c2Index)
            textView2.removeFromSuperview()
            self.textView2 = nil
            
            // When textView2 is deallocated, it triggers a call to 
            // -[NSNotificationCenter removeObserver:name:object:] for 'NSTextDidChangeNotification'.
            // Critically, this happens with textView1 as the `object` parameter, and textView1's delegate
            // as the `observer`. This means that even though `textView1.delegate` is still set, it will
            // no longer receive the -textDidChange:` delegate method.
        }
    }
}


extension ViewController: NSTextViewDelegate {
    func textDidChange(notification: NSNotification) {
        flashLabel(textChangedLabel)
    }
    
    
    
    func textView(textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
        
        flashLabel(delegateConnectedLabel)
        return true
    }
    
    private func flashLabel(label: NSTextField) {
        label.alphaValue = 1
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 1
            label.animator().alphaValue = 0.1
            },
            completionHandler: nil)
    }
}

