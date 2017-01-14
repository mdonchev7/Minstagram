//
//  SignUpViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/5/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "SignUpEmailViewController.h"
#import "SignUpFullNameViewController.h"
#import "BackendServices.h"

@interface SignUpEmailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (nonatomic) BackendServices *services;

@end

@implementation SignUpEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)nextStep:(UIButton *)sender {
    NSString *email = self.emailField.text;
    
    [self.services isEmailTaken:email completionBlock:^(NSString *email, BOOL alreadyTaken) {
        if (alreadyTaken) {
            NSLog(@"email is already in use by another user.");
        } else {
            [self performSegueWithIdentifier:@"Present Full Name Verification View Controller" sender:self];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationVC = [segue destinationViewController];
    
    if ([destinationVC isKindOfClass:[SignUpFullNameViewController class]]) {
        ((SignUpFullNameViewController *)destinationVC).email = self.emailField.text;
    }
}

- (IBAction)navigateToLoginViewController:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma Mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
