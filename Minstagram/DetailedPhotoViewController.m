//
//  DetailedPhotoViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/21/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <KinveyKit/KinveyKit.h>

#import "DetailedPhotoViewController.h"
#import "Post.h"
#import "NSString+FontAwesome.h"
#import "LikersTableViewController.h"
#import "BackendServices.h"
#import "UserViewController.h"

@interface DetailedPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedOnLabel;

@property (nonatomic) Post *post;
@property (nonatomic) BackendServices *services;

@end

@implementation DetailedPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.likeButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:25.0f]];
    [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart-o"] forState:UIControlStateNormal];
    [self.commentButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:26.0f]];
    [self.commentButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-comment-o"] forState:UIControlStateNormal];
    [self.heartLabel setFont:[UIFont fontWithName:@"FontAwesome" size:12.0f]];
    [self.heartLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"]];
    
    [self.usernameLabel setText:self.username];
    
    self.profilePhotoImageView.image = [UIImage imageNamed:@"user-default"];
    self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.height / 2;
    self.profilePhotoImageView.layer.masksToBounds = YES;
    self.profilePhotoImageView.layer.borderWidth = 0;
    
    [self.services postById:self.postId completionBlock:^(Post *post) {
        [self.likesLabel setText:[NSString stringWithFormat:@"%lu likes", (unsigned long)[post.likers count]]];
        self.post = post;
        [self setPostedOnDate];
        
        [self.services photoById:post.photoId completionBlock:^(UIImage *image) {
            [self.photoImageView setImage:image];
            self.photoImageView.userInteractionEnabled = YES;
            [self.activityIndicator setHidesWhenStopped:YES];
            [self.activityIndicator stopAnimating];
        }];
    }];
}

- (IBAction)likeUnlikePhoto:(id)sender {
    KCSUser *activeUser = [KCSUser activeUser];
    
    NSMutableArray *likers = [NSMutableArray arrayWithArray:self.post.likers];
    
    if ([likers containsObject:activeUser.username]) {
        [likers removeObject:activeUser.username];
    } else {
        [likers addObject:activeUser.username];
    }
    
    self.post.likers = likers;
    
    [self.services savePost:self.post
            completionBlock:^(Post *savedPost) {
                [self.likesLabel setText:[NSString stringWithFormat:@"%lu likes", (unsigned long)[savedPost.likers count]]];
            }];
}

- (IBAction)commentPhoto:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Oops..."
                                message:@"Commenting is not implemented yet. We hope it will be within the next update."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setPostedOnDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.post.postedOn];
    [self.postedOnLabel setText:[NSString stringWithFormat:@"%ld %@, %ld", (long)[components day], [self monthFromNumber:[components month]], (long)[components year]]];
}

- (NSString *)monthFromNumber:(NSInteger)number {
    switch (number) {
        case 1:
            return @"January";
            break;
        case 2:
            return @"February";
            break;
        case 3:
            return @"March";
            break;
        case 4:
            return @"April";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"August";
            break;
        case 9:
            return @"September";
            break;
        case 10:
            return @"October";
            break;
        case 11:
            return @"November";
            break;
        case 12:
            return @"December";
            break;
        default:
            return @"Invalid";
            break;
    }
}

#pragma mark - Navigation

- (IBAction)navigateToLikersTableViewController:(UITapGestureRecognizer *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LikersTableViewController *ltvc = [sb instantiateViewControllerWithIdentifier:@"Likers Table View Controller"];
    ltvc.post = self.post;
    
    [self.navigationController pushViewController:ltvc animated:YES];
}

- (IBAction)navigateToUserViewController:(UITapGestureRecognizer *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    uvc.username = self.usernameLabel.text;
    [self.navigationController showViewController:uvc sender:self];
}

#pragma mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
