//
//  FilterViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/30/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "FilterViewController.h"
#import "MinstagramViewController.h"
#import "UIImage+Filter.h"
#import "UIImage+Resize.h"
#import "Post.h"
#import "BackendServices.h"

#import <KinveyKit/KinveyKit.h>

@interface FilterViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *filtersContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *hefeButton;
@property (weak, nonatomic) IBOutlet UIButton *riseButton;
@property (weak, nonatomic) IBOutlet UIButton *monoButton;
@property (weak, nonatomic) IBOutlet UIButton *larkButton;
@property (weak, nonatomic) IBOutlet UIButton *junoButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic) UIImage *mediumQualityImage;
@property (nonatomic) UIImage *lowQualityImage;

@property (nonatomic) NSString *filter;

@property (nonatomic) BackendServices *services;

@end

@implementation FilterViewController

#pragma Mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.activityIndicator setHidden:YES];
    [self.shareButton setHidden:NO];
    
    [self hideTabBar];
    
    self.filter = @"Normal";
    
    CGSize lowQualitySize = CGSizeMake(70.0f, 70.0f);
    CGSize mediumQualitySize = CGSizeMake(375.0f, 375.0f);
    
    self.lowQualityImage = [UIImage imageWithImage:self.image scaledToSize:lowQualitySize];
    self.mediumQualityImage = [UIImage imageWithImage:self.image scaledToSize:mediumQualitySize];
    
    if (self.image) {
        [self showAllViews];
        
        [self.imageView setImage:self.mediumQualityImage];
        
        [self setButtonImages];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideAllViews];
    [self showTabBar];
}

#pragma Mark - Touch Events

- (IBAction)didTapClose:(id)sender {
    [self.tabBarController setSelectedIndex:((MinstagramViewController *)self.tabBarController).previousTabIndex];
}

- (IBAction)didTapShare:(UIButton *)sender {
    CGSize uploadSize = CGSizeMake(640.0f, 640.0f);
    CGSize thumbnailSize = CGSizeMake(140.0f, 140.0f);
    
    UIImage *image = [UIImage imageWithImage:self.image scaledToSize:uploadSize];
    UIImage *thumbnail = [UIImage imageWithImage:self.image scaledToSize:thumbnailSize];
    
    if (![self.filter isEqualToString:@"Normal"]){
        image = [UIImage applyFilterOnImage:image withFilterName:self.filter];
        thumbnail = [UIImage applyFilterOnImage:thumbnail withFilterName:self.filter];
    }
    
    [self.shareButton setHidden:YES];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    
    KCSMetadata *metaData = [[KCSMetadata alloc] init];
    [metaData setGloballyReadable:YES];
    
    [self.services uploadPhoto:image
                   withOptions:@{KCSFileACL: metaData}
               completionBlock:^(KCSFile *uploadInfo) {
                   [self.services uploadPhoto:thumbnail
                                  withOptions:@{KCSFileACL: metaData}
                              completionBlock:^(KCSFile *thumbnailUploadInfo) {
                                  [self.services uploadPostWithUploadInfo:uploadInfo thumbnailUploadInfo:thumbnailUploadInfo completionBlock:^{
                                      [self.tabBarController setSelectedIndex:3];
                                  }];
                              }];
               }];
}

- (IBAction)didTapNormalFilter:(UIButton *)sender {
    [self.imageView setImage:self.mediumQualityImage];
    self.filter = @"Normal";
}

- (IBAction)didTapHefeFilter:(UIButton *)sender {
    [self setImageView:self.imageView image:self.mediumQualityImage withFilterName:@"CISepiaTone"];
    self.filter = @"CISepiaTone";
}

- (IBAction)didTapRiseFilter:(UIButton *)sender {
    [self setImageView:self.imageView image:self.mediumQualityImage withFilterName:@"CIPhotoEffectProcess"];
    self.filter = @"CIPhotoEffectProcess";
}

- (IBAction)didTapMonoFilter:(UIButton *)sender {
    [self setImageView:self.imageView image:self.mediumQualityImage withFilterName:@"CIPhotoEffectMono"];
    self.filter = @"CIPhotoEffectMono";
}

- (IBAction)didTapLarkFilter:(UIButton *)sender {
    [self setImageView:self.imageView image:self.mediumQualityImage withFilterName:@"CIPhotoEffectChrome"];
    self.filter = @"CIPhotoEffectChrome";
}

- (IBAction)didTapJunoFilter:(UIButton *)sender {
    [self setImageView:self.imageView image:self.mediumQualityImage withFilterName:@"CIPhotoEffectInstant"];
    self.filter = @"CIPhotoEffectInstant";
}

#pragma Mark - Helper Methods

- (void)hideTabBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    float fHeight = screenRect.size.height;
    
    for (UIView *view in self.tabBarController.view.subviews) {
        if ([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor blackColor];
        }
    }
}

- (void)showTabBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - self.tabBarController.tabBar.frame.size.height;
    
    for (UIView *view in self.tabBarController.view.subviews) {
        if ([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
}

- (void)setButtonImages {
    [self setButton:self.normalButton imageWithFilterName:@"Normal"];
    [self setButton:self.hefeButton imageWithFilterName:@"CISepiaTone"];
    [self setButton:self.monoButton imageWithFilterName:@"CIPhotoEffectMono"];
    [self setButton:self.larkButton imageWithFilterName:@"CIPhotoEffectChrome"];
    [self setButton:self.junoButton imageWithFilterName:@"CIPhotoEffectInstant"];
    [self setButton:self.riseButton imageWithFilterName:@"CIPhotoEffectProcess"];
}

- (void)setButton:(UIButton *)button imageWithFilterName:(NSString *)filterName {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([filterName isEqualToString:@"Normal"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setBackgroundImage:self.lowQualityImage forState:UIControlStateNormal];
            });
        } else {
            UIImage *image = [UIImage applyFilterOnImage:self.lowQualityImage withFilterName:filterName];
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setBackgroundImage:image forState:UIControlStateNormal];
            });
        }
    });
}

- (void)setImageView:(UIImageView *)imageView image:(UIImage *)image withFilterName:(NSString *)filterName {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage applyFilterOnImage:self.mediumQualityImage withFilterName:filterName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:image];
        });
    });
}

- (void)hideAllViews {
    [self.headerView setHidden:YES];
    [self.imageView setHidden:YES];
    [self.filtersContainerView setHidden:YES];
}

- (void)showAllViews {
    [self.headerView setHidden:NO];
    [self.filtersContainerView setHidden:NO];
    [self.imageView setHidden:NO];
}

#pragma Mark - Delegate Methods

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
