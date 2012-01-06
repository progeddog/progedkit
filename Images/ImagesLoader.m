//
// ImagesLoader.m
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

#import "ImagesLoader.h"

#import "FetchImageOperation.h"
#import "UIImage+Extensions.h"
#import "ResizeImageOperation.h"
#import "Logging.h"

#define kOriginalKey [NSNull null]

@interface ImagesLoader()
@property (nonatomic,retain) NSMutableDictionary *cache;
@property (nonatomic,retain) NSMutableArray *delegates;
@property (nonatomic,retain) NSMutableArray *delegatesURLs;
@property (nonatomic,retain) NSMutableDictionary *fetchOperations;
@property (nonatomic,retain) NSMutableDictionary *resizeOperations;
@property (nonatomic,retain) NSOperationQueue *queue;

- (id) keyForImage:(NSURL *)imageURL withSize:(NSValue *)size;
@end

@implementation ImagesLoader
static ImagesLoader *instance = nil;

+ (ImagesLoader *) sharedInstance {
    return instance;
}

+ (id) alloc {
	@synchronized([ImagesLoader class]) {
        if (!instance)
            instance = [super alloc];
		return instance;
	}
}

- (id) initWithQueue:(NSOperationQueue *)aQueue; {
    self = [self init];
    if (self) {
        self.cache = [NSMutableDictionary dictionary];
        self.delegates = [NSMutableArray array];
        self.delegatesURLs = [NSMutableArray array];
        self.fetchOperations = [NSMutableDictionary dictionary];
        self.resizeOperations = [NSMutableDictionary dictionary];
        self.queue = aQueue;
        
        instance = self;
    }
    return self;
}

- (id) keyForImage:(NSURL *)imageURL withSize:(NSValue *)size {
    id sizeValue = size ? size : kOriginalKey;
    NSDictionary *key = [NSDictionary dictionaryWithObjectsAndKeys:
                         imageURL, @"url",
                         sizeValue, @"size",
                         nil];
    return key;
}

- (UIImage *) cachedImage:(NSURL *)imageURL withSize:(NSValue *)size {
    return [self.cache objectForKey:[self keyForImage:imageURL withSize:size]];
}

- (NSOperation *) requestImage:(NSURL *)imageURL 
                   forDelegate:(id<ImagesLoaderDelegate>)delegate
                      withSize:(NSValue *)size {
    DLog(@"Requesting %@ with size %@", imageURL, size);
    UIImage *cachedImage = [self cachedImage:imageURL withSize:size];
    if (cachedImage) {
        DLog(@"Cache hit");
        [delegate imageReady:cachedImage forSize:size];
        return nil;
    }
    else {
        [self cancelDelegate:delegate];
        [self.delegates addObject:delegate];
        [self.delegatesURLs addObject:[self keyForImage:imageURL withSize:size]];
        
        DLog(@"%@ = %@", delegates, delegatesURLs);
        
        NSOperation *fetchOperation = [self.fetchOperations objectForKey:imageURL];
        DLog(@"Current fetch operation: %@", fetchOperation);
        
        if (![self cachedImage:imageURL withSize:nil] && !fetchOperation) {
            fetchOperation =
            [[[FetchImageOperation alloc] initWithLoader:self 
                                              imageAtURL:imageURL] autorelease];
            [self.fetchOperations setObject:fetchOperation forKey:imageURL];
            [self.queue addOperation:fetchOperation];
            
            DLog(@"New fetch operation: %@", fetchOperation);
        }
        
        if (size) {
            NSOperation *resizeOperation = 
            [self.resizeOperations objectForKey:[self keyForImage:imageURL withSize:size]];
            DLog(@"Current resize operation: %@", resizeOperation);
            
            if (!resizeOperation) {
                resizeOperation =
                [[[ResizeImageOperation alloc] initWithLoader:self 
                                                        image:imageURL 
                                                         size:size] autorelease];
                [self.resizeOperations setObject:resizeOperation 
                                          forKey:[self keyForImage:imageURL withSize:size]];
                
                if (fetchOperation)
                    [resizeOperation addDependency:fetchOperation];
                [resizeOperation setQueuePriority:NSOperationQueuePriorityHigh];
                [self.queue addOperation:resizeOperation];
                DLog(@"New resize operation: %@", resizeOperation);
            }
            return resizeOperation;
        }
        else {
            return fetchOperation;
        }
    }
}

