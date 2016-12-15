//
//  TopPostHeaderTableViewCell.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/15/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "TopPostHeaderTableViewCell.h"

@implementation TopPostHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.height / 2;
    self.profilePhotoImageView.layer.masksToBounds = YES;
    self.profilePhotoImageView.layer.borderWidth = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
