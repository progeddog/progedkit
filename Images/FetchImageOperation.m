//
// FetchImageOperation.m
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

#import "FetchImageOperation.h"

#import "ImagesLoader.h"
#import "ResizeImageOperation.h"
#import "Logging.h"

@interface FetchImageOperation()
- (void) setResult:(UIImage *)image;
@end

@implementation FetchImageOperation

- (id) initWithLoader:(ImagesLoader *)newLoader
           imageAtURL:(NSURL *)newURL {
    self = [super init];
    if (self) {
        self.loader = newLoader;
        self.url = newURL;
    }
    return self;
}

#pragma mark - Operation

- (void) main {
    @autoreleasepool {
        DLog(@"Running image fetch: %@, %@", self, url);
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image = [[[UIImage alloc] initWithData:data] autorelease];
        [data release];
        DLog(@"Finished fetch: %@", self);
        [self performSelectorOnMainThread:@selector(setResult:) withObject:image waitUntilDone:NO];
    }
}

- (void) setResult:(UIImage *)image {
    [self.loader setImage:image forURL:url withSize:nil];
}

#pragma mark - Memory management

- (void)dealloc {
    self.loader = nil;
    self.url = nil;
    [super dealloc];
}

#pragma mark -
@synthesize loader;
@synthesize url;
@end
