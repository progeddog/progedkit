//
// ImagesLoader.h
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

@protocol ImagesLoaderDelegate <NSObject>
- (void) imageReady:(UIImage *)image forSize:(NSValue *)size;
@end

@interface ImagesLoader : NSObject {
    NSMutableDictionary *cache;
    NSMutableArray *delegates;
    NSMutableArray *delegatesURLs;
    NSMutableDictionary *fetchOperations;
    NSMutableDictionary *resizeOperations;
    NSOperationQueue *queue;
}

+ (ImagesLoader *) sharedInstance;

- (id) initWithQueue:(NSOperationQueue *)queue;

- (NSOperation *) requestImage:(NSURL *)imageURL 
                   forDelegate:(id<ImagesLoaderDelegate>)delegate
                      withSize:(NSValue *)size;
- (NSOperation *) requestImage:(NSURL *)imageURL forDelegate:(id<ImagesLoaderDelegate>)delegate;
- (NSOperation *) requestImage:(NSURL *)imageURL 
                   forDelegate:(id<ImagesLoaderDelegate>)delegate 
                      resizeTo:(CGSize)size;

- (UIImage *) cachedImage:(NSURL *)imageURL withSize:(NSValue *)size;
- (void) setImage:(UIImage *)image forURL:(NSURL *)imageURL withSize:(NSValue *)size;
- (void) purgeCache;
- (void) cancelAll;
- (void) cancelDelegate:(id<ImagesLoaderDelegate>)delegate;

@end
