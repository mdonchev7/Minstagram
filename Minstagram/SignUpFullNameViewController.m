//
//  SignUpFullNameViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/8/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "SignUpFullNameViewController.h"
#import "SignUpUsernameViewController.h"

@interface SignUpFullNameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpFullNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)nextStep:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Present Username Verification View Controller" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *email = self.email;
    NSString *fullName = self.fullNameField.text;
    NSString *password = self.passwordField.text;
    
    SignUpUsernameViewController *vc = ((SignUpUsernameViewController *)[segue destinationViewController]);
    
    vc.email = email;
    vc.fullName = fullName;
    vc.password = password;
}

@end
