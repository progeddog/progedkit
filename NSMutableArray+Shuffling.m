//
// NSMutableArray+Shuffling.m
//
// See 
// http://stackoverflow.com/questions/56648/whats-the-best-way-to-shuffle-an-nsmutablearray
// Authors: John D. Pope, Kristopher Johnson
//

#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

- (void) shuffle {
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        srandom(time(NULL));
    }
    
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
