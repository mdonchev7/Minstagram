//
//  SignInViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/6/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "LoginViewController.h"
#import "BackendServices.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (nonatomic) BackendServices *services;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.services loginWithUsername:@"prelogin"
                            password:@"prelogin"
                     completionBlock:^(KCSUser *user, KCSUserActionResult result) {
                         NSLog(@"prelogin was successful");
                     }];
}

- (IBAction)login:(UIButton *)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [self.services loginWithUsername:username password:password completionBlock:^(KCSUser *user, KCSUserActionResult result) {
        NSLog(@"%@", [KCSUser activeUser]);
        NSLog(@"Logedd in successfully.");
        
        [self performSegueWithIdentifier:@"Present Tab Bar Controller From Login" sender:self];
    }];
}

#pragma Mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
