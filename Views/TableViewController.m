//
// TableViewController.m
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

#import "TableViewController.h"

#import "ViewController.h"

@implementation TableViewController

- (id) init {
	return [self initWithStyle:UITableViewStylePlain];
}

- (id) initWithStyle:(UITableViewStyle)aStyle {
	self = [super init];
	if (self) {
		style = aStyle;
	}
	return self;
}

- (void) loadView {
	self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:style] autorelease];
	self.view = self.tableView;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

#pragma mark -
#pragma mark Table view

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

#pragma mark -
#pragma mark Memory management

- (void) releaseOutlets {
	[super releaseOutlets];
	self.tableView = nil;
	self.view = nil;
}

#pragma mark -
@synthesize tableView;
@end
