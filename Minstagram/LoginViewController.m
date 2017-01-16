//
//  SignInViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/6/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "LoginViewController.h"
#import "BackendServices.h"
#import "NSString+FontAwesome.h"
#import "SignUpEmailViewController.h"
#import "MinstagramTabBarController.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *usernameTextFieldActionButton;
@property (weak, nonatomic) IBOutlet UIButton *passwordTextFieldActionButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameTextFieldVerticalConstraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameTextFieldVerticalConstraintBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTextFieldVerticalConstraintBottom;

@property (nonatomic) BackendServices *services;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.usernameTextFieldActionButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
    [self.usernameTextFieldActionButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
    
    self.passwordTextFieldActionButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
    [self.passwordTextFieldActionButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
    
    [self.activityIndicator setHidden:YES];
    
    [self.services loginWithUsername:@"prelogin"
                            password:@"prelogin"
                     completionBlock:^(KCSUser *user, NSError *error) {
                     }];
    
    NSMutableParagraphStyle *style = [self.self.usernameTextField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = self.usernameTextField.font.lineHeight - (self.usernameTextField.font.lineHeight - [UIFont fontWithName:@"Proxima Nova" size:14.0].lineHeight) / 2.0;

    [self setTextFieldPlaceholderText:@"Username" forUITextField:self.usernameTextField];
    [self setTextFieldPlaceholderText:@"Password" forUITextField:self.passwordTextField];    
}

- (IBAction)login:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    [self.actionButton setTitle:[NSString new] forState:UIControlStateNormal];
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [self.services loginWithUsername:username
                            password:password
                     completionBlock:^(KCSUser *user, NSError *error) {
                         [self.activityIndicator setHidesWhenStopped:YES];
                         [self.activityIndicator stopAnimating];
                         [self.actionButton setTitle:@"Login" forState:UIControlStateNormal];
                         
                         if (error == nil) {
                             UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                             MinstagramTabBarController *mtbc = [sb instantiateViewControllerWithIdentifier:@"Tab Bar Controller"];
                             [self.navigationController showViewController:mtbc sender:self];
                         } else {
                             UIAlertController * alert = [UIAlertController
                                                          alertControllerWithTitle:@"Invalid credentials"
                                                          message:@"The credentials you entered are incorrect. Please try again."
                                                          preferredStyle:UIAlertControllerStyleAlert];
                             
                             UIAlertAction *tryAgainButton = [UIAlertAction actionWithTitle:@"Try Again"
                                                                                      style:UIAlertActionStyleDefault
                                                                                    handler:^(UIAlertAction * action) {
                                                        }];
                             
                             [alert addAction:tryAgainButton];
                             
                             [self presentViewController:alert animated:YES completion:nil];
                         }
                     }];
}

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)usernameTextFieldEditingChanged:(UITextField *)sender {
    [self trackTextFieldsChanges];
    
    if ([self.usernameTextField hasText]) {
        [self.usernameTextFieldActionButton setHidden:NO];
    } else {
        [self.usernameTextFieldActionButton setHidden:YES];
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
    if ([self.usernameTextField hasText] && [self.passwordTextField hasText]) {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.8f];
        [self.actionButton setEnabled:YES];
    } else if (![self.usernameTextField hasText] || ![self.passwordTextField hasText]) {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.40f];
        [self.actionButton setEnabled:NO];
    }
}

- (IBAction)clearUsernameTextField:(id)sender {
    [self.usernameTextField setText:[NSString new]];
    [self.usernameTextFieldActionButton setHidden:YES];
    [self trackTextFieldsChanges];
}

- (IBAction)clearPasswordTextField:(UIButton *)sender {
    [self.passwordTextField setText:[NSString new]];
    [self.passwordTextFieldActionButton setHidden:YES];
    [self trackTextFieldsChanges];
}

- (IBAction)usernameTextFieldEditingDidBegin:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.usernameTextFieldVerticalConstraintTop.constant -= 70;
        self.usernameTextFieldVerticalConstraintBottom.constant -= 5;
        self.passwordTextFieldVerticalConstraintBottom.constant -= 10;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)usernameTextFieldEditingDidEnd:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.usernameTextFieldVerticalConstraintTop.constant += 70;
        self.usernameTextFieldVerticalConstraintBottom.constant += 5;
        self.passwordTextFieldVerticalConstraintBottom.constant += 10;
        
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)passwordTextFieldEditingDidBegin:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.usernameTextFieldVerticalConstraintTop.constant -= 70;
        self.usernameTextFieldVerticalConstraintBottom.constant -= 5;
        self.passwordTextFieldVerticalConstraintBottom.constant -= 10;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)passwordTextFieldEditingDidEnd:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.usernameTextFieldVerticalConstraintTop.constant += 70;
        self.usernameTextFieldVerticalConstraintBottom.constant += 5;
        self.passwordTextFieldVerticalConstraintBottom.constant += 10;
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Helper Methods

- (void)setTextFieldPlaceholderText:(NSString *)text forUITextField:(UITextField *)textField{
    NSMutableParagraphStyle *style = [textField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = textField.font.lineHeight - (textField.font.lineHeight - [UIFont fontWithName:@"Proxima Nova" size:14.0].lineHeight) / 2.0;
    
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text
                                                                           attributes:@{
                                                                                        NSForegroundColorAttributeName: [UIColor colorWithRed:79/255.0f green:79/255.0f blue:79/255.0f alpha:0.2f],
                                                                                        NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:14.0],
                                                                                        NSParagraphStyleAttributeName : style
                                                                                        }];
}

#pragma mark - Navigation

- (IBAction)navigateToSignUpViewController:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpEmailViewController *suevc = [sb instantiateViewControllerWithIdentifier:@"Sign Up Email View Controller"];
    NSLog(@"nav controller -> %@", self.navigationController);
    NSLog(@"sign up email vc -> %@", suevc);
    [self.navigationController showViewController:suevc sender:self];
}

#pragma mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
