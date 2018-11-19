//
//  ReadingWebview.swift
//  Globe3
//
//  Created by Charles Masson on 24/11/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class ReadingWebview: UIWebView {
    
    required init(coder : NSCoder){
        super.init(coder : coder)!
        paginationBreakingMode = UIWebPaginationBreakingMode.Page
        paginationMode = UIWebPaginationMode.LeftToRight
        scrollView.scrollEnabled = false
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        paginationBreakingMode = UIWebPaginationBreakingMode.Page
        paginationMode = UIWebPaginationMode.LeftToRight
        scrollView.scrollEnabled = false
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    func loadFont(font : String) {
        stringByEvaluatingJavaScriptFromString("document.body.style.fontFamily = '\(font)'")
        stringByEvaluatingJavaScriptFromString("var ps = document.getElementsByTagName('p');for(var i =0;i<ps.length;i++){ps[i].style.fontFamily = '\(font)';}")
    }
    
    func scrollToSearchedText(text : String, occurence : Int) -> Int {
        print("occurence \(occurence)")
        /*var top = */stringByEvaluatingJavaScriptFromString("function scrollToSearched(elt){ " +
            "if (elt) {" +
            "\nif (elt.nodeType == 3) { " +
            "\nwhile (true) { " +
                "var value = elt.nodeValue;" +
                "var idx = value.toLowerCase().indexOf('\(text)');" +
                "if (idx < 0) {break;}\n" +
                "var span = document.createElement('span');" +
                "var text = document.createTextNode(value.substr(idx,\(text.characters.count))); " +
                "span.appendChild(text); " +
                "span.setAttribute('class','onsentape'); " +
                "span.setAttribute('id','searched-now-' +  count);" +
                "count++;" +
                "/*if(count == \(occurence)) {\nreturn('pd');}\n span.getBoundingClientRect().top;*/" +
                "span.style.backgroundColor='yellow'; " +
                "span.style.color='black'; " +
                "text = document.createTextNode(value.substr(idx+\(text.characters.count))); " +
                "elt.deleteData(idx, value.length - idx); " +
                "var next = elt.nextSibling; elt.parentNode.insertBefore(span, next); " +
                "elt.parentNode.insertBefore(text, next); " +
                "elt = text;}\n" +
            "}else if (elt.nodeType == 1) { " +
                "if (elt.style.display != 'none' && elt.nodeName.toLowerCase() != 'select') {" +
                    "for (var i=elt.childNodes.length-1; i>=0; i--) { " +
                        "scrollToSearched(elt.childNodes[i]); } } } } " +
            "}" +
            "var count = 1; " +
            "scrollToSearched(document.body);" +
            "function debug(s) { setTimeout( function(){ alert(s); } , 1); }" +
            "/*function(){return(document.getElementById('searched-now-' + (count - \(occurence))).getBoundingClientRect().left);}*/")
        let position = stringByEvaluatingJavaScriptFromString("function getPos(){return(document.getElementById('searched-now-' + (count - \(occurence))).getBoundingClientRect().left);}\n" + "getPos();")
        
        print("\(frame.size.width)")
        
        print("result position\(position)")
        if position != nil && position! != "" {
            let pageDec : CGFloat = CGFloat(Float(position!)!) / frame.size.width
            let page = floor(pageDec)
            print("\(pageDec)     \(page)")
            scrollView.contentOffset.x = CGFloat(page) * frame.size.width
            return Int(page)
        } else {
            return 0
        }
        
    }
    
    func loadDarkBackground() {
        stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#000000', 'important')")//We load the background
        stringByEvaluatingJavaScriptFromString("document.body.style.color = '#EFEFEF'")
        superview?.backgroundColor = UIColor.blackColor()
    }
    
    func loadGrayBackground() {
        stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#EFEFEF', 'important')")
        stringByEvaluatingJavaScriptFromString("document.body.style.color = '#000000'")
    }
}
