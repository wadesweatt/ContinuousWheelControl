//
//  AppDelegate.m
//  ContinuousWheelControl
//
//  Created by Wade Sweatt on 7/11/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.wheelView.delegate = self;
}

- (void) wheelDidMoveByAmount:(CGFloat)amount {
	[self.textField setStringValue:[NSString stringWithFormat:@"%.3f", amount]];
	//NSLog(@"wheel moved by amount: %f", amount);
}

@end
