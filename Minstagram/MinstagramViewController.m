//
//  MinstagramViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/1/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "MinstagramViewController.h"
#import "Minstagram-Swift.h"
#import "FilterViewController.h"

@interface MinstagramViewController () <FusumaDelegate>

@end

@implementation MinstagramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 0) {
        self.previousTabIndex = 0;
    } else if (item.tag == 1) {
        self.previousTabIndex = 1;
    } else if (item.tag == 2) {
        FusumaViewController *fvc = [[FusumaViewController alloc] init];
        fvc.delegate = self;
        fvc.hasVideo = NO;
        
        [self presentViewController:fvc animated:YES completion:nil];
    } else if (item.tag == 3) {
        self.previousTabIndex = 3;
    }
}

#pragma Mark - Fusuma View Controller Delegate Methods

- (void)fusumaCameraRollUnauthorized {
    
}

- (void)fusumaVideoCompletedWithFileURL:(NSURL *)fileURL {
    // video is not supported
}

- (void)fusumaClosed {
    self.selectedIndex = self.previousTabIndex;
}

- (void)fusumaImageSelected:(UIImage *)image {
    FilterViewController *fvc = [self.viewControllers objectAtIndex:2];
    fvc.image = image;
}

- (void)fusumaDismissedWithImage:(UIImage *)image {
    
}

@end
