//
//  LikedPostsCollectionViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 3/8/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import "LikedPostsCollectionViewController.h"
#import "DetailedPhotoViewController.h"

#import "BackendServices.h"
#import "Repository.h"

#import "PostCollectionViewCell.h"

@interface LikedPostsCollectionViewController ()

@property (nonatomic) BackendServices *services;
@property (nonatomic) Repository *repository;

@property (nonatomic) NSMutableArray *postIds;

@end

@implementation LikedPostsCollectionViewController

static NSString * const reuseIdentifier = @"reusable cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [[KCSUser activeUser] refreshFromServer:^(NSArray *objects, NSError *error) {
        if (error == nil)  {
            KCSUser *activeUser = [objects firstObject];
            self.postIds = [activeUser getValueForAttribute:@"liked posts"];
            [self.collectionView reloadData];
        } else {
            NSLog(@"error: %@", error);
        }
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.postIds count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[PostCollectionViewCell alloc] init];
    }
    
    cell.postId = self.postIds[indexPath.row];
    
    cell.imageView.image = nil;
    
    [self.repository thumbnailByPostId:self.postIds[indexPath.row] completionBlock:^(UIImage *thumbnail) {
        [cell.imageView setImage:thumbnail];
    }];
    
    return cell;
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

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeMake(screenWidth / 3 - 1, screenWidth / 3 - 1);
    
    return size;
}

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Navigate To Detailed Photo View Controller From Liked Posts View Controller"]) {
        DetailedPhotoViewController *dpvc = [segue destinationViewController];
        dpvc.postId = ((PostCollectionViewCell *)sender).postId;
        dpvc.username = [KCSUser activeUser].username;
    }
}

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
