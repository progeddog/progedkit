//
// ImageActivity.m
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

#import "ImageActivityView.h"

static float const kImageActivityTransitionDuration = 0.3f;

@interface ImageActivityView()
@property (nonatomic,retain) UIActivityIndicatorView *activityView;

- (void) load;
@end

@implementation ImageActivityView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self load];
    }
    return self;
}

- (void) load {
    self.activityView = [[[UIActivityIndicatorView alloc] 
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] 
                         autorelease];
    self.activityView.hidesWhenStopped = YES;
    [self addSubview:self.activityView];
    
    self.contentMode = UIViewContentModeScaleAspectFit;
}

- (void) setImageURL:(NSURL *)url {
    NSOperation *operation = 
    [[ImagesLoader sharedInstance] requestImage:url 
                                    forDelegate:self 
                                       resizeTo:self.frame.size];
    if (operation) {
        self.image = nil;
        if (!self.activityView.isAnimating) {
            self.activityView.center = self.center;
            [self.activityView startAnimating];
        }
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.activityView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout];
}

#pragma mark - Image delegate

- (void) imageReady:(UIImage *)image forSize:(NSValue *)size {
    if (self.activityView.isAnimating) {
        [self.activityView stopAnimating];
        
        self.alpha = 0;
        [UIView animateWithDuration:kImageActivityTransitionDuration 
                         animations:^{
                             self.alpha = 1;
                         }];
    }
    self.image = image;
}

#pragma mark - Memory management

- (void) dealloc {
    [[ImagesLoader sharedInstance] cancelDelegate:self];
    self.activityView = nil;
    [super dealloc];
}

#pragma mark -
@synthesize activityView;
@end
