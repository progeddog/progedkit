//
// WebViewController.m
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

#import "WebViewController.h"


@implementation WebViewController

- (id) initWithURL:(NSURL *)anUrl andTitle:(NSString *)aTitle {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		url = [anUrl retain];
		title = [aTitle retain];
	}
	return self;
}

- (id) initWithHTML:(NSString *)aHtml andTitle:(NSString *)aTitle {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		html = [aHtml retain];
		title = [aTitle retain];
	}
	return self;
}

- (void) loadView {
	self.view = webView = [[[UIWebView alloc] init] autorelease];
	webView.delegate = self;
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	if (url)
		[webView loadRequest:[NSURLRequest requestWithURL:url]];
	else if(html)
		[webView loadHTMLString:html baseURL:nil];
	
	UINavigationItem *item = self.navigationItem;
	item.title = title;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void) webViewDidStartLoad:(UIWebView *)webView {
	[self showActivity];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
	[self hideActivity];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
  navigationType:(UIWebViewNavigationType)navigationType {
	
	NSURL *anUrl = [request URL];
	BOOL external = NO;
	
	if (![anUrl isEqual:url]) {
		if ([[anUrl scheme] hasPrefix:@"itms"]) {
			external = YES;
		}
		else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
			external = YES;
		}
		else if (navigationType == UIWebViewNavigationTypeOther && javascriptRedirects) {
			external = YES;
		}
	}

	if (external) {
		[[UIApplication sharedApplication] openURL:anUrl];
		return NO;
	}
	else {
		return YES;
	}
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[title release];
	[url release];
	[html release];
	[super dealloc];
}

#pragma mark -
@synthesize javascriptRedirects;
@end
