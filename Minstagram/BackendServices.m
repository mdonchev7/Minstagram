//
//  BackendServices.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/3/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "BackendServices.h"

#import <KinveyKit/KinveyKit.h>

#import "Relation.h"
#import "Post.h"

@implementation BackendServices

- (void)isUsernameTaken:(NSString *)username
        completionBlock:(void (^)(NSString *, BOOL))completionBlock {
    [KCSUser checkUsername:username
       withCompletionBlock:^(NSString *username, BOOL alreadyTaken, NSError *error) {
           if (error == nil) {
               completionBlock(username, alreadyTaken);
           } else {
               NSLog(@"username existense check error: %@", error);
           }
       }];
}

- (void)isEmailTaken:(NSString *)email
     completionBlock:(void (^)(NSString *, BOOL))completionBlock {
    [self userByEmail:email completionBlock:^(KCSUser *user) {
        if (user == nil) {
            completionBlock(email, NO);
        } else {
            completionBlock(email, YES);
        }
    }];
}

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
             fieldsAndValues:(NSDictionary *)fieldsAndValues
             completionBlock:(void (^)(KCSUser *, KCSUserActionResult))completionBlock {
    [KCSUser userWithUsername:username
                     password:password
              fieldsAndValues:fieldsAndValues
          withCompletionBlock:^(KCSUser *user, NSError *error, KCSUserActionResult result) {
              if (error == nil) {
                  completionBlock(user, result);
              } else {
                  NSLog(@"user registration error: %@", error);
              }
          }];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
          completionBlock:(void (^)(KCSUser *, KCSUserActionResult))completionBlock {
    [KCSUser loginWithUsername:username
                      password:password
           withCompletionBlock:^(KCSUser *user, NSError *error, KCSUserActionResult result) {
               if (error == nil) {
                   completionBlock(user, result);
               } else {
                   NSLog(@"user login error: %@", error);
               }
           }];
}

- (void)userByEmail:(NSString *)email
    completionBlock:(void (^)(KCSUser *))completionBlock {
    [KCSUserDiscovery lookupUsersForFieldsAndValues:@{KCSUserAttributeEmail : email}
                                    completionBlock:^(NSArray *users, NSError *error) {
                                        if (error == nil) {
                                            KCSUser *user = [users firstObject];
                                            completionBlock(user);
                                        } else {
                                            NSLog(@"user fetch error: %@", error);
                                        }
                                    }
                                      progressBlock:nil];
}

- (void)userByUsername:(NSString *)username
       completionBlock:(void (^)(KCSUser *user))completionBlock {
    KCSAppdataStore *usersStore = [KCSAppdataStore storeWithCollection:[KCSCollection userCollection] options:nil];
    
    [usersStore queryWithQuery:[KCSQuery queryOnField:@"username"
                               withExactMatchForValue:username]
           withCompletionBlock:^(NSArray *users, NSError *error) {
               if (error == nil) {
                   KCSUser *user = [users firstObject];
                   completionBlock(user);
               } else {
                   NSLog(@"user fetch error: %@", error);
               }
           } withProgressBlock:nil];
}

- (void)followingByUsername:(NSString *)username
            completionBlock:(void (^)(NSArray *))completionBlock {
    KCSAppdataStore *relationsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Relations"
                                                                     ofClass:[Relation class]]
                                 options:nil];
    
    [relationsStore queryWithQuery:[KCSQuery queryOnField:@"follower"
                                   withExactMatchForValue:username]
               withCompletionBlock:^(NSArray *following, NSError *error) {
                   if (error == nil) {
                       completionBlock(following);
                   } else {
                       NSLog(@"relations fetch error: %@", error);
                   }
                   
               } withProgressBlock:nil];
}

- (void)followersByUsername:(NSString *)username
            completionBlock:(void (^)(NSArray *))completionBlock {
    KCSAppdataStore *relationsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Relations"
                                                                     ofClass:[Relation class]]
                                 options:nil];
    
    [relationsStore queryWithQuery:[KCSQuery queryOnField:@"being followed"
                                   withExactMatchForValue:username]
               withCompletionBlock:^(NSArray *followers, NSError *error) {
                   if (error == nil) {
                       completionBlock(followers);
                   } else {
                       NSLog(@"relations fetch error: %@", error);
                   }
               } withProgressBlock:nil];
}

- (void)postById:(NSString *)postId
 completionBlock:(void (^)(Post *))completionBlock {
    KCSAppdataStore *postsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Posts"
                                                                     ofClass:[Post class]]
                                 options:nil];
    
    [postsStore loadObjectWithID:postId
             withCompletionBlock:^(NSArray *posts, NSError *error) {
                 if (error == nil) {
                     Post *post = [posts firstObject];
                     completionBlock(post);
                 } else {
                     NSLog(@"post fetch error: %@", error);
                 }
             } withProgressBlock:nil];
}

