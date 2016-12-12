//
//  UserViewController.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/23/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) NSString *username;

@end
