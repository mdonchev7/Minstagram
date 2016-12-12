//
//  PostTableViewCell.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/9/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "PostTableViewCell.h"
#import "NSString+FontAwesome.h"

@implementation PostTableViewCell

@dynamic imageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.likeButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:27.0f];
    [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart-o"] forState:UIControlStateNormal];
    self.commentButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:27.0f];
    [self.commentButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-comment-o"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
