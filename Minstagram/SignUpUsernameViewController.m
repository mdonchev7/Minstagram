//
//  SignUpUsernameViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/8/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "SignUpUsernameViewController.h"
#import "BackendServices.h"
#import "NSString+FontAwesome.h"
#import "MinstagramTabBarController.h"

@interface SignUpUsernameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *usernameTextFieldActionButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (nonatomic) BackendServices *services;

@end

@implementation SignUpUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator setHidden:YES];
    
    self.usernameTextFieldActionButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
    [self.usernameTextFieldActionButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
    
    NSMutableParagraphStyle *style = [self.self.usernameTextField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = self.usernameTextField.font.lineHeight - (self.usernameTextField.font.lineHeight - [UIFont fontWithName:@"Proxima Nova" size:14.0].lineHeight) / 2.0;
    
    [self setTextFieldPlaceholderText:@"Username" forUITextField:self.usernameTextField];
    
}

- (IBAction)nextStep:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    [self.actionButton setTitle:[NSString new] forState:UIControlStateNormal];
    
    NSString *username = self.usernameTextField.text;
    
    [self.services isUsernameTaken:username completionBlock:^(NSString *username, BOOL alreadyTaken) {
        if (alreadyTaken) {
            NSLog(@"Username is already taken, choose another one.");
        } else {
            KCSMetadata *metaData = [[KCSMetadata alloc] init];
            [metaData setGloballyReadable:YES];
            
            if (self.profileImage) {
                [self.services uploadPhoto:self.profileImage
                               withOptions:@{KCSFileACL: metaData}
                           completionBlock:^(KCSFile *uploadInfo) {
                               [self.services registerWithUsername:username
                                                          password:self.password
                                                   fieldsAndValues:@{@"email": self.email,
                                                                     @"full name": self.fullName,
                                                                     @"posts": @[],
                                                                     @"liked posts": @[],
                                                                     @"profile photo": uploadInfo.fileId }
                                                   completionBlock:^(KCSUser *user, KCSUserActionResult result) {
                                                       [self.actionButton setTitle:@"Next" forState:UIControlStateNormal];
                                                       [self.activityIndicator setHidesWhenStopped:YES];
                                                       [self.activityIndicator stopAnimating];
                                                       
                                                       UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                       MinstagramTabBarController *mtbc = [sb instantiateViewControllerWithIdentifier:@"Tab Bar Controller"];
                                                       [self.navigationController showViewController:mtbc sender:self];
                                                   }];
                           }];
                
            } else {
                [self.services registerWithUsername:username
                                           password:self.password
                                    fieldsAndValues:@{@"email": self.email,
                                                      @"full name": self.fullName,
                                                      @"posts": @[],
                                                      @"liked posts": @[] }
                                    completionBlock:^(KCSUser *user, KCSUserActionResult result) {
                                        [self.actionButton setTitle:@"Next" forState:UIControlStateNormal];
                                        [self.activityIndicator setHidesWhenStopped:YES];
                                        [self.activityIndicator stopAnimating];
                                        
                                        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                        MinstagramTabBarController *mtbc = [sb instantiateViewControllerWithIdentifier:@"Tab Bar Controller"];
                                        [self.navigationController showViewController:mtbc sender:self];
                                    }];
                
            }
            
        }
    }];
}

#pragma mark - Helper Methods

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)usernameTextFieldEditingChanged:(UITextField *)sender {
    [self trackTextFieldChanges];
    
    if ([self.usernameTextField hasText]) {
        [self.usernameTextFieldActionButton setHidden:NO];
    } else {
        [self.usernameTextFieldActionButton setHidden:YES];
    }
}

- (void)trackTextFieldChanges {
    if ([self.usernameTextField hasText]) {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.8f];
        [self.actionButton setEnabled:YES];
    } else {
        self.actionButton.backgroundColor = [self.actionButton.backgroundColor colorWithAlphaComponent:0.4f];
        [self.actionButton setEnabled:NO];
    }
}

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

- (IBAction)clearUsernameTextField:(UIButton *)sender {
    [self.usernameTextField setText:[NSString new]];
    [self.usernameTextFieldActionButton setHidden:YES];
    [self trackTextFieldChanges];
}

#pragma Mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
