//
//  Post.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/5/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Post : NSObject <KCSPersistable>

@property (nonatomic) NSString *entityId;
@property (nonatomic) NSString *photoId;
@property (nonatomic) NSString *thumbnailId;
@property (nonatomic) NSDate *postedOn;
@property (nonatomic) NSArray *likers;

@end
