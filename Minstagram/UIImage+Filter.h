//
//  UIImage+Filter.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/2/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Filter)

+ (UIImage *)applyFilterOnImage:(UIImage *)image withFilterName:(NSString *)filterName;

@end
