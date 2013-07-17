//
//  RVContinuousWheel.h
//  ContinuousWheelControl
//
//  Created by Wade Sweatt on 7/11/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol RVContinuousWheelControlling <NSObject>
- (void) wheelDidMoveByAmount:(CGFloat)amount;
@optional
- (void) wheelDidBeginMovementWithOffset:(CGFloat)offset;
- (void) wheelDidEndMovementWithOffset:(CGFloat)offset;
@end

@interface RVContinuousWheel : NSView {
	CGFloat offset;
	CGPoint lastDragPoint;
	NSShadow *outerShadow, *tickMarkShadow;
	NSGradient *fillGradient, *highlightGradient, *outsideGradient;
}
@property (nonatomic, weak)	id <RVContinuousWheelControlling> delegate;
@end
