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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *normalFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *normalFilterLabel;
@property (weak, nonatomic) IBOutlet UIButton *sepiaToneFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *sepiaToneLabel;
@property (weak, nonatomic) IBOutlet UIButton *fadeFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *fadeFilterLabel;
@property (weak, nonatomic) IBOutlet UIButton *monoFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *monoFilterLabel;
@property (weak, nonatomic) IBOutlet UIButton *instantFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *instantFilterLabel;
@property (weak, nonatomic) IBOutlet UIButton *tonalFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *tonalFilterLabel;
@property (weak, nonatomic) IBOutlet UIButton *processFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *processFilterLabel;
@property (weak, nonatomic) IBOutlet UIButton *chromeFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *chromeFilterLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) UIImage *mediumQualityImage;
@property (nonatomic) UIImage *lowQualityImage;

@property (nonatomic) NSString *filter;
@property (nonatomic) UILabel *previouslySelectedFilterLabel;

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
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.frame.size.height);
    
    [self.activityIndicator setHidden:YES];
    [self.shareButton setHidden:NO];
    
    [self hideTabBar];
    
    self.filter = @"Normal";
    
    [self setLabelsInInitialState];
    
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
    
    if (self.previouslySelectedFilterLabel != self.normalFilterLabel) {
        [self setLabelInSelectedState:self.normalFilterLabel];
        self.previouslySelectedFilterLabel = self.normalFilterLabel;
    }
}

- (IBAction)didTapSepiaToneFilter:(UIButton *)sender {
    [self setImageView:self.imageView
                 image:self.mediumQualityImage
        withFilterName:@"CISepiaTone"];
    self.filter = @"CISepiaTone";
    
    if (self.previouslySelectedFilterLabel != self.sepiaToneLabel) {
        [self setLabelInSelectedState:self.sepiaToneLabel];
        self.previouslySelectedFilterLabel = self.sepiaToneLabel;
    }
}

- (IBAction)didTapFadeFilter:(UIButton *)sender {
    [self setImageView:self.imageView
                 image:self.mediumQualityImage
        withFilterName:@"CIPhotoEffectFade"];
    self.filter = @"CIPhotoEffectFade";
    
    if (self.previouslySelectedFilterLabel != self.fadeFilterLabel) {
        [self setLabelInSelectedState:self.fadeFilterLabel];
        self.previouslySelectedFilterLabel = self.fadeFilterLabel;
    }
}

- (IBAction)didTapMonoFilter:(UIButton *)sender {
    [self setImageView:self.imageView
                 image:self.mediumQualityImage
        withFilterName:@"CIPhotoEffectMono"];
    self.filter = @"CIPhotoEffectMono";
    
    if (self.previouslySelectedFilterLabel != self.monoFilterLabel) {
        [self setLabelInSelectedState:self.monoFilterLabel];
        self.previouslySelectedFilterLabel = self.monoFilterLabel;
    }
}

- (IBAction)didTapInstantFilter:(UIButton *)sender {
    [self setImageView:self.imageView
                 image:self.mediumQualityImage
        withFilterName:@"CIPhotoEffectInstant"];
    self.filter = @"CIPhotoEffectInstant";
    
    if (self.previouslySelectedFilterLabel != self.instantFilterLabel) {
        [self setLabelInSelectedState:self.instantFilterLabel];
        self.previouslySelectedFilterLabel = self.instantFilterLabel;
    }
}

- (IBAction)didTapTonalFilter:(UIButton *)sender {
    [self setImageView:self.imageView
                 image:self.mediumQualityImage
        withFilterName:@"CIPhotoEffectTonal"];
    self.filter = @"CIPhotoEffectTonal";
    
    if (self.previouslySelectedFilterLabel != self.tonalFilterLabel) {
        [self setLabelInSelectedState:self.tonalFilterLabel];
        self.previouslySelectedFilterLabel = self.tonalFilterLabel;
    }
}

