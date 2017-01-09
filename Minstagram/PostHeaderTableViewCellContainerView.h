//
//  PostHeaderTableViewCellContainerView.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/9/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostHeaderTableViewCellContainerView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedTimeAgoLabel;

@end
