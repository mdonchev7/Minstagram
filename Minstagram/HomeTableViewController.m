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
#import "UIImage+Helpers.h"
#import "Relation.h"
#import "Post.h"
#import "BackendServices.h"

@interface HomeTableViewController ()

@property (nonatomic) NSMutableArray *postIds;
@property (nonatomic) NSMutableArray *following;
@property (nonatomic) KCSAppdataStore *postsStore;

@property (nonatomic) BackendServices *services;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTabBarItemIcons];
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
                                   }
                               }];
                           }
                       }
     ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.postIds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    [cell.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
    cell.profilePhotoImageView.layer.cornerRadius = cell.profilePhotoImageView.frame.size.height / 2;
    cell.profilePhotoImageView.layer.masksToBounds = YES;
    cell.profilePhotoImageView.layer.borderWidth = 0;
    
    [self.services postById:self.postIds[indexPath.row]
             completionBlock:^(Post *post) {
                     NSString *timeSincePosted = [self formattedTimeSincePostedFromDate:post.postedOn ToDate:[NSDate date]];
                     [cell.timeSincePostedLabel setText:timeSincePosted];
             }];
    
    cell.photoImageView.image = nil;
    [UIImage loadWithPostId:self.postIds[indexPath.row]
                   callback:^(UIImage *image, NSArray *likers) {
                       cell.photoImageView.image = image;
                   }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper Methods

-(NSString *)formattedTimeSincePostedFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger seconds = [calendar components:NSCalendarUnitSecond fromDate:fromDate toDate:toDate options:0].second;
    
    if (seconds > 604799) { // >= a week
        return [NSString stringWithFormat:@"%liw", seconds / 60 / 60 / 24 / 7];
    } else if (seconds > 86399) { // >= a day
        return [NSString stringWithFormat:@"%lid", seconds / 60 / 60 / 24];
    } else if (seconds > 3599) { // >= an hour
        return [NSString stringWithFormat:@"%lih", seconds / 60 / 60];
    } else if (seconds > 59) { // >= a minute
        return [NSString stringWithFormat:@"%lim", seconds / 60];
    } else { // >= a second
        return [NSString stringWithFormat:@"%lis", (long)seconds];
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

@end
