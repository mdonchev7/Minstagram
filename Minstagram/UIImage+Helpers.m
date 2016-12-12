//
//  UIImage+Helpers.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/7/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "UIImage+Helpers.h"
#import "Post.h"

#import <KinveyKit/KinveyKit.h>

@implementation UIImage (Helpers)

+ (void) loadWithPostId:(NSString *)postId callback:(void (^)(UIImage *image, NSArray *likers))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        KCSAppdataStore *postsStore =
        [KCSAppdataStore storeWithOptions:@{KCSStoreKeyCollectionName: @"Posts",
                                            KCSStoreKeyCollectionTemplateClass: [Post class]}];
        
        // download post entity
        [postsStore loadObjectWithID:postId withCompletionBlock:^(NSArray *objects, NSError *error) {
            if (error == nil) {
                Post *post = [objects firstObject];
                
                // download image file
                [KCSFileStore downloadData:post.photoId
                           completionBlock:^(NSArray *downloadedResources, NSError *error) {
                    if (error == nil) {
                        KCSFile* file = downloadedResources[0];
                        NSData* fileData = file.data;
                        
                        // get back on the main queue and execute the callback
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *image = [UIImage imageWithData:fileData];
                            callback(image, post.likers);
                        });
                        
                        NSLog(@"File download was successful");
                    } else {
                        NSLog(@"File download was not successful: %@", error);
                    }
                } progressBlock:nil];
            } else {
                NSLog(@"Error occurred during post fetch: %@", error);
            }
        } withProgressBlock:nil];
    });
}

@end
