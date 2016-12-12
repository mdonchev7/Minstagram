//
//  Relation.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/19/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "Relation.h"

@implementation Relation

- (NSDictionary *)hostToKinveyPropertyMapping
{
    return @{@"entityId" : KCSEntityKeyId,
             @"follower" : @"follower",
             @"beingFollowed" : @"being followed",
             };
}

@end
