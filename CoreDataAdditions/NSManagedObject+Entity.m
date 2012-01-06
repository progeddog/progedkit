//
// NSManagedObject+Entity.m
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

#import "NSManagedObject+Entity.h"

#import "DataManager.h"
#import "NSFetchRequest+Execute.h"

@implementation NSManagedObject(Entity)

+ (NSEntityDescription *) entity {
    return [self entityIn:[DataManager sharedInstance].context];
}

+ (NSEntityDescription *) entityIn:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:NSStringFromClass(self) 
                       inManagedObjectContext:context];
}

+ (NSFetchRequest *) fetchRequest {
    return [self fetchRequestIn:[DataManager sharedInstance].context];
}

+ (NSFetchRequest *) fetchRequestIn:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [self entityIn:context];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    return request;
}

+ (id) insert {
    return [self insertIn:[DataManager sharedInstance].context];
}

+ (id) insertIn:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                         inManagedObjectContext:context];
}

+ (void) truncate {
    [self truncateIn:[DataManager sharedInstance].context];
}

+ (void) truncateIn:(NSManagedObjectContext *)context {
    NSArray *objects = [[self fetchRequestIn:context] execute];
    for (NSManagedObject *object in objects) {
        [object deleteObject];
    }
}

- (void) deleteObject {
    [self deleteObjectFrom:[DataManager sharedInstance].context];
}

- (void) deleteObjectFrom:(NSManagedObjectContext *)context {
    [context deleteObject:self];
}

+ (id) byId:(NSInteger)index {
    return [self byId:index inContext:[DataManager sharedInstance].context];
}

+ (id) byId:(NSInteger)index inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self fetchRequestIn:context];
    [request setPredicate:[NSPredicate predicateWithFormat:
                                     @"id = %@", [NSNumber numberWithInt:index]]];
    return [request findIn:context];
}

@end
