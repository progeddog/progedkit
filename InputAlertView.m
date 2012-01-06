//
// InputAlertView.m
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

#import "InputAlertView.h"

@implementation InputAlertView

- (id) initWithTitle:(NSString *)title message:(NSString *)message 
            delegate:(id<InputAlertViewDelegate>)delegate {
    self = [super initWithTitle:title 
                        message:[NSString stringWithFormat:@"%@\n\n\n", message]
                       delegate:self 
              cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel button title")
              otherButtonTitles:NSLocalizedString(@"OK", @"ok buton title"), nil];
    if (self) {
        self.textField = [[[UITextField alloc] 
                           initWithFrame:CGRectMake(20, 80, 240, 25)] autorelease];
        self.textField.backgroundColor = [UIColor whiteColor];
        self.textField.delegate = self;
        [self addSubview:self.textField];
        
        self.inputDelegate = delegate;
    }
    return self;
}

- (void) show {
    [super show];
    [self.textField becomeFirstResponder]; 
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void) dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if (self.textField.text.length == 0 && buttonIndex != self.cancelButtonIndex) {
        return;
    }
    
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.inputDelegate inputAlert:self didConfirmedMessage:self.textField.text];
    }
    
    if ([self.inputDelegate respondsToSelector:@selector(inputAlertDidFinished:)]) {
        [self.inputDelegate inputAlertDidFinished:self];
    }
}

#pragma mark -
#pragma mark Text field

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
 replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range 
                                                             withString:string];
    if (self.maxLength > 0 && [text length] > self.maxLength) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
    self.textField = nil;
    [super dealloc];
}

#pragma mark -
@synthesize inputDelegate;
@synthesize textField;
@synthesize maxLength;
@end
