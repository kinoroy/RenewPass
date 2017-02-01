//
// ViewController.swift
//
// Copyright (c) 2015 Mathias Koehnke (http://www.mathiaskoehnke.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Cocoa
import WKZombie

class ViewController: NSViewController {

    @IBOutlet weak var imageView : NSImageView!
    @IBOutlet weak var activityIndicator : NSProgressIndicator!
    
    let url = URL(string: "https://github.com/logos")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimation(nil)
        getTopTrendingEntry(url: url)
    }

    func getTopTrendingEntry(url: URL) {
            open(url)
        >>> get(by: .XPathQuery("//img[contains(@class, 'gh-octocat')]"))
        >>> fetch
        === output
    }
    
    func output(result: HTMLImage?) {
        imageView.image = result?.fetchedContent()
        activityIndicator.stopAnimation(nil)
    }
}