- (void)photoById:(NSString *)photoId
  completionBlock:(void (^)(UIImage *))completionBlock {
    [KCSFileStore downloadData:photoId
               completionBlock:^(NSArray *downloadedResources, NSError *error) {
                   if (error == nil) {
                       KCSFile *file = downloadedResources[0];
                       NSData *fileData = file.data;
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           UIImage *image = [UIImage imageWithData:fileData];
                           completionBlock(image);
                       });
                   } else {
                       NSLog(@"photo fetch error: %@", error);
                   }
               } progressBlock:nil];
}

- (void)uploadPhoto:(UIImage *)imageToUpload
        withOptions:(NSDictionary *)options
    completionBlock:(void (^)(KCSFile *))completionBlock {
    NSData *data = UIImageJPEGRepresentation(imageToUpload, 1.0);
    
    [KCSFileStore uploadData:data
                     options:options
             completionBlock:^(KCSFile *uploadInfo, NSError *error) {
                 if (error == nil) {
                     completionBlock(uploadInfo);
                 } else {
                     NSLog(@"photo upload error: %@", error);
                 }
             } progressBlock:nil];
}

- (void)uploadPostWithUploadInfo:(KCSFile *)uploadInfo
                 completionBlock:(void (^)(void))completionBlock {
    KCSAppdataStore *postsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Posts"
                                                                     ofClass:[Relation class]]
                                 options:nil];
    
    Post *postToUpload = [[Post alloc] init];
    postToUpload.photoId = [uploadInfo fileId];
    postToUpload.postedOn = [NSDate date];
    postToUpload.likers = [[NSArray alloc] init];
    
    [postsStore saveObject:postToUpload
       withCompletionBlock:^(NSArray *savedObjects, NSError *error) {
           if (error == nil) {
               KCSUser *activeUser = [KCSUser activeUser];
               NSMutableArray *posts = [activeUser getValueForAttribute:@"posts"];
               [posts addObject:[[savedObjects firstObject] kinveyObjectId]];
               [activeUser setValue:posts forAttribute:@"posts"];
               
               [activeUser saveWithCompletionBlock:^(NSArray *objects, NSError *error) {
                   if (error == nil) {
                       completionBlock();
                   } else {
                       NSLog(@"user save error: %@", error);
                   }
               }];
           } else {
               NSLog(@"post upload error: %@", error);
           }
       } withProgressBlock:nil];
}

- (void)savePost:(Post *)postToSave
 completionBlock:(void (^)(Post *))completionBlock {
    KCSAppdataStore *postsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Posts"
                                                                     ofClass:[Relation class]]
                                 options:nil];
    
    [postsStore saveObject:postToSave
            withCompletionBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    completionBlock([objects firstObject]);
                } else {
                    NSLog(@"post save error: %@", error);
                }
            } withProgressBlock:nil];
}

- (void)relationByFollowerUsername:(NSString *)followerUsername
             beingFollowedUsername:(NSString *)beingFollowedUsername
                   completionBlock:(void (^)(Relation *))completionBlock {
    KCSAppdataStore *relationsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Relations"
                                                                     ofClass:[Relation class]]
                                 options:nil];
    
    [relationsStore queryWithQuery:[KCSQuery queryOnField:@"follower"
                                   withExactMatchForValue:followerUsername]
               withCompletionBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beingFollowed = %@", beingFollowedUsername];
            Relation *relation = [[objects filteredArrayUsingPredicate:predicate] firstObject];
            
            completionBlock(relation);
        } else {
            NSLog(@"relation fetch error: %@", error);
        }
    } withProgressBlock:nil];
}

- (void)saveRelation:(Relation *)relationToSave
     completionBlock:(void (^)(Relation *))completionBlock {
    KCSAppdataStore *relationsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Relations"
                                                                     ofClass:[Relation class]]
                                 options:nil];
    
    [relationsStore saveObject:relationToSave
                withCompletionBlock:^(NSArray *objects, NSError *error) {
                    if (error == nil) {
                        completionBlock([objects firstObject]);
                    } else {
                        NSLog(@"relation saving error: %@", error);
                    }
                } withProgressBlock:nil];
}

- (void)deleteRelation:(Relation *)relationToDelete
       completionBlock:(void (^)(void))completionBlock {
    KCSAppdataStore *relationsStore =
    [KCSAppdataStore storeWithCollection:[KCSCollection collectionFromString:@"Relations"
                                                                     ofClass:[Relation class]]
                                 options:nil];
    
    [relationsStore removeObject:relationToDelete
                  withCompletionBlock:^(unsigned long count, NSError *error) {
                      if (error == nil) {
                          completionBlock();
                      } else {
                          NSLog(@"relation deletion error: %@", error);
                      }
                  } withProgressBlock:nil];
}

@end



















