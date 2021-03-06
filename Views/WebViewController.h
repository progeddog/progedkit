//
// WebViewController.h
//
// Copyright (C) 2012 Yurii Pavlovskii <progdogdev@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <Foundation/Foundation.h>

#import "ViewController.h"

@interface WebViewController : ViewController <UIWebViewDelegate> {
	NSURL *url;
	NSString *html;
	NSString *title;
	UIWebView *webView;
	
	BOOL javascriptRedirects;
}

@property (nonatomic,assign) BOOL javascriptRedirects;

- (id) initWithURL:(NSURL *)url andTitle:(NSString *)title;
- (id) initWithHTML:(NSString *)aHtml andTitle:(NSString *)aTitle;

@end
