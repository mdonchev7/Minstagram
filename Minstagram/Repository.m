//
//  Repository.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/11/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import "Repository.h"
#import "AppDelegate.h"
#import "BackendServices.h"

@interface Repository()

@property (nonatomic) BackendServices *services;
@property (nonatomic) NSMutableArray *requestedPosts;

@end

@implementation Repository

- (void)thumbnailByPostId:(NSString *)postId completionBlock:(void (^)(UIImage *))completionBlock {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataPost"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", postId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    if (error == nil) {
        CoreDataPost *post = [matches firstObject];
        
        if (post != nil && post.thumbnailId != nil) {
            if (post.thumbnailData == nil && ![self.requestedPosts containsObject:postId]) {
                [self.services photoById:post.thumbnailId completionBlock:^(UIImage *image) {
                    post.thumbnailData = UIImageJPEGRepresentation(image, 1.0f);
                    
                    completionBlock(image);
                }];
            } else {
                UIImage *thumbnail = [UIImage imageWithData:post.thumbnailData];
                
                completionBlock(thumbnail);
            }
        } else if (![self.requestedPosts containsObject:postId]) {
            [self.services postById:postId completionBlock:^(KinveyPost *post) {
                [self.services photoById:post.thumbnailId completionBlock:^(UIImage *image) {
                    CoreDataPost *coreDataPost = [NSEntityDescription
                                                  insertNewObjectForEntityForName:@"CoreDataPost"
                                                  inManagedObjectContext:context];
                    
                    coreDataPost.thumbnailData = UIImageJPEGRepresentation(image, 1.0f);
                    coreDataPost.identifier = post.entityId;
                    coreDataPost.imageId = post.photoId;
                    coreDataPost.thumbnailId = post.thumbnailId;
                    
                    completionBlock(image);
                }];
            }];
        }
    } else {
        NSLog(@"%@", error);
    }
}

- (void)imageByPostId:(NSString *)postId completionBlock:(void (^)(UIImage *))completionBlock {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataPost"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", postId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error == nil) {
        CoreDataPost *post = [matches firstObject];
        
        if (post != nil && post.imageId != nil) {
            if (post.imageData == nil && ![self.requestedPosts containsObject:postId]) {
                [self.services photoById:post.imageId completionBlock:^(UIImage *image) {
                    [self.requestedPosts addObject:postId];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        post.imageData = UIImageJPEGRepresentation(image, 1.0f);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(image);
                        });
                    });
                }];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage imageWithData:post.imageData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(image);
                    });
                });
            }
        } else if (![self.requestedPosts containsObject:postId]) {
            [self.services postById:postId completionBlock:^(KinveyPost *post) {
                [self.requestedPosts addObject:postId];
                
                CoreDataPost *coreDataPost = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataPost"
                                                                           inManagedObjectContext:context];
                
                [self.services photoById:post.photoId completionBlock:^(UIImage *image) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        coreDataPost.identifier = post.entityId;
                        coreDataPost.imageId = post.photoId;
                        coreDataPost.imageData = UIImageJPEGRepresentation(image, 1.0f);
                        coreDataPost.thumbnailId = post.thumbnailId;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(image);
                        });
                    });
                }];
            }];
        }
    } else {
        NSLog(@"%@", error);
    }
}

#pragma Mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

- (NSMutableArray *)requestedPosts {
    if (!_requestedPosts) {
        _requestedPosts = [[NSMutableArray alloc] init];
    }
    
    return _requestedPosts;
}

@end
