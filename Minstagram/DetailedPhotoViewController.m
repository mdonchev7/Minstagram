//
//  DetailedPhotoViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/21/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <KinveyKit/KinveyKit.h>

#import "DetailedPhotoViewController.h"
#import "NSString+FontAwesome.h"
#import "LikersTableViewController.h"
#import "BackendServices.h"
#import "UserViewController.h"
#import "Repository.h"

@interface DetailedPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIView *likesContainer;
@property (weak, nonatomic) IBOutlet UILabel *postedOnLabel;

@property (nonatomic) KinveyPost *post;
@property (nonatomic) BackendServices *services;
@property (nonatomic) Repository *repository;

@end

@implementation DetailedPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [self.activityIndicator startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.likeButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:25.0f]];
    [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart-o"]
                     forState:UIControlStateNormal];
    [self.commentButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:26.0f]];
    [self.commentButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-comment-o"] forState:UIControlStateNormal];
    [self.heartLabel setFont:[UIFont fontWithName:@"FontAwesome" size:12.0f]];
    [self.heartLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"]];
    
    [self.usernameLabel setText:self.username];
    
    self.profilePhotoImageView.image = [UIImage imageNamed:@"user-default"];
    self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.height / 2;
    self.profilePhotoImageView.layer.masksToBounds = YES;
    self.profilePhotoImageView.layer.borderWidth = 0;
    
    [self.repository imageByPostId:self.postId completionBlock:^(UIImage *image) {
        [self.photoImageView setImage:image];
        self.photoImageView.userInteractionEnabled = YES;
        [self.activityIndicator setHidesWhenStopped:YES];
        [self.activityIndicator stopAnimating];
    }];
    
    [self.services postById:self.postId completionBlock:^(KinveyPost *post) {
        self.post = post;
        
        [self.likesLabel setText:[NSString stringWithFormat:@"%lu likes", (unsigned long)[post.likers count]]];
        [self setDate:post.postedOn];
        
        [self.likesContainer setHidden:NO];
        
        if ([post.likers containsObject:[KCSUser activeUser].username]) {
            [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"] forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)likeUnlikePhoto:(id)sender {
    KCSUser *activeUser = [KCSUser activeUser];
    
    NSMutableArray *likers = [NSMutableArray arrayWithArray:self.post.likers];
    NSMutableArray *likedPosts = [activeUser getValueForAttribute:@"liked posts"];
    
    if ([likers containsObject:activeUser.username]) {
        [likers removeObject:activeUser.username];
        [likedPosts removeObject:self.postId];
        [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart-o"] forState:UIControlStateNormal];
    } else {
        [likers addObject:activeUser.username];
        [likedPosts addObject:self.postId];
        [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"] forState:UIControlStateNormal];
    }
    
    [activeUser setValue:likedPosts forAttribute:@"liked posts"];
    [activeUser saveWithCompletionBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            
        } else {
            NSLog(@"user save error: %@", error);
        }
    }];
    
    self.post.likers = likers;
    
    [self.services savePost:self.post completionBlock:^(KinveyPost *savedPost) {
        [self.likesLabel setText:[NSString stringWithFormat:@"%lu likes", (unsigned long)[savedPost.likers count]]];
    }];
}

- (IBAction)commentOnPhoto:(UIButton *)sender {
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

- (void)setDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    [self.postedOnLabel setText:[NSString stringWithFormat:@"%ld %@, %ld", (long)[components day], [self monthFromNumber:[components month]], (long)[components year]]];
    [self.postedOnLabel setHidden:NO];
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

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

- (Repository *)repository {
    if (!_repository) {
        _repository = [[Repository alloc] init];
    }
    
    return _repository;
}

@end
