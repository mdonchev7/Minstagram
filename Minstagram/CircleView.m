//
//  CircleView.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/15/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[self.tintColor colorWithAlphaComponent:0.65f] set];
    
    CGContextSetLineWidth(context, 2.0);
    rect = CGRectMake(rect.origin.x + 1, rect.origin.y + 1, rect.size.width - 2, rect.size.height - 2);
    CGContextStrokeEllipseInRect(context, rect);
}

@end
