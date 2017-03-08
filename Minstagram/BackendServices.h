//
//  BackendServices.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/3/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

#import "KinveyPost.h"
#import "Relation.h"

@interface BackendServices : NSObject

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
          completionBlock:(void (^)(KCSUser *user, NSError *error))completionBlock;

- (void)userByEmail:(NSString *)email
     completionBlock:(void (^)(KCSUser *user))completionBlock;

- (void)userByUsername:(NSString *)username
        completionBlock:(void (^)(KCSUser *user))completionBlock;

- (void)isUsernameTaken:(NSString *)username
        completionBlock:(void (^)(NSString *username, BOOL alreadyTaken))completionBlock;

- (void)isEmailTaken:(NSString *)email
        completionBlock:(void (^)(NSString *email, BOOL alreadyTaken))completionBlock;

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
             fieldsAndValues:(NSDictionary *)fieldsAndValues
             completionBlock:(void (^)(KCSUser *user, KCSUserActionResult result))completionBlock;

- (void)followingByUsername:(NSString *)username
            completionBlock:(void (^)(NSArray *following))completionBlock;

- (void)followersByUsername:(NSString *)username
            completionBlock:(void (^)(NSArray *followers))completionBlock;

- (void)postById:(NSString *)postId
  completionBlock:(void (^)(KinveyPost *post))completionBlock;

- (void)photoById:(NSString *)photoId
  completionBlock:(void (^)(UIImage *image))completionBlock;

- (void)uploadPhoto:(UIImage *)imageToUpload
        withOptions:(NSDictionary *)options
    completionBlock:(void (^)(KCSFile *uploadInfo))completionBlock;

- (void)uploadPostWithUploadInfo:(KCSFile *)uploadInfo
             thumbnailUploadInfo:(KCSFile *)thumbnailInfo
                 completionBlock:(void (^)(void))completionBlock;

- (void)savePost:(KinveyPost *)postToSave
 completionBlock:(void (^)(KinveyPost *savedPost))completionBlock;

- (void)relationByFollowerUsername:(NSString *)followerUsername
             beingFollowedUsername:(NSString *)beingFollowedUsername
                   completionBlock:(void (^)(Relation *relation))completionBlock;

- (void)saveRelation:(Relation *)relationToSave
     completionBlock:(void (^)(Relation *savedRelation))completionBlock;

- (void)deleteRelation:(Relation *)relationToDelete
       completionBlock:(void (^)(void))completionBlock;

@end
