//
//  PostHeaderTableViewCell.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/15/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (weak, nonatomic) IBOutlet UILabel *postedTimeAgoLabel;

@end
