//
//  SceneView.swift
//  SceneKitPick
//
//  Created by ischuetz on 24/07/2014.
//  Copyright (c) 2014 ivanschuetz. All rights reserved.
//

import SceneKit
import QuartzCore

protocol ItemSelectionDelegate {
    func onItemSelected(name:String)
}

class SceneView: SCNView {
    
    var selectionDelegate:ItemSelectionDelegate!
    
    var selectedMaterial:SCNMaterial!
    
    func loadSceneAtURL(url:NSURL) {
        
        let options:Dictionary = [SCNSceneSourceCreateNormalsIfAbsentKey : true]
        
        var error:NSError?
        let maybeScene:SCNScene? = SCNScene.sceneWithURL(url, options: options, error: &error)
        
        if let scene = maybeScene? {
            self.scene = scene
            
        } else {
            println("Error loading scene: " + error!.localizedDescription)
        }
    }
    
    
    func selectNode(node:SCNNode, materialIndex:Int) {
        
        if self.selectedMaterial {
            self.selectedMaterial.removeAllAnimations()
            self.selectedMaterial = nil
        }
        
        let unsharedMaterial:SCNMaterial = node.geometry.materials[materialIndex].copy() as SCNMaterial
        node.geometry.replaceMaterialAtIndex(materialIndex, withMaterial: unsharedMaterial)
        
        self.selectedMaterial = unsharedMaterial
        
        let highlightAnimation:CABasicAnimation = CABasicAnimation(keyPath: "contents")
        highlightAnimation.toValue = NSColor.blueColor()
        highlightAnimation.fromValue = NSColor.blackColor()
        
        highlightAnimation.repeatCount = MAXFLOAT
        highlightAnimation.removedOnCompletion = false
        highlightAnimation.fillMode = kCAFillModeForwards
        highlightAnimation.duration = 0.5
        highlightAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        self.selectedMaterial.emission.intensity = 1.0
        self.selectedMaterial.emission.addAnimation(highlightAnimation, forKey: "highlight")

        self.selectionDelegate.onItemSelected(node.name)
    }
    
    override func mouseDown(event: NSEvent!) {
        let mouseLocation = self.convertPoint(event.locationInWindow, fromView: nil)
        let hits = self.hitTest(mouseLocation, options: nil)
        
        if hits.count > 0 {
            let hit:SCNHitTestResult = hits[0] as SCNHitTestResult
            self.selectNode(hit.node, materialIndex: 0)
            
        }
        
        super.mouseDown(event)
    }
}
