//
// DataManager.m
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

#import "DataManager.h"


static NSString *const kDBName = @"EatYork.sqlite";
static NSString *const kModelName = @"EatYork";
static NSString *const kModelType = @"momd";

static DataManager *dataManager;

@implementation DataManager

+ (DataManager *) sharedInstance {
    if (!dataManager) {
        dataManager = [[DataManager alloc] init];
    }
    return dataManager;
}

#pragma mark -
#pragma mark Core Data context

- (void) saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.context;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // XXX: Save context error handling
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *) context {
    if (context != nil) {
        return context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self store];
    if (coordinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
    }
    return context;
}

- (NSManagedObjectModel *) model {
    if (model != nil) {
        return model;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kModelName withExtension:kModelType];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return model;
}

- (NSPersistentStoreCoordinator *) store {
    if (store != nil) {
        return store;
    }
    
    NSURL *storeURL = [self storeURL];
    
    NSError *error = nil;
    store = [[NSPersistentStoreCoordinator alloc] 
             initWithManagedObjectModel:[self model]];
    if (![store addPersistentStoreWithType:NSSQLiteStoreType 
                             configuration:nil 
                                       URL:storeURL 
                                   options:nil 
                                     error:&error]) {
        // XXX: Must process store availability / migration here
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return store;
}

#pragma mark - Application's Documents directory

- (NSURL *) applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *) storeURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kDBName];
}

#pragma mark - Memory managment

- (void) dealloc {
    if (self == dataManager)
        dataManager = nil;
    
    self.context = nil;
    self.model = nil;
    self.store = nil;
    [super dealloc];
}

#pragma mark -
@synthesize context;
@synthesize model;
@synthesize store;
@end
