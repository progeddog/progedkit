//
// FlatListObject.m
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

#import "FlatListObject.h"

@interface FlatListObject()
@property (nonatomic,strong) NSArray *sublist;

- (void) loadCache;
@end

@implementation FlatListObject

- (id) initWithObject:(id<FlatListedObject>)object {
    return [self initWithObject:object andLevel:0];
}

- (id) initWithObject:(id<FlatListedObject>)object andLevel:(NSUInteger)level {
    self = [self init];
    if (self) {
        self.object = object;
        self.level = level;
    }
    return self;
}

- (id) objectAtIndex:(NSInteger)index {
    if (index >= 1 && [self.object isFlatExtended]) {
        [self loadCache];
        index -= 1;
        for (int i=0; i<self.sublist.count; i++) {
            FlatListObject *object = [self.sublist objectAtIndex:i];
            if (index < [object count]) {
                return [object objectAtIndex:index];
            }
            else {
                index -= [object count];
            }
        }
        return nil;
    }
    else {
        return self;
    }
}

- (void) loadCache {
    if (!self.sublist) {
        NSArray *objectSublist = [self.object flatSublist];
        NSMutableArray *sublist = [NSMutableArray arrayWithCapacity:objectSublist.count];
        for (id<FlatListedObject> subobject in objectSublist) {
            [sublist addObject:[[[FlatListObject alloc] initWithObject:subobject 
                                                              andLevel:self.level + 1] 
                                autorelease]];
        }
        self.sublist = [[sublist copy] autorelease];
    }
}

- (void) purgeCache {
    self.sublist = nil;
}
            
- (NSUInteger) count {
    if ([self.object isFlatExtended]) {
        [self loadCache];
        
        // this should not be cached because list extension
        NSUInteger count = 1;
        for (int i=0; i<self.sublist.count; i++) {
            count += [[self.sublist objectAtIndex:i] count];
        }
        return count;
    }
    else {
        return 1;
    }
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
    self.object = nil;
    self.sublist = nil;
    [super dealloc];
}

#pragma mark -
@synthesize object;
@synthesize sublist;
@synthesize level;
@end
