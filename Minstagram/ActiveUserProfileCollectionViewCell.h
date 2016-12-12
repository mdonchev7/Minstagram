//
//  MyProfileCollectionViewCell.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/6/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveUserProfileCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) NSString *postId;

@end
