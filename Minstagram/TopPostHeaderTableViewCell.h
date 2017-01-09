//
//  TopPostHeaderTableViewCell.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/15/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostHeaderTableViewCellContainerView.h"

@interface TopPostHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet PostHeaderTableViewCellContainerView *containerView;

@end
