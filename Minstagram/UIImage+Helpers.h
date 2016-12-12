//
//  UIImage+Helpers.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/7/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helpers)

+ (void)loadWithPostId:(NSString *)postId callback:(void (^)(UIImage *image, NSArray *likers))callback;

@end
