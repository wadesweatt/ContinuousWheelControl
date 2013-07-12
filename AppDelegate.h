//
//  AppDelegate.h
//  ContinuousWheelControl
//
//  Created by Wade Sweatt on 7/11/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RVContinuousWheel.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, RVContinuousWheelControlling>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSTextField *textField;
@property (nonatomic, strong) IBOutlet RVContinuousWheel *wheelView;
@end
