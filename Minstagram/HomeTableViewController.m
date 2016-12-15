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
#import "Post.h"
#import "BackendServices.h"
#import "UserViewController.h"
#import "PostHeaderTableViewCell.h"
#import "TopPostHeaderTableViewCell.h"

@interface HomeTableViewController ()

@property (nonatomic) NSMutableArray *postIds;
@property (nonatomic) NSMutableArray *following;
@property (nonatomic) KCSAppdataStore *postsStore;

@property (nonatomic) BackendServices *services;
@property (nonatomic) NSMutableDictionary *userByPostId;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTabBarItemIcons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"billabong" size:31], NSFontAttributeName,nil]];
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
    
    cell.photoImageView.image = nil;
    
    [self.services postById:self.postIds[indexPath.section]
            completionBlock:^(Post *post) {
                [self.services photoById:post.photoId
                         completionBlock:^(UIImage *image) {
                             [cell.photoImageView setImage:image];
                         }];
            }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 96.0f;
    }
    
    return 49.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        TopPostHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"top header"];
        
        [self.services postById:self.postIds[section]
                completionBlock:^(Post *post) {
                    NSString *postedTimeAgo = [self formattedTimeSincePostedFromDate:post.postedOn ToDate:[NSDate date]];
                    
                    [cell.postedTimeAgoLabel setText:postedTimeAgo];
                    
                    KCSUser *user = [self.userByPostId valueForKey:post.entityId];
                    [cell.usernameButton setTitle:user.username forState:UIControlStateNormal];
                    
                    NSString *profilePhotoId = [user getValueForAttribute:@"profile photo"];
                    if ([profilePhotoId isEqualToString:@""]) {
                        [cell.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
                    } else {
                        [self.services photoById:profilePhotoId
                                 completionBlock:^(UIImage *image) {
                                     [cell.profilePhotoImageView setImage:image];
                                 }];
                    }
                }];
        
        return cell;
    } else {
        PostHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"post header"];
        
        [self.services postById:self.postIds[section]
                completionBlock:^(Post *post) {
                    NSString *postedTimeAgo = [self formattedTimeSincePostedFromDate:post.postedOn ToDate:[NSDate date]];
                    [cell.postedTimeAgoLabel setText:postedTimeAgo];
                    
                    KCSUser *user = [self.userByPostId valueForKey:post.entityId];
                    [cell.usernameButton setTitle:user.username forState:UIControlStateNormal];
                    
                    NSString *profilePhotoId = [user getValueForAttribute:@"profile photo"];
                    if ([profilePhotoId isEqualToString:@""]) {
                        [cell.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
                    } else {
                        [self.services photoById:profilePhotoId
                                 completionBlock:^(UIImage *image) {
                                     [cell.profilePhotoImageView setImage:image];
                                 }];
                    }
                }];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (IBAction)navigateToUserViewController:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    uvc.username = ((UIButton *)sender).titleLabel.text;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold], NSFontAttributeName,nil]];
    
    [self.navigationController pushViewController:uvc animated:YES];
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
