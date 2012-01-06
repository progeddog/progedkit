//
// NSFetchRequest+Execute.m
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

#import "NSFetchRequest+Execute.h"

#import "DataManager.h"

@implementation NSFetchRequest(Execute)

- (NSArray *) execute {
    return [self executeIn:[DataManager sharedInstance].context];
}

- (NSArray *) executeIn:(NSManagedObjectContext *)context {
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:self error:&error];
    if (array == nil) {
        // XXX: Fetch error handling
        NSLog(@"Fetch Error: %@, %@", self, error);
    }
    return array;
}

- (NSUInteger) count {
    return [self countIn:[DataManager sharedInstance].context];
}

- (NSUInteger) countIn:(NSManagedObjectContext *)context {
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:self error:&error];
    if (error) {
        // XXX: Count error handling
        NSLog(@"Count Error: %@, %@", self, error);
    }
    return count;
}

- (id) find {
    return [self findIn:[DataManager sharedInstance].context];
}

- (id) findIn:(NSManagedObjectContext *)context {
    [self setFetchLimit:1];
    NSArray *all = [self executeIn:context];
    return [all lastObject];
}

@end
