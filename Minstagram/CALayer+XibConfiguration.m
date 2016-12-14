//
//  CALayer+XibConfiguration.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/14/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

- (void)setBorderUIColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}

- (UIColor *)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
