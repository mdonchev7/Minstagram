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
#import "NSString+FontAwesome.h"
#import "SignUpFullNameViewController.h"

@interface SignUpEmailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *emailTextFieldActionButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (nonatomic) BackendServices *services;

@end

@implementation SignUpEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.delegate = self;
    
    [self.activityIndicator setHidden:YES];
    
    self.emailTextFieldActionButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
    [self.emailTextFieldActionButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
    
    [self setTextFieldPlaceholderText:@"Email Address"];
    
    [self.emailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.phoneButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f] forState:UIControlStateNormal];
}

#pragma mark - Navigation

- (IBAction)nextStep:(UIButton *)sender {
    [self.actionButton setTitle:[NSString new] forState:UIControlStateNormal];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    
    NSString *email = self.textField.text;
    
    [self.services isEmailTaken:email completionBlock:^(NSString *email, BOOL alreadyTaken) {
        [self.activityIndicator setHidesWhenStopped:YES];
        [self.activityIndicator stopAnimating];
        [self.actionButton setTitle:@"Next" forState:UIControlStateNormal];
        
        if (alreadyTaken) {
            NSLog(@"email is already in use by another user.");
        } else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SignUpFullNameViewController *sufnvc = [sb instantiateViewControllerWithIdentifier:@"Sign Up Full Name View Controller"];
            sufnvc.email = self.textField.text;
            [self.navigationController showViewController:sufnvc sender:self];
        }
    }];
}

- (IBAction)navigateToLoginViewController:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clearEmailTextField:(UIButton *)sender {
    [self.textField setText:[NSString new]];
    [self.emailTextFieldActionButton setHidden:YES];
    [self trackTextFieldChanges];
}

- (IBAction)emailTextFieldEditingDidChange:(UITextField *)sender {
    [self trackTextFieldChanges];
    
    if ([self.textField hasText]) {
        [self.emailTextFieldActionButton setHidden:NO];
    } else {
        [self.emailTextFieldActionButton setHidden:YES];
    }
}

- (void)trackTextFieldChanges {
    if ([self.textField hasText]) {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.8f];
        [self.actionButton setEnabled:YES];
    } else {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.40f];
        [self.actionButton setEnabled:NO];
    }
}

- (IBAction)handlePhoneButtonTap:(UIButton *)sender {
    [self.phoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.emailButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f] forState:UIControlStateNormal];
    [self setTextFieldPlaceholderText:@"Not supported yet"];
    [self.textField setText:[NSString new]];
    [self.textField setEnabled:NO];
}

- (IBAction)handleEmailButtonTap:(UIButton *)sender {
    [self.emailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.phoneButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f] forState:UIControlStateNormal];
    [self setTextFieldPlaceholderText:@"Email Address"];
    [self.textField setEnabled:YES];
}

- (void)setTextFieldPlaceholderText:(NSString *)text {
    NSMutableParagraphStyle *style = [self.self.textField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = self.textField.font.lineHeight - (self.textField.font.lineHeight - [UIFont fontWithName:@"Proxima Nova" size:14.0].lineHeight) / 2.0;
    
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text
                                                                           attributes:@{
                                                                                        NSForegroundColorAttributeName: [UIColor colorWithRed:79/255.0f green:79/255.0f blue:79/255.0f alpha:0.2f],
                                                                                        NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:14.0],
                                                                                        NSParagraphStyleAttributeName : style
                                                                                        }];
}

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma Mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
