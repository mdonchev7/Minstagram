//
//  Repository.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/11/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Repository : NSObject

- (void)thumbnailByPostId:(NSString *)postId
 completionBlock:(void (^)(UIImage *thumbnail))completionBlock;

@end
