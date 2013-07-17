//
//  RVContinuousWheel.m
//  ContinuousWheelControl
//
//  Created by Wade Sweatt on 7/11/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import "RVContinuousWheel.h"
#import "NSColor+MyColorAdditions.h"

@implementation RVContinuousWheel

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        offset = 0.0;
		outerShadow = [[NSShadow alloc] init];
		[outerShadow setShadowBlurRadius:self.bounds.size.height*0.05];
		[outerShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.9]];
		[outerShadow setShadowOffset:NSMakeSize(0, -2)];
		
		tickMarkShadow = [[NSShadow alloc] init];
		[tickMarkShadow setShadowBlurRadius:self.bounds.size.height*0.02];
		[tickMarkShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:1.0]];
		[tickMarkShadow setShadowOffset:NSMakeSize(0, 0)];
		
		fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.17 green:0.18 blue:0.2 alpha:1.0]
													 endingColor:[NSColor colorWithDeviceRed:0.27 green:0.28 blue:0.3 alpha:1.0]];
        
		highlightGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor clearColor], 0.0,
                             [NSColor colorWithCalibratedWhite:0.8 alpha:0.3], 0.5,
                             [NSColor clearColor], 1.0, nil];
		
		outsideGradient = [[NSGradient alloc] initWithColorsAndLocations:[[NSColor blackColor] colorWithAlphaComponent:0.5], 0.0,
						   [NSColor clearColor], 0.25,
						   [NSColor clearColor], 0.75,
						   [[NSColor blackColor] colorWithAlphaComponent:0.5], 1.0, nil];
    }
    
    return self;
}

#define SLIDER_INLET_INSET 10.0

- (void)drawRect:(NSRect)dirtyRect
{
	CGRect bounds = CGRectInset([self bounds], 2.0, 2.0);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	CGPoint points[4];
	points[0] = NSMakePoint(bounds.origin.x, bounds.size.height*0.25);
	points[1] = NSMakePoint(points[0].x, bounds.size.height*0.75);
	points[2] = NSMakePoint(bounds.size.width, points[1].y);
	points[3] = NSMakePoint(points[2].x, points[0].y);
	
	[path moveToPoint:points[0]];
	[path lineToPoint:points[1]];
	NSPoint controlPoint1 = NSMakePoint(bounds.size.width / 2, bounds.size.height * 0.83);
	[path curveToPoint:points[2] controlPoint1:controlPoint1 controlPoint2:controlPoint1];
	[path lineToPoint:points[3]];
	NSPoint controlPoint2 = NSMakePoint(bounds.size.width / 2, bounds.size.height * 0.17);
	[path curveToPoint:points[0] controlPoint1:controlPoint2 controlPoint2:controlPoint2];
	
	[[NSColor rvMediumLightGrayColor] setStroke];
	
	[path setLineWidth:0.0];
	[fillGradient drawInBezierPath:path angle:90.0];
	[highlightGradient drawInBezierPath:path angle:0.0];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[outerShadow set];
	[path fill];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	[path stroke];
	
	
	NSBezierPath *innerLinePath = [NSBezierPath bezierPath];
	[innerLinePath setLineWidth:3.0];
	CGFloat width = bounds.size.width;
	CGFloat height = bounds.size.height; // greater than length of curve in the middle, will be clipped to "path"
	CGFloat startingX = bounds.origin.x + offset;
	CGFloat startingY = bounds.size.height * 0.2; // top of curve, will be clipped to "path"
	
	CGFloat sectionWidth = bounds.size.width * 0.05;
	
	CGFloat negativeX = startingX - sectionWidth;
	while (negativeX > bounds.origin.x) {
		if (negativeX > bounds.origin.x) {
			[innerLinePath moveToPoint:NSMakePoint(negativeX, startingY)];
			[innerLinePath lineToPoint:NSMakePoint(negativeX, startingY + height)];
		}
		negativeX -= sectionWidth;
	}
	
	while (startingX < width) {
		[innerLinePath moveToPoint:NSMakePoint(startingX, startingY)];
		[innerLinePath lineToPoint:NSMakePoint(startingX, startingY + height)];
		startingX += sectionWidth;
	}
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[[NSColor colorWithDeviceRed:0.55 green:0.55 blue:0.56 alpha:1.0] set];
	[path addClip];
	//[tickMarkShadow set];
	[innerLinePath stroke];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	[outsideGradient drawInBezierPath:path angle:0.0];
}

- (void) mouseDown:(NSEvent *)theEvent {
	lastDragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if ([self.delegate respondsToSelector:@selector(wheelDidBeginMovementWithOffset:)]) {
		[self.delegate wheelDidBeginMovementWithOffset:offset];
	}
}

- (void) mouseDragged:(NSEvent *)theEvent {
	CGPoint dragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask|NSLeftMouseDraggedMask|NSLeftMouseUpMask
									   untilDate:[NSDate distantFuture]
										  inMode:NSEventTrackingRunLoopMode dequeue:YES]) && ([theEvent type]!=NSLeftMouseUp))
    {
        @autoreleasepool {
            NSDisableScreenUpdates();
			dragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			CGFloat change = dragPoint.x - lastDragPoint.x;
			offset += change;
			NSEnableScreenUpdates();
			[self setNeedsDisplay:YES];
			[self.delegate wheelDidMoveByAmount:change];
			lastDragPoint = dragPoint;
		}
	}
	[self mouseUp:theEvent];
}

- (void) mouseUp:(NSEvent *)theEvent {
	lastDragPoint = CGPointZero;
	CGFloat sectionWidth =  CGRectInset(self.bounds, 2.0, 2.0).size.width * 0.05;
	// Reduce the size of the offset to the smallest number
	// possible, and retain the drawing of the view as shown.
	// Used to keep the offset from building up into a huge number
	CGFloat mod = fmod(fabs(offset), sectionWidth);
	offset = offset<0 ? (-1*mod) : mod;
	[self setNeedsDisplay:YES];
	
	if ([self.delegate respondsToSelector:@selector(wheelDidEndMovementWithOffset:)]) {
		[self.delegate wheelDidEndMovementWithOffset:offset];
	}
}

@end
