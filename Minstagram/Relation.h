//
//  Relation.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/19/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Relation : NSObject <KCSPersistable>

@property (nonatomic) NSString *entityId;
@property (nonatomic) NSString *follower;
@property (nonatomic) NSString *beingFollowed;

@end
