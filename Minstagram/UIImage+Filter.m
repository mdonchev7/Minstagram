//
//  UIImage+Filter.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/2/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "UIImage+Filter.h"

@implementation UIImage (Filter)

+ (UIImage *)applyFilterOnImage:(UIImage *)image withFilterName:(NSString *)filterName {
    CGImageRef imageRef = [image CGImage];
    CIImage *ciImage = [CIImage imageWithCGImage:imageRef];
    
    CIFilter *filter = [CIFilter filterWithName:filterName];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGRect extent = [result extent];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    UIImage *imageWithFilterApplied = [UIImage imageWithCGImage:cgImage];
    
    return imageWithFilterApplied;
}

@end
