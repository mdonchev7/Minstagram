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

- (void)thumbnailByPostId:(NSString *)postId
          completionBlock:(void (^)(UIImage *))completionBlock {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
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
            [self.services postById:postId
                    completionBlock:^(KinveyPost *post) {
                        [self.services photoById:post.thumbnailId
                                 completionBlock:^(UIImage *image) {
                                     CoreDataPost *coreDataPost = [NSEntityDescription
                                                                   insertNewObjectForEntityForName:@"CoreDataPost"
                                                                   inManagedObjectContext:context];
                                     
                                     coreDataPost.identifier = post.entityId;
                                     coreDataPost.thumbnail = UIImageJPEGRepresentation(image, 1.0f);
                                     coreDataPost.likes = [post.likers count];
                                     coreDataPost.postedOn = post.postedOn;
                                     coreDataPost.photoId = post.photoId;
                                     
                                     completionBlock(image);
                                 }];
                    }];
        }
    } else {
        NSLog(@"%@", error);
    }
}

- (void)postById:(NSString *)postId
     completionBlock:(void (^)(CoreDataPost *))completionBlock {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
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
                [self.services photoById:post.photoId
                         completionBlock:^(UIImage *image) {
                             post.photo = UIImageJPEGRepresentation(image, 1.0f);
                             completionBlock(post);
                         }];
            } else {
                completionBlock(post);
            }
        } else {
            [self.services postById:postId
                    completionBlock:^(KinveyPost *post) {
                        CoreDataPost *coreDataPost =
                        [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataPost"
                                                                                   inManagedObjectContext:context];
                        
                        coreDataPost.identifier = post.entityId;
                        coreDataPost.likes = [post.likers count];
                        coreDataPost.postedOn = post.postedOn;
                        coreDataPost.photoId = post.photoId;
                        
                        [self.services photoById:post.thumbnailId
                                 completionBlock:^(UIImage *image) {
                                     coreDataPost.thumbnail = UIImageJPEGRepresentation(image, 1.0f);
                                 }];
                        [self.services photoById:post.photoId
                                 completionBlock:^(UIImage *image) {
                                     coreDataPost.photo = UIImageJPEGRepresentation(image, 1.0f);
                                     completionBlock(coreDataPost);
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
