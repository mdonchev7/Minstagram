//
//  FollowerTableViewCell.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/11/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end
