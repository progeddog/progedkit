//
// UIView+FindFirstResponder.m
//
// See
// http://stackoverflow.com/questions/1823317/how-do-i-legally-get-the-current-first-responder-on-the-screen-on-an-iphone
// Author: Thomas Müller
//

#import "UIView+FindFirstResponder.h"


@implementation UIView (FindFirstResponder)

- (UIView *) findFirstResponder {
    if (self.isFirstResponder) {
		return self;
    }
	
    for (UIView *subView in self.subviews) {
        UIView *retView = [subView findFirstResponder];
		if (retView)
			return retView;
    }
	
    return nil;
}

@end
