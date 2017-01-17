//
//  SignUpFullNameViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/8/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "SignUpFullNameViewController.h"
#import "SignUpUsernameViewController.h"
#import "BackendServices.h"

#import "NSString+FontAwesome.h"
#import "UIImage+Resize.h"

#import "Minstagram-Swift.h"

@interface SignUpFullNameViewController () <UITextFieldDelegate, FusumaDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *fullnameTextFeldActionButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *passwordTextFieldActionButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *addPhotoContainerVIew;
@property (weak, nonatomic) IBOutlet UIView *titleContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullNameTextFieldVerticalTopTitleContainerViewConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *fullNameTextFieldVerticalTopAddPhotoContainerViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullNameTextFieldVerticalConstraintBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTextFieldVerticalConstraintBottom;
@property (nonatomic) UIImage *profileImage;

@property (nonatomic) BackendServices *services;
@property (nonatomic) UIImageView *imageView;

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
    
    NSMutableParagraphStyle *style = [self.self.fullNameTextField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = self.fullNameTextField.font.lineHeight - (self.fullNameTextField.font.lineHeight - [UIFont fontWithName:@"Proxima Nova" size:14.0].lineHeight) / 2.0;
    
    [self setTextFieldPlaceholderText:@"Full Name" forUITextField:self.fullNameTextField];
    [self setTextFieldPlaceholderText:@"Password" forUITextField:self.passwordTextField];
}

- (IBAction)nextStep:(UIButton *)sender {
    NSString *email = self.email;
    NSString *fullName = self.fullNameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpUsernameViewController *suuvc = [sb instantiateViewControllerWithIdentifier:@"Sign Up Username View Controller"];
    
    suuvc.email = email;
    suuvc.fullName = fullName;
    suuvc.password = password;
    suuvc.profileImage = self.profileImage;
    
    [self.navigationController showViewController:suuvc sender:self];
}

#pragma mark - Navigation

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

- (IBAction)fullNameTextFieldEditingDidBegin:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3f animations:^{
        [self.addPhotoContainerVIew setHidden:YES];
        [self.imageView setHidden:YES];
        self.fullNameTextFieldVerticalTopAddPhotoContainerViewConstraint.active = NO;
        self.fullNameTextFieldVerticalTopTitleContainerViewConstraint.active = YES;
        self.fullNameTextFieldVerticalConstraintBottom.constant -= 5;
        self.passwordTextFieldVerticalConstraintBottom.constant -= 10;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)fullNameTextFieldEditingDidEnd:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3f animations:^{
        self.fullNameTextFieldVerticalTopAddPhotoContainerViewConstraint.active = YES;
        self.fullNameTextFieldVerticalTopTitleContainerViewConstraint.active = NO;
        self.fullNameTextFieldVerticalConstraintBottom.constant += 5;
        self.passwordTextFieldVerticalConstraintBottom.constant += 10;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!self.fullNameTextField.isFirstResponder && !self.passwordTextField.isFirstResponder) {
            [self.addPhotoContainerVIew setHidden:NO];
            [self.imageView setHidden:NO];
        }
    }];
}

- (IBAction)passwordTextFieldEditingDidBegin:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3f animations:^{
        [self.addPhotoContainerVIew setHidden:YES];
        [self.imageView setHidden:YES];
        self.fullNameTextFieldVerticalTopAddPhotoContainerViewConstraint.active = NO;
        self.fullNameTextFieldVerticalTopTitleContainerViewConstraint.active = YES;
        self.fullNameTextFieldVerticalConstraintBottom.constant -= 5;
        self.passwordTextFieldVerticalConstraintBottom.constant -= 10;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)passwordTextFieldEditingDidEnd:(UITextField *)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3f animations:^{
        self.fullNameTextFieldVerticalTopAddPhotoContainerViewConstraint.active = YES;
        self.fullNameTextFieldVerticalTopTitleContainerViewConstraint.active = NO;
        self.fullNameTextFieldVerticalConstraintBottom.constant += 5;
        self.passwordTextFieldVerticalConstraintBottom.constant += 10;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!self.fullNameTextField.isFirstResponder && !self.passwordTextField.isFirstResponder) {
            [self.addPhotoContainerVIew setHidden:NO];
            [self.imageView setHidden:NO];
        }
    }];
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

- (IBAction)handleAddPhotoViewTap:(UITapGestureRecognizer *)sender {
    FusumaViewController *fvc = [[FusumaViewController alloc] init];
    fvc.delegate = self;
    fvc.hasVideo = NO;
    
    [self presentViewController:fvc animated:YES completion:nil];
}

#pragma mark - Fusuma delegate methods

- (void)fusumaCameraRollUnauthorized {
    
}

- (void)fusumaVideoCompletedWithFileURL:(NSURL *)fileURL {
    // video is not supported
}

- (void)fusumaClosed {
    
}

- (void)fusumaImageSelected:(UIImage *)image {
    CGSize size = CGSizeMake(80.0f, 80.0f);
    UIImage *resizedImage = [UIImage imageWithImage:image scaledToSize:size];
    self.profileImage = resizedImage;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
    [self.view addSubview:imageView];
    imageView.frame = self.addPhotoContainerVIew.frame;
    [self.addPhotoContainerVIew setHidden:YES];
    
    imageView.clipsToBounds = YES;
    
    CGPoint saveCenter = imageView.center;
    CGRect newFrame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    imageView.frame = newFrame;
    imageView.layer.cornerRadius = imageView.frame.size.width / 2.0;
    imageView.center = saveCenter;
    
    self.imageView = imageView;
}

- (void)fusumaDismissedWithImage:(UIImage *)image {
    
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

@end