- (NSOperation *) requestImage:(NSURL *)imageURL forDelegate:(id<ImagesLoaderDelegate>)delegate {
    return [self requestImage:imageURL forDelegate:delegate withSize:nil];
}

- (NSOperation *) requestImage:(NSURL *)imageURL 
                   forDelegate:(id<ImagesLoaderDelegate>)delegate 
                      resizeTo:(CGSize)size {
    return [self requestImage:imageURL forDelegate:delegate 
                     withSize:[NSValue valueWithCGSize:size]];
}

- (void) setImage:(UIImage *)image forURL:(NSURL *)imageURL withSize:(NSValue *)size {
    if (image)
        [self.cache setObject:image forKey:[self keyForImage:imageURL withSize:size]];
    
    DLog(@"%@ = %@", delegates, delegatesURLs);
    for (int i=delegates.count-1; i>=0; i--) {
        if ([[delegatesURLs objectAtIndex:i] isEqual:[self keyForImage:imageURL withSize:size]]) {
            DLog(@"Delegate %@ received image: %@, %@", [delegates objectAtIndex:i], image, size);
            
            [[delegates objectAtIndex:i] imageReady:image forSize:size];
            
            [delegates removeObjectAtIndex:i];
            [delegatesURLs removeObjectAtIndex:i];
        }
    }
    
    if (!size)
        [self.fetchOperations removeObjectForKey:imageURL];
    else
        [self.resizeOperations removeObjectForKey:[self keyForImage:imageURL withSize:size]];
}

- (void) purgeCache {
    [self.cache removeAllObjects];
}

- (void) cancelAll {
    DLog(@"Cancel all");
    
    for (NSURL *imageURL in self.fetchOperations) {
        NSOperation *fetchOperation = [self.fetchOperations objectForKey:imageURL];
        if (![fetchOperation isExecuting]) {
            [fetchOperation cancel];
            [self.fetchOperations removeObjectForKey:imageURL];
        }
        else {
            DLog(@"%@ is executing now (not cancelled)", fetchOperation);
        }
    }
    
    for (NSArray *key in self.resizeOperations) {
        NSOperation *resizeOperation = [self.resizeOperations objectForKey:key];
        [resizeOperation cancel];
    }
    [self.resizeOperations removeAllObjects];
    
    [self.delegates removeAllObjects];
    [self.delegatesURLs removeAllObjects];
}

- (void) cancelDelegate:(id<ImagesLoaderDelegate>)delegate {
    DLog(@"Cancel delegate: %@", delegate);
    
    NSUInteger delegateIndex = [delegates indexOfObjectIdenticalTo:delegate];
    if (delegateIndex != NSNotFound) {
        id key = [delegatesURLs objectAtIndex:delegateIndex];
        DLog(@"Delegate reset: %@", key);
        
        [self.delegates removeObjectAtIndex:delegateIndex];
        [self.delegatesURLs removeObjectAtIndex:delegateIndex];
        
        [[self.resizeOperations objectForKey:key] cancel];
        [self.resizeOperations removeObjectForKey:key];
    }
}

#pragma mark - Memory management

- (void) dealloc {
    self.cache = nil;
    self.delegates = nil;
    self.delegatesURLs = nil;
    self.fetchOperations = nil;
    self.resizeOperations = nil;
    self.queue = nil;
    [super dealloc];
}

#pragma mark -
@synthesize cache;
@synthesize delegates;
@synthesize delegatesURLs;
@synthesize fetchOperations;
@synthesize resizeOperations;
@synthesize queue;
@end