- (IBAction)didTapProcessFilter:(UIButton *)sender {
    [self setImageView:self.imageView image:self.mediumQualityImage withFilterName:@"CIPhotoEffectProcess"];
    self.filter = @"CIPhotoEffectProcess";
    
    if (self.previouslySelectedFilterLabel != self.processFilterLabel) {
        [self setLabelInSelectedState:self.processFilterLabel];
        self.previouslySelectedFilterLabel = self.processFilterLabel;
    }
}

- (IBAction)didTapChromeFilter:(UIButton *)sender {
    [self setImageView:self.imageView image:self.mediumQualityImage withFilterName:@"CIPhotoEffectChrome"];
    self.filter = @"CIPhotoEffectChrome";
    
    if (self.previouslySelectedFilterLabel != self.chromeFilterLabel) {
        [self setLabelInSelectedState:self.chromeFilterLabel];
        self.previouslySelectedFilterLabel = self.chromeFilterLabel;
    }
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
    [self setButton:self.normalFilterButton backgroundImageWithFilterName:@"Normal"];
    [self setButton:self.sepiaToneFilterButton backgroundImageWithFilterName:@"CISepiaTone"];
    [self setButton:self.fadeFilterButton backgroundImageWithFilterName:@"CIPhotoEffectFade"];
    [self setButton:self.monoFilterButton backgroundImageWithFilterName:@"CIPhotoEffectMono"];
    [self setButton:self.instantFilterButton backgroundImageWithFilterName:@"CIPhotoEffectInstant"];
    [self setButton:self.tonalFilterButton backgroundImageWithFilterName:@"CIPhotoEffectTonal"];
    [self setButton:self.processFilterButton backgroundImageWithFilterName:@"CIPhotoEffectProcess"];
    [self setButton:self.chromeFilterButton backgroundImageWithFilterName:@"CIPhotoEffectChrome"];
}

- (void)setButton:(UIButton *)button backgroundImageWithFilterName:(NSString *)filterName {
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

- (void)setLabelInSelectedState:(UILabel *)label {
    [label setFont:[UIFont fontWithName:@"Proxima Nova-Semibold" size:13.0f]];
    [label setFont:[label.font fontWithSize:13.0f]]; // the upper row does not affect the size for some reason
    [label setTextColor:[UIColor blackColor]];
    
    [self.previouslySelectedFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
    [self.previouslySelectedFilterLabel setTextColor:[UIColor grayColor]];
}

- (void)setLabelsInInitialState {
    self.previouslySelectedFilterLabel = self.normalFilterLabel;
    [self.normalFilterLabel setTextColor:[UIColor blackColor]];
    [self.sepiaToneLabel setTextColor:[UIColor grayColor]];
    [self.fadeFilterLabel setTextColor:[UIColor grayColor]];
    [self.monoFilterLabel setTextColor:[UIColor grayColor]];
    [self.instantFilterLabel setTextColor:[UIColor grayColor]];
    [self.tonalFilterLabel setTextColor:[UIColor grayColor]];
    [self.processFilterLabel setTextColor:[UIColor grayColor]];
    [self.chromeFilterLabel setTextColor:[UIColor grayColor]];
    
    [self.normalFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova-Semibold" size:13.0f]];
    [self.normalFilterLabel setFont:[self.normalFilterLabel.font fontWithSize:13.0f]]; // the upper row does not affect the size for some reason
    [self.sepiaToneLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
    [self.fadeFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
    [self.monoFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
    [self.instantFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
    [self.tonalFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
    [self.processFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
    [self.chromeFilterLabel setFont:[UIFont fontWithName:@"Proxima Nova" size:13.0f]];
}

- (void)hideAllViews {
    [self.headerView setHidden:YES];
    [self.imageView setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.titleLabel setHidden:YES];
}

- (void)showAllViews {
    [self.headerView setHidden:NO];
    [self.imageView setHidden:NO];
    [self.scrollView setHidden:NO];
    [self.titleLabel setHidden:NO];
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
