//
// ResizeImageOperation.m
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

#import "ResizeImageOperation.h"

#import "ImagesLoader.h"
#import "UIImage+Extensions.h"
#import "Logging.h"

@interface ResizeImageOperation()
- (void) setResult:(UIImage *)result;
@end

@implementation ResizeImageOperation

- (id) initWithLoader:(ImagesLoader *)newLoader
                image:(NSURL *)newImage
                 size:(NSValue *)newSize {
    self = [self init];
    if (self) {
        self.loader = newLoader;
        self.image = newImage;
        self.size = newSize;
    }
    return self;
}

#pragma mark - Operation

- (void) main {
    @autoreleasepool {
        DLog(@"Resize operation running: %@, %@", self, image);
        UIImage *original = [self.loader cachedImage:self.image withSize:nil];
        
        CGSize newSize = [self.size CGSizeValue];
        newSize.width *= [[UIScreen mainScreen] scale];
        newSize.height *= [[UIScreen mainScreen] scale];
        
        UIImage *newImage;
        
        if (original.size.width > newSize.width || original.size.height > newSize.height) {
            float k = original.size.width / original.size.height;
            if (newSize.width / newSize.height > k) {
                newSize.width = k * newSize.height;
            }
            else {
                newSize.height = newSize.width / k;
            }
            newImage = [original imageScaledToSize:newSize];
        }
        else {
            newImage = original;
        }
        
        DLog(@"Finished resize: %@", self);
        [self performSelectorOnMainThread:@selector(setResult:) 
                               withObject:newImage 
                            waitUntilDone:NO];
    }
}

- (void) setResult:(UIImage *)result {
    [self.loader setImage:result forURL:self.image withSize:self.size];
}

#pragma mark - Memory management

- (void) dealloc {
    self.loader = nil;
    self.image = nil;
    self.size = nil;
    [super dealloc];
}

#pragma mark -
@synthesize loader;
@synthesize image;
@synthesize size;
@end
