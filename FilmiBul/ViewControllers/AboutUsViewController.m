//
//  AboutUsViewController.m
//  FilmiBul
//
//  Created by Emre Cimenkaya on 26/02/2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "AboutUsViewController.h"
#import "OYUtils.h"
#import <MessageUI/MessageUI.h>


@interface AboutUsViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
    
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Gradient
    //========================================================================
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)rgb(0, 68, 87).CGColor, (id)rgb(31, 118, 142).CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Analytics
    //========================================================================
    [OYUtils analyticsSetScreenName:@"AboutUs"];
    [OYUtils activateEdgeSwipe:self isActive:YES];
    
    [_rateButton setTitle:OYLocale(@"rate") forState:UIControlStateNormal];
    [_shareButton setTitle:OYLocale(@"shareApp") forState:UIControlStateNormal];

    _feedbackLabel.text = OYLocale(@"feedback");
    _companyLabel.text = OYLocale(@"company");
    _versionLabel.text = [NSString stringWithFormat:@"%@ %@", OYLocale(@"version"), CURRENT_VERSION];
    
    _logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"filmibul_%@",LANGUAGE_CODE]];
}

- (void)sendEmail {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        picker.mailComposeDelegate = self;
        [picker setSubject:@"Filmibul - Geri Bildirim"];
        [picker setToRecipients:[NSArray arrayWithObject:@"info@upapp.io"]];
        [picker setMessageBody:@"" isHTML:NO];
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result){
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            [OYUtils analyticsLogEventWithName:@"Email_Send"];
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)rateApplicationButtonAction:(id)sender {
    [SKStoreReviewController requestReview];
    [OYUtils analyticsLogEventWithName:@"Rate_Application"];
    
}

- (IBAction)shareButtonAction:(id)sender {
    [OYUtils analyticsLogEventWithName:@"Share_App"];
    
    NSArray *sharedObjects = @[OYLocale(@"shareGame") , APP_ITUNES_LINK];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeMessage,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     ];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)mailButtonAction:(id)sender {
    [self sendEmail];
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
