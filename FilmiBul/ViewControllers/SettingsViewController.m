//
//  SettingsViewController.m
//  FilmiBul
//
//  Created by Emre Cimenkaya on 26/02/2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "SettingsViewController.h"
#import "OYUtils.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicLabel;
@property (weak, nonatomic) IBOutlet UILabel *adsLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
    
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UIButton *musicButton;
@property (weak, nonatomic) IBOutlet UIButton *adsButton;
@property (weak, nonatomic) IBOutlet UIButton *languageButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Gradient
    //========================================================================
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)rgb(0, 68, 87).CGColor, (id)rgb(31, 118, 142).CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    // Button States
    //========================================================================
    [_soundButton setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]];
    [_musicButton setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:@"isMusicOn"]];
    [_adsButton setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:@"isAdsOn"]];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"LanguageCode"] isEqualToString:@"tr"]) {
        [_languageButton setSelected:YES];
    } else{
        [_languageButton setSelected:NO];
    }
}
    
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Analytics
    //========================================================================
    [OYUtils analyticsSetScreenName:@"Settings"];
    [OYUtils activateEdgeSwipe:self isActive:YES];

    _soundLabel.text = OYLocale(@"sound");
    _musicLabel.text = OYLocale(@"music");
    _adsLabel.text = OYLocale(@"ads");
    _languageLabel.text = OYLocale(@"language");
    
    _logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"filmibul_%@",LANGUAGE_CODE]];
}

- (IBAction)soundSwitchAction:(id)sender {
    [sender setSelected:![sender isSelected]];
    [[NSUserDefaults standardUserDefaults] setBool:[sender isSelected] forKey:@"isSoundOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAppMusicAction:(id)sender {
    [sender setSelected:![sender isSelected]];
    [[NSUserDefaults standardUserDefaults] setBool:[sender isSelected] forKey:@"isMusicOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isMusicOn"]) {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Sounds/BackgroundMusic.mp3",[[NSBundle mainBundle] resourcePath]]];
        [OYUtils sharedObject].sharedPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [[OYUtils sharedObject].sharedPlayer setNumberOfLoops:-1];
        [[OYUtils sharedObject].sharedPlayer prepareToPlay];
        [[OYUtils sharedObject].sharedPlayer play];
    } else{
        [[OYUtils sharedObject].sharedPlayer stop];
    }
}

- (IBAction)adSwitchAction:(id)sender {
    [sender setSelected:![sender isSelected]];
    [[NSUserDefaults standardUserDefaults] setBool:[sender isSelected] forKey:@"isAdsOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)languageSwitchAction:(id)sender {
    [sender setSelected:![sender isSelected]];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"LanguageCode"] isEqualToString:@"tr"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"en" forKey:@"LanguageCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else{
        [[NSUserDefaults standardUserDefaults] setValue:@"tr" forKey:@"LanguageCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
        [self viewWillAppear:YES];
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end 
