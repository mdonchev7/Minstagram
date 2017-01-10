//
//  FeedTableViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/10/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "HomeTableViewController.h"
#import "NSString+FontAwesome.h"
#import "UIImage+FontAwesome.h"
#import "PostTableViewCell.h"
#import "Relation.h"
#import "BackendServices.h"
#import "UserViewController.h"
#import "PostHeaderTableViewCell.h"
#import "TopPostHeaderTableViewCell.h"
#import "PostHeaderTableViewCellContainerView.h"

@interface HomeTableViewController ()

@property (nonatomic) NSMutableArray *postIds;
@property (nonatomic) NSMutableArray *following;
@property (nonatomic) BackendServices *services;
@property (nonatomic) NSMutableDictionary *userByPostId;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-20.0f, 0.0f, 0.0f, 0.0f);
    
    [self setTabBarItemIcons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.postIds removeAllObjects];
    
    [self.services followingByUsername:[[KCSUser activeUser] username]
                       completionBlock:^(NSArray *following) {
                           for (Relation *relation in following) {
                               [self.services userByUsername:relation.beingFollowed
                                             completionBlock:^(KCSUser *user) {
                                                 for (NSString *postId in [user getValueForAttribute:@"posts"]) {
                                                     [self.postIds addObject:postId];
                                                     [self.tableView reloadData];
                                                     
                                                     [self.userByPostId setValue:user forKey:postId];
                                                 }
                                             }];
                           }
                       }
     ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.postIds count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"reusable cell" forIndexPath:indexPath];
    [cell awakeFromNib];
    
    if (cell == nil) {
        cell = [[PostTableViewCell alloc] init];
    }
    
    cell.postId = self.postIds[indexPath.section];
    
    cell.photoImageView.image = nil;
    
    cell.photoImageView.userInteractionEnabled = NO;
    cell.photoImageView.tag = indexPath.row;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewDoubleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [cell.photoImageView addGestureRecognizer:tapRecognizer];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.services postById:self.postIds[indexPath.section]
            completionBlock:^(KinveyPost *post) {
                [cell.likesLabel setText:[NSString stringWithFormat:@"%lu likes", (unsigned long)[post.likers count]]];

                [cell.likeButton setHidden:NO];
                [cell.commentButton setHidden:NO];
                [cell.likesContainer setHidden:NO];
                
                if ([post.likers containsObject:[KCSUser activeUser].username]) {
                    [cell.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"] forState:UIControlStateNormal];
                }
                
                [self.services photoById:post.photoId
                         completionBlock:^(UIImage *image) {
                             [cell.photoImageView setImage:image];
                             cell.photoImageView.userInteractionEnabled = YES;
                         }];
            }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 104.0f;
    }
    
    return 69.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        TopPostHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"top header"];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleContainerViewTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [cell.containerView addGestureRecognizer:tapRecognizer];
        
        [self.services postById:self.postIds[section]
                completionBlock:^(KinveyPost *post) {
                    NSString *postedTimeAgo = [self formattedTimeSincePostedFromDate:post.postedOn ToDate:[NSDate date]];
                    
                    [cell.containerView.postedTimeAgoLabel setText:postedTimeAgo];
                    
                    KCSUser *user = [self.userByPostId valueForKey:post.entityId];
                    [cell.containerView.usernameLabel setText:user.username];
                    
                    NSString *profilePhotoId = [user getValueForAttribute:@"profile photo"];
                    if ([profilePhotoId isEqualToString:@""]) {
                        [cell.containerView.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
                    } else {
                        [self.services photoById:profilePhotoId
                                 completionBlock:^(UIImage *image) {
                                     [cell.containerView.profilePhotoImageView setImage:image];
                                 }];
                    }
                }];
        
        return cell;
    } else {
        PostHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"post header"];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleContainerViewTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [cell.containerView addGestureRecognizer:tapRecognizer];
        
        [self.services postById:self.postIds[section]
                completionBlock:^(KinveyPost *post) {
                    NSString *postedTimeAgo = [self formattedTimeSincePostedFromDate:post.postedOn ToDate:[NSDate date]];
                    [cell.containerView.postedTimeAgoLabel setText:postedTimeAgo];
                    
                    KCSUser *user = [self.userByPostId valueForKey:post.entityId];
                    [cell.containerView.usernameLabel setText:user.username];
                    
                    NSString *profilePhotoId = [user getValueForAttribute:@"profile photo"];
                    if ([profilePhotoId isEqualToString:@""]) {
                        [cell.containerView.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
                    } else {
                        [self.services photoById:profilePhotoId
                                 completionBlock:^(UIImage *image) {
                                     [cell.containerView.profilePhotoImageView setImage:image];
                                 }];
                    }
                }];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Helper Methods

-(NSString *)formattedTimeSincePostedFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    float seconds = [calendar components:NSCalendarUnitSecond fromDate:fromDate toDate:toDate options:0].second;
    
    if (seconds > 604799) { // >= a week
        return [NSString stringWithFormat:@"%.0fw", floorf(seconds / 60 / 60 / 24 / 7)];
    } else if (seconds > 86399) { // >= a day
        return [NSString stringWithFormat:@"%.0fd", floorf(seconds / 60 / 60 / 24)];
    } else if (seconds > 3599) { // >= an hour
        return [NSString stringWithFormat:@"%.0fh", floorf(seconds / 60 / 60)];
    } else if (seconds > 59) { // >= a minute
        return [NSString stringWithFormat:@"%.0fm", floorf(seconds / 60)];
    } else { // >= a second
        return [NSString stringWithFormat:@"%.0lis", (long)seconds];
    }
}

