//
//  PostTableViewCell.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/9/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIView *likesContainer;

@property (nonatomic) NSString *postId;

@end
