//
// ViewController.m
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

#import "ViewController.h"

static float const kViewActivityTransitionDuration = 0.5;

static UIInterfaceOrientation interfaceOrientation;

@interface ViewController()

@end

@implementation ViewController

+ (UIInterfaceOrientation) interfaceOrientation {
    return interfaceOrientation;
}

+ (void) setDeviceOrientation:(UIDeviceOrientation)orientation {
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
        interfaceOrientation = (UIInterfaceOrientation)orientation;
    }
}

- (id) init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self willRotateToInterfaceOrientation:[ViewController interfaceOrientation] duration:0];
}

#pragma mark - Rotation

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) adjustsRotation {
    return NO;
}

- (void) adjustRotationTo:(CGSize)newSize landscape:(BOOL)landscape {
    
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                 duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (duration > 0 && [self adjustsRotation]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
    }
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self adjustRotationTo:CGSizeMake(480, 300) landscape:YES];
    }
    else {
        [self adjustRotationTo:CGSizeMake(320, 460) landscape:NO];
    }
    
    if (duration > 0 && [self adjustsRotation])
        [UIView commitAnimations];
}

#pragma mark - Activity

- (void) showActivity {
    if (!viewControllerActivity) {
        viewControllerActivity = [[UIView alloc] initWithFrame:self.view.bounds];
        viewControllerActivity.backgroundColor = [UIColor colorWithWhite:0.00f alpha:0.40f];
        viewControllerActivity.autoresizingMask = 
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIActivityIndicatorView *activityIndicator =
        [[[UIActivityIndicatorView alloc] 
          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        activityIndicator.center = viewControllerActivity.center;
        activityIndicator.autoresizingMask = 
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [viewControllerActivity addSubview:activityIndicator];
        
        UILabel *activityLabel = 
        [[[UILabel alloc] initWithFrame:CGRectMake(0, 
                                                   viewControllerActivity.frame.size.height - 25,
                                                   viewControllerActivity.frame.size.width, 25)] 
         autorelease];
        activityLabel.text = NSLocalizedString(@"Please wait..", @"activity text");
        activityLabel.textColor = [UIColor whiteColor];
        activityLabel.backgroundColor = [UIColor clearColor];
        activityLabel.textAlignment = UITextAlignmentCenter;
        activityLabel.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin; //| UIViewAutoresizingFlexibleBottomMargin;*/
        [viewControllerActivity addSubview:activityLabel];
        
        [self.view addSubview:viewControllerActivity];
        [activityIndicator startAnimating];
    }
}

- (void) showActivityAnimated {
    if (!viewControllerActivity) {
        [self showActivity];
        viewControllerActivity.alpha = 0;
        
        [UIView animateWithDuration:kViewActivityTransitionDuration
                         animations:^{
                             viewControllerActivity.alpha = 1;
                         }];
    }
}

- (void) hideActivity {
    if (viewControllerActivity) {
        [viewControllerActivity removeFromSuperview];
        [viewControllerActivity release], viewControllerActivity = nil;
    }
}

- (void) hideActivityAnimated {
    if (viewControllerActivity) {
        UIView *activity = viewControllerActivity;
        viewControllerActivity = nil;
        
        [UIView animateWithDuration:kViewActivityTransitionDuration
                              delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ activity.alpha = 0; }
                         completion:^(BOOL completed) { 
                             [activity removeFromSuperview];
                             [activity release];
                         }];
    }
}

#pragma mark - Memory management

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) releaseOutlets {
    
}

- (void) viewDidUnload {
    [super viewDidUnload];
    [self releaseOutlets];
}

- (void) dealloc {
    [self releaseOutlets];
    [super dealloc];
}

@end