- (void)setTabBarItemIcons {
    UITabBarController *tabBarController = (UITabBarController *)self.parentViewController.parentViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    [UITabBar appearance].tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:255];
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    UIImage *home = [UIImage imageWithIcon:@"fa-home"
                           backgroundColor:[UIColor clearColor]
                                 iconColor:[UIColor
                                            colorWithRed:0.5
                                            green:0.5
                                            blue:0.5
                                            alpha:255]
                                  fontSize:31];
    UIImage *search = [UIImage imageWithIcon:@"fa-search"
                             backgroundColor:[UIColor clearColor]
                                   iconColor:[UIColor colorWithRed:0.5
                                                             green:0.5
                                                              blue:0.5
                                                             alpha:255]
                                    fontSize:31];
    UIImage *share = [UIImage imageWithIcon:@"fa-picture-o"
                            backgroundColor:[UIColor clearColor]
                                  iconColor:[UIColor colorWithRed:0.5
                                                            green:0.5
                                                             blue:0.5
                                                            alpha:255]
                                   fontSize:31];
    UIImage *profile = [UIImage imageWithIcon:@"fa-user"
                              backgroundColor:[UIColor clearColor]
                                    iconColor:[UIColor colorWithRed:0.5
                                                              green:0.5
                                                               blue:0.5
                                                              alpha:255]
                                     fontSize:31];
    
    [tabBarItem1 setImage:home];
    [tabBarItem2 setImage:search];
    [tabBarItem3 setImage:share];
    [tabBarItem4 setImage:profile];
    
    [self.tabBarController.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }];
}

#pragma mark - Navigation

- (void)handleContainerViewTap:(UITapGestureRecognizer *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    NSString *username = ((PostHeaderTableViewCellContainerView *)sender.view).usernameLabel.text;
    uvc.username = username;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold], NSFontAttributeName,nil]];
    
    [self.navigationController pushViewController:uvc animated:YES];
}

- (IBAction)handleLikeButtonTap:(UIButton *)sender {
    PostTableViewCell *cell = (PostTableViewCell *)sender.superview.superview;
    [self likeUnlikePhotoWithCell:cell];
}

- (void)handleImageViewDoubleTap:(UITapGestureRecognizer *)sender {
    PostTableViewCell *cell = (PostTableViewCell *)sender.view.superview.superview;
    
    [self likeUnlikePhotoWithCell:cell];
}

- (void)likeUnlikePhotoWithCell:(PostTableViewCell *)cell {
    KCSUser *activeUser = [KCSUser activeUser];
    
    [self.services postById:cell.postId completionBlock:^(KinveyPost *post) {
        NSMutableArray *likers = [NSMutableArray arrayWithArray:post.likers];
        
        if ([likers containsObject:activeUser.username]) {
            [likers removeObject:activeUser.username];
            [cell.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart-o"] forState:UIControlStateNormal];
        } else {
            [likers addObject:activeUser.username];
            [cell.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"] forState:UIControlStateNormal];
        }
        
        post.likers = likers;
        
        [self.services savePost:post
                completionBlock:^(KinveyPost *savedPost) {
                    [cell.likesLabel setText:[NSString stringWithFormat:@"%lu likes", (unsigned long)[savedPost.likers count]]];
                }];
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

#pragma mark - Lazy Instantiation

- (NSMutableArray *)postIds {
    if (!_postIds) {
        _postIds = [[NSMutableArray alloc] init];
    }
    
    return _postIds;
}

- (NSMutableArray *)following {
    if (!_following) {
        _following = [[NSMutableArray alloc] init];
    }
    
    return _following;
}

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

- (NSMutableDictionary *)userByPostId {
    if (!_userByPostId) {
        _userByPostId = [[NSMutableDictionary alloc] init];
    }
    
    return _userByPostId;
}

@end
