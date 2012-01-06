//
// ScrollViewController.m
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

#import "ScrollViewController.h"

#import "UIView+FindFirstResponder.h"

const NSUInteger kScrollMargin = 10;

@implementation ScrollViewController

- (id) init {
	self = [super init];
	if (self) {
		
	}
	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	if (!scrollView && [[self.view class] isSubclassOfClass:[UIScrollView class]]) {
		scrollView = (UIScrollView *)self.view;
	}
	
	scrollView.contentSize = scrollView.bounds.size;
	scrollView.bounces = NO;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification 
											   object:self.view.window]; 
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillHide:) 
												 name:UIKeyboardWillHideNotification
											   object:self.view.window]; 
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[scrollView findFirstResponder] resignFirstResponder];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIKeyboardWillShowNotification 
												  object:nil]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIKeyboardWillHideNotification 
												  object:nil]; 
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification {	
	NSDictionary *userInfo = [notification userInfo];
	
	//CGRect frameBegin = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect frameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve animationCurve = 
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
	double animationDuration = 
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

	[UIView beginAnimations:@"keyboardShow" context:nil];
	[UIView setAnimationCurve:animationCurve];
	[UIView setAnimationDuration:animationDuration];
	
	frameEnd = [self.view convertRect:frameEnd fromView:self.view.window];
	
	CGRect newFrame = self.view.frame;
	newFrame.size.height = frameEnd.origin.y;
	self.view.frame = newFrame;
	
	[UIView commitAnimations];
	
	UIView *responder = [scrollView findFirstResponder];
	
	CGRect responderFrame = [scrollView convertRect:responder.bounds fromView:responder];
	if (responderFrame.origin.y + responder.frame.size.height > frameEnd.origin.y - kScrollMargin) {
		responderFrame.size.height += kScrollMargin;
		[scrollView scrollRectToVisible:responderFrame animated:YES];
		/*[scrollView setContentOffset:
		 CGPointMake(0, responderFrame.origin.y + responderFrame.size.height - kScrollMargin, 
							scrollView.frame.size.height - newFrame.size.height))];*/
	}
}

- (void) keyboardWillHide:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	
	CGRect frameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	frameEnd = [self.view convertRect:frameEnd fromView:self.view.window];
	
	CGRect newFrame = self.view.frame;
	newFrame.size.height = frameEnd.origin.y;
	self.view.frame = newFrame;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[super dealloc];
}
	 
#pragma mark -
@synthesize scrollView;
@end
