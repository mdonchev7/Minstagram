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
        if ([matches count] == 1) {
            CoreDataPost *post = [matches firstObject];
            UIImage *thumbnail = [UIImage imageWithData:post.thumbnail];
            completionBlock(thumbnail);
        } else if ([matches count] == 0) {
            [self.services postById:postId completionBlock:^(KinveyPost *post) {
                [self.services photoById:post.thumbnailId completionBlock:^(UIImage *image) {
                    CoreDataPost *coreDataPost = [NSEntityDescription
                                                  insertNewObjectForEntityForName:@"CoreDataPost"
                                                  inManagedObjectContext:context];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        coreDataPost.thumbnail = UIImageJPEGRepresentation(image, 1.0f);
                    });
                    
                    coreDataPost.identifier = post.entityId;
                    coreDataPost.photoId = post.photoId;
                    
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
        if ([matches count] == 1) {
            CoreDataPost *post = [matches firstObject];
            
            if (post.photo == nil) {
                [self.services photoById:post.photoId completionBlock:^(UIImage *image) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        post.photo = UIImageJPEGRepresentation(image, 1.0f);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(image);
                        });
                    });
                }];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage imageWithData:post.photo];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(image);
                    });
                });
            }
        } else {
            [self.services postById:postId completionBlock:^(KinveyPost *post) {
                CoreDataPost *coreDataPost = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataPost"
                                                                           inManagedObjectContext:context];
                
                [self.services photoById:post.photoId completionBlock:^(UIImage *image) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        coreDataPost.photo = UIImageJPEGRepresentation(image, 1.0f);
                        
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

@end
