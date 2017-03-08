//
//  OptionsTableViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/11/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "OptionsTableViewController.h"

#import <KinveyKit/KinveyKit.h>

@interface OptionsTableViewController ()

@end

@implementation OptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (IBAction)logOut:(UITapGestureRecognizer *)sender {
    [[KCSUser activeUser] logout];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"Login Parent View Controller"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
