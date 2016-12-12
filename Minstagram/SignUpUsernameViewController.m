//
//  SignUpUsernameViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/8/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "SignUpUsernameViewController.h"
#import "BackendServices.h"

@interface SignUpUsernameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;

@property (nonatomic) BackendServices *services;

@end

@implementation SignUpUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)nextStep:(UIButton *)sender {
    NSString *username = self.usernameField.text;
    
    [self.services isUsernameTaken:username completionBlock:^(NSString *username, BOOL alreadyTaken) {
        if (alreadyTaken) {
            NSLog(@"Username is already taken, choose another one.");
        } else {
            [self.services registerWithUsername:username
                                       password:self.password
                                fieldsAndValues:@{@"email": self.email,
                                                  @"full name": self.fullName,
                                                  @"posts": @[],
                                                  @"liked posts": @[],
                                                  @"profile photo": @""}
                                completionBlock:^(KCSUser *user, KCSUserActionResult result) {
                                    [self performSegueWithIdentifier:@"Present Tab Bar Controller From Signup" sender:self];
                                }];
        }
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
