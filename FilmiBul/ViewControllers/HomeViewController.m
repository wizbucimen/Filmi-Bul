//
//  SubmitQuestionViewController.h
//  FilmiBul
//
//  Created by Emre Cimenkaya on 20/02/2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "HomeViewController.h"
#import "OYUtils.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
@import GoogleMobileAds;

@interface HomeViewController () <AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UIButton *playNowButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *submitQuestionButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation HomeViewController{
    FIRRemoteConfig *remoteConfig;
    Reachability *reachability;
    BOOL isInternetConnected;
    BOOL isUpdateRequeired;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self checkInternet];

    //Background Music
    //=================================================
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isMusicOn"]) {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Sounds/BackgroundMusic.mp3",[[NSBundle mainBundle] resourcePath]]];
        [OYUtils sharedObject].sharedPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [[OYUtils sharedObject].sharedPlayer setNumberOfLoops:-1];
        [[OYUtils sharedObject].sharedPlayer setDelegate:self];
        [[OYUtils sharedObject].sharedPlayer prepareToPlay];
        [[OYUtils sharedObject].sharedPlayer play];
    }
    
    // Gradient
    //========================================================================
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)rgb(0, 68, 87).CGColor, (id)rgb(31, 118, 142).CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];

//    gradient.colors = @[(id)rgb(221, 36, 118).CGColor, (id)rgb(255, 175, 64).CGColor];
//    float a = pow(sinf((2*M_PI*((0.45+0.75)/2))),2);
//    float b = pow(sinf((2*M_PI*((0.45+0.0)/2))),2);
//    float c = pow(sinf((2*M_PI*((0.45+0.25)/2))),2);
//    float d = pow(sinf((2*M_PI*((0.45+0.5)/2))),2);
//
//    //4. set the gradient direction
//    [gradient setStartPoint:CGPointMake(a, b)];
//    [gradient setEndPoint:CGPointMake(c, d)];
    
    
    //    GADRequest *request = [GADRequest request];
    //    request.testDevices = @[ kGADSimulatorID ];
    //    [self.bannerView loadRequest:request];
    
    // Navigation Bar
    //========================================================================
    [self.navigationController.navigationBar setHidden:YES];
    
    // Version Control
    //========================================================================
    [self fetchRemoteConfigWithDeveloperMode:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Analytics
    //========================================================================
    [OYUtils analyticsSetScreenName:@"Home"];
    
    // Ad Banner for AdMob
    //========================================================================
    self.bannerView.adUnitID = @"ca-app-pub-1404994284442192/7090890640";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    [_submitQuestionButton setTitle:OYLocale(@"submit") forState:UIControlStateNormal];
    [_aboutButton setTitle:OYLocale(@"about") forState:UIControlStateNormal];
    
    _logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"filmibul_%@",LANGUAGE_CODE]];
}

- (void)checkInternet{
    reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reachability.reachableBlock = ^(Reachability*reach){
        isInternetConnected = YES;
    };
    
    reachability.unreachableBlock = ^(Reachability*reach){
        isInternetConnected = NO;
    };
    
    [reachability startNotifier];
}

- (void)fetchRemoteConfigWithDeveloperMode:(BOOL)State{
    
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:State];
    long expirationDuration = 3600;
    
    // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from the server.
    if (remoteConfig.configSettings.isDeveloperModeEnabled) {
        expirationDuration = 0;
    }
    remoteConfig = [FIRRemoteConfig remoteConfig];
    remoteConfig.configSettings = remoteConfigSettings;
    
    [remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"Config fetched!");
            
            [remoteConfig activateFetched];
            FIRRemoteConfigValue *configParam = remoteConfig[@"app_version"];
//            NSLog(@"Version Information is = %@",configParam.stringValue);
            
            switch (configParam.numberValue.integerValue){
                case 0:
                    NSLog(@"Application is up to date");
                    break;
                case 1:
                    NSLog(@"There is a new version of the application");
                    [self showMessage:OYLocale(@"newversion") withTitle:OYLocale(@"update") withCancel:YES];
                    break;
                case 2:
                    NSLog(@"You Must Update");
                    isUpdateRequeired = YES;
                    [self showMessage:OYLocale(@"mustupdate") withTitle:OYLocale(@"update") withCancel:NO];
                    break;
            }
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error);
        }
    }];
}

- (void)showMessage:(NSString *)message withTitle:(NSString *)title withCancel:(BOOL)canCancel{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:OYLocale(@"okey") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_ITUNES_LINK] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:OYLocale(@"later") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    
    if (canCancel) {
        [alert addAction:cancelAction];
    }
    [alert addAction:okAction];
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alert animated:YES completion:nil];
}

- (IBAction)playNowButtonAction:(id)sender {
    if (isUpdateRequeired) {
        [self showMessage:OYLocale(@"update") withTitle:OYLocale(@"updateTitle") withCancel:OYLocale(@"cancel")];
    } else{
        if (isInternetConnected) {
            [OYUtils pushViewController:self withStoryboardName:@"Main" withIdentifier:@"GameViewController"];
        } else{
            [OYUtils showAlertMessage:OYLocale(@"connection") withTitle:OYLocale(@"conenctionTitle") okButtonTitle:@"okey" withCancelButtonTitle:nil];
        }
    }
}

- (IBAction)sumbitQuestionButtonAction:(id)sender {
    if (isUpdateRequeired) {
        [self showMessage:OYLocale(@"update") withTitle:OYLocale(@"updateTitle") withCancel:OYLocale(@"cancel")];

    } else{
        [OYUtils pushViewController:self withStoryboardName:@"Main" withIdentifier:@"SubmitQuestionViewController"];
    }
}

- (IBAction)settingsButtonAction:(id)sender {
    if (isUpdateRequeired) {
        [self showMessage:OYLocale(@"update") withTitle:OYLocale(@"update title") withCancel:OYLocale(@"cancel")];

    } else{
        [OYUtils pushViewController:self withStoryboardName:@"Main" withIdentifier:@"SettingsViewController"];
    }
}

- (IBAction)aboutUsButtonAction:(id)sender {
    if (isUpdateRequeired) {
        [self showMessage:OYLocale(@"update") withTitle:OYLocale(@"update title") withCancel:OYLocale(@"cancel")];
    } else{
        [OYUtils pushViewController:self withStoryboardName:@"Main" withIdentifier:@"AboutUsViewController" ];
    }
}

@end
