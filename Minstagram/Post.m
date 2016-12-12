//
//  Post.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/5/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "Post.h"

@implementation Post

- (NSDictionary *)hostToKinveyPropertyMapping
{
    return @{@"entityId" : KCSEntityKeyId,
             @"photoId" : @"photo id",
             @"postedOn" : @"posted on",
             @"likers" : @"likers"
             };
}

@end
