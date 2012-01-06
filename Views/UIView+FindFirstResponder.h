//
// UIView+FindFirstResponder.h
//
// See
// http://stackoverflow.com/questions/1823317/how-do-i-legally-get-the-current-first-responder-on-the-screen-on-an-iphone
// Author: Thomas Müller
//

#import <Foundation/Foundation.h>


@interface UIView(FindFirstResponder)
- (UIView *) findFirstResponder;
@end
