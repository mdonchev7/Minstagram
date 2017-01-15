//
//  SignUpFullNameViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/8/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "SignUpFullNameViewController.h"
#import "SignUpUsernameViewController.h"
#import "NSString+FontAwesome.h"

@interface SignUpFullNameViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *fullnameTextFeldActionButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *passwordTextFieldActionButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation SignUpFullNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fullNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    [self.activityIndicator setHidden:YES];
    
    self.fullnameTextFeldActionButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
    [self.fullnameTextFeldActionButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
    
    self.passwordTextFieldActionButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
    [self.passwordTextFieldActionButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
}

- (IBAction)nextStep:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Present Username Verification View Controller" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *suuvc = [segue destinationViewController];
    
    if ([suuvc isKindOfClass:[SignUpUsernameViewController class]]) {
        NSString *email = self.email;
        NSString *fullName = self.fullNameTextField.text;
        NSString *password = self.passwordTextField.text;
        
        SignUpUsernameViewController *vc = (SignUpUsernameViewController *)suuvc;
        
        vc.email = email;
        vc.fullName = fullName;
        vc.password = password;
    }
}

- (IBAction)navigateToLoginViewController:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Methods

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)fullNameTextFieldEditingChanged:(UITextField *)sender {
    [self trackTextFieldsChanges];
    
    if ([self.fullNameTextField hasText]) {
        [self.fullnameTextFeldActionButton setHidden:NO];
    } else {
        [self.fullnameTextFeldActionButton setHidden:YES];
    }
}

- (IBAction)passwordTextFieldEditingChanged:(UITextField *)sender {
    [self trackTextFieldsChanges];
    
    if ([self.passwordTextField hasText]) {
        [self.passwordTextFieldActionButton setHidden:NO];
    } else {
        [self.passwordTextFieldActionButton setHidden:YES];
    }
}

- (void)trackTextFieldsChanges {
    if ([self.fullNameTextField hasText] && self.passwordTextField.text.length > 4) {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.8f];
        [self.actionButton setEnabled:YES];
    } else {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.4f];
        [self.actionButton setEnabled:NO];
    }
}

- (IBAction)clearFullNameTextField:(id)sender {
    [self.fullNameTextField setText:[NSString new]];
    [self.fullnameTextFeldActionButton setHidden:YES];
    [self trackTextFieldsChanges];
}

- (IBAction)clearPasswordTextField:(UIButton *)sender {
    [self.passwordTextField setText:[NSString new]];
    [self.passwordTextFieldActionButton setHidden:YES];
    [self trackTextFieldsChanges];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end
