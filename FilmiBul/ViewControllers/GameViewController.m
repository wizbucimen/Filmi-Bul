//
//  SubmitQuestionViewController.h
//  FilmiBul
//
//  Created by Emre Cimenkaya on 20/02/2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "GameViewController.h"
#import "OYUtils.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


#define ANSWER_A 11
#define ANSWER_B 12
#define ANSWER_C 13
#define ANSWER_D 14

#define GAME_TIME 60
#define QUESTION_DELAY_TIME .10f
#define CORRECT_MULTIPLIER 10
#define FALSE_MULTIPLIER 5

#define TRUE_COLOR [UIColor colorWithRed:130/255.f green:219/255.f blue:86/255.f alpha:1.0f]
#define FALSE_COLOR [UIColor colorWithRed:237/255.f green:126/255.f blue:126/255.f alpha:1.0f]

@import Firebase;
@import FirebaseDatabase;

@interface GameViewController () <GADInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *statusBarImageView;

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *aLabel;
@property (weak, nonatomic) IBOutlet UILabel *bLabel;
@property (weak, nonatomic) IBOutlet UILabel *cLabel;
@property (weak, nonatomic) IBOutlet UILabel *dLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctLabel;
@property (weak, nonatomic) IBOutlet UILabel *wrongLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *wrongTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportQuestionLabel;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (strong, nonatomic) GADInterstitial *interstitial;

@property (weak, nonatomic) IBOutlet UIImageView *aView;
@property (weak, nonatomic) IBOutlet UIImageView *bView;
@property (weak, nonatomic) IBOutlet UIImageView *cView;
@property (weak, nonatomic) IBOutlet UIImageView *dView;

@property (weak, nonatomic) IBOutlet UIView *reportView;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UIView *correctView;
@property (weak, nonatomic) IBOutlet UIView *falseView;

@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;

@end

@implementation GameViewController{
    UIVisualEffectView *blurEffectView;
    NSMutableArray *questions;
    NSTimer *timer;
    NSTimer *timerStatusBar;
    int gameTime;
    int questionIndex;
    int correctCount;
    int falseCount;
    bool scoreBoard;
}

#pragma mark - View & Styles
//========================================================================
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Timer
    //========================================================================
    gameTime = GAME_TIME;
    if (!scoreBoard) {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfPlay"]) {
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfPlay"]+1 forKey:@"numberOfPlay"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *numberOfPlay = [NSString stringWithFormat:@"%li",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfPlay"]];
            NSLog(@"Number of Play = %@",numberOfPlay);
            
            [FIRAnalytics logEventWithName:@"NumberOfPlay"
                                parameters:@{
                                             @"name": @"NumberOfPlay",
                                             @"number": numberOfPlay
                                             }];

        } else{
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"numberOfPlay"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [self startTimer];
        [self startTimerStatusBar];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Advertisement Show
    //========================================================================
    self.interstitial = [self createAndLoadInterstitial];
    
    // Gradient
    //========================================================================
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)rgb(0, 68, 87).CGColor, (id)rgb(31, 118, 142).CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    // Init
    //========================================================================
    if (!questions) {
        questions = [[NSMutableArray alloc] init];
    }
    questionIndex = 0;
    correctCount = 0;
    falseCount = 0;
    
    // Analytics
    //========================================================================
    [OYUtils analyticsSetScreenName:@"Game"];
    
    // Ad Banner for AdMob
    //========================================================================
//    self.bannerView.adUnitID = @"ca-app-pub-1404994284442192/3653729581";
//    self.bannerView.rootViewController = self;
//    [self.bannerView loadRequest:[GADRequest request]];
    
    // Sound
    //========================================================================
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
        NSString *path = [NSString stringWithFormat:@"%@/Sounds/start.mp3",[[NSBundle mainBundle] resourcePath]];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self setViewStyles];
    [self getQuestionsFromFirebase];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_shareButton setTitle:OYLocale(@"share") forState:UIControlStateNormal];
    [_timeButton setTitle:OYLocale(@"time") forState:UIControlStateNormal];
    _gameScoreLabel.text = OYLocale(@"score");

    _correctTextLabel.text = OYLocale(@"correct");
    _wrongTextLabel.text = OYLocale(@"false");
    [_reportButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"report_%@",LANGUAGE_CODE]] forState:UIControlStateNormal];
    _reportQuestionLabel.text = OYLocale(@"reportQuestion");
    [_confirmButton setTitle:OYLocale(@"okey") forState:UIControlStateNormal];
    [_closeButton setTitle:OYLocale(@"later") forState:UIControlStateNormal];

}

- (void)setViewStyles {
    _reportView.layer.cornerRadius = 4.0f;
    _reportView.layer.masksToBounds = YES;
    
    _confirmButton.layer.cornerRadius = 4.0f;
    _confirmButton.layer.masksToBounds = YES;
    
    _closeButton.layer.cornerRadius = 4.0f;
    _closeButton.layer.masksToBounds = YES;
    
    _reportView.hidden = YES;
    _scoreView.hidden = YES;
    _replayButton.hidden = YES;
    _correctView.layer.cornerRadius = _falseView.layer.cornerRadius = _correctView.layer.frame.size.width/2;

    [OYUtils activateEdgeSwipe:self isActive:NO];
}

#pragma mark - Quetions
//========================================================================
- (void)getQuestionsFromFirebase {
    SHOW_HUD
    FIRDatabaseReference *db = [[FIRDatabase database] reference];
    [[db child:@"questions"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        HIDE_HUD
        NSDictionary *dict = snapshot.valueInExportFormat;
        questions = [[dict allValues] mutableCopy];
        questions = [self randomizeArray:questions];
        [self nextQuestion];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
        HIDE_HUD
    }];
}

- (NSMutableArray *)randomizeArray:(NSMutableArray *)array{
    for (int x = 0; x < [array count]; x++) {
        int randInt = (arc4random() % ([array count] - x)) + x;
        [array exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    return array;
}

#pragma mark - Answers
//========================================================================
- (void)answerQuestionWithView:(UIImageView *)answerView isTrue:(BOOL)isTrue{
    NSString *path;
    
    answerView.image = [answerView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (isTrue) {
        correctCount++;
        answerView.tintColor = TRUE_COLOR;
        path = [NSString stringWithFormat:@"%@/Sounds/correct_answer.m4a",[[NSBundle mainBundle] resourcePath]];
    } else{
        falseCount++;
        answerView.tintColor = FALSE_COLOR;
        path = [NSString stringWithFormat:@"%@/Sounds/false_answer.m4a",[[NSBundle mainBundle] resourcePath]];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

- (void)nextQuestion{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    // Set Texts of the question
    //========================================================================
    _questionLabel.text = [[questions objectAtIndex:questionIndex] objectForKey:@"question"];
    NSString *languageCode = [NSString stringWithFormat:@"answers_%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"LanguageCode"]];
    _aLabel.text = [[[questions objectAtIndex:questionIndex] objectForKey:languageCode] objectForKey:@"a"];
    _bLabel.text = [[[questions objectAtIndex:questionIndex] objectForKey:languageCode] objectForKey:@"b"];
    _cLabel.text = [[[questions objectAtIndex:questionIndex] objectForKey:languageCode] objectForKey:@"c"];
    _dLabel.text = [[[questions objectAtIndex:questionIndex] objectForKey:languageCode] objectForKey:@"d"];
    
    // Reset Answer Color
    //========================================================================
    _aView.image = [_aView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _bView.image = [_bView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _cView.image = [_cView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _dView.image = [_dView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)finishGame {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
        NSString *path = [NSString stringWithFormat:@"%@/Sounds/finish.mp3",[[NSBundle mainBundle] resourcePath]];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfPlay"] % 2 == 0) { // Cift sayi ise
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdsOn"]){
            if (self.interstitial.isReady) {
                [[OYUtils sharedObject].sharedPlayer pause];
                [self.interstitial presentFromRootViewController:self];
        //        self.interstitial = [self createAndLoadInterstitial];
            } else {
                NSLog(@"Ad wasn't ready");
                [self showScore];
            }
        } else{
            [self showScore];
        }
    } else{
        [self showScore];
    }
}

#pragma mark - Report Question
//========================================================================
- (void)shouldShowReportView:(BOOL)shouldShow{
    if (shouldShow) {
        _reportView.hidden = NO;
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:blurEffectView];
        [self.view bringSubviewToFront:_reportView];
        
    } else{
        _reportView.hidden = YES;
        [blurEffectView removeFromSuperview];
    }
}

- (void)reportQuestion{
    SHOW_HUD
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        FIRDatabaseReference *ref = [[FIRDatabase database] reference];
        
        [[[ref child:@"reported_questions"] childByAutoId] setValue:[[questions objectAtIndex:questionIndex] objectForKey:@"question"]];
        [OYUtils analyticsLogEventWithName:@"Question_Reported"];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            HIDE_HUD
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:OYLocale(@"Olley") message:OYLocale(@"reportQuestionOkay") preferredStyle:UIAlertControllerStyleAlert];
            [UIAlertController alertControllerWithTitle:OYLocale(@"oyea") message:@"message" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Tamam Kanka" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

                [self startTimer];
                [self startTimerStatusBar];
            }];
            
            
            [alert addAction:okAction];
            
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alert animated:YES completion:nil];
            
        });
    });
}

#pragma mark - Timers
//========================================================================
- (void)counter {
    gameTime = gameTime-1;
    if (gameTime == 0) {
        [timer invalidate];
        [timerStatusBar invalidate];
        [self finishGame];
    } else{
        _countLabel.text = [NSString stringWithFormat:@"%i",gameTime];
    }
    
    if (gameTime  <= 10) {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            NSString *path = [NSString stringWithFormat:@"%@/Sounds/time_start.mp3",[[NSBundle mainBundle] resourcePath]];
            SystemSoundID soundID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
            AudioServicesPlaySystemSound(soundID);
        }
    }
}

- (void)statusBarCounter{
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect statusFrame = _statusBarImageView.frame;
        statusFrame.size.width += 240 / 60 / 4;
        _statusBarImageView.frame = statusFrame;
        
    }completion:^(BOOL finished) {
        
    }];
}

- (NSTimer *)startTimer {
    return timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(counter)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (NSTimer *)startTimerStatusBar {
    return timerStatusBar = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                             target:self
                                                           selector:@selector(statusBarCounter)
                                                           userInfo:nil
                                                            repeats:YES];
}

#pragma mark - Button Actions
//========================================================================
- (IBAction)reportButtonAction:(id)sender {
    [self shouldShowReportView:YES];
    [timer invalidate];
    [timerStatusBar invalidate];
}

- (IBAction)confimButtonAction:(id)sender {
    [self shouldShowReportView:NO];
    [self reportQuestion];
}

- (IBAction)closeButtonAction:(id)sender {
    [self shouldShowReportView:NO];
    [self startTimer];
    [self startTimerStatusBar];
}

- (IBAction)answerButtonAction:(id)sender {
    NSString *answer = [[questions objectAtIndex:questionIndex] objectForKey:@"correct_answer"];
    int correctAnswerKey = 0;
    if ([answer isEqualToString:@"a"]) {
        correctAnswerKey = ANSWER_A;
    } else if ([answer isEqualToString:@"b"]){
        correctAnswerKey = ANSWER_B;
    } else if ([answer isEqualToString:@"c"]){
        correctAnswerKey = ANSWER_C;
    } else{
        correctAnswerKey = ANSWER_D;
    }

    int tag = (int)((UIView*)sender).tag ;
    switch (tag) {
        case ANSWER_A:
            if (correctAnswerKey == ANSWER_A) {
                [self answerQuestionWithView:_aView isTrue:YES];
            }else {
                [self answerQuestionWithView:_aView isTrue:NO];
            }
            break;
        case ANSWER_B:
            if (correctAnswerKey == ANSWER_B) {
                [self answerQuestionWithView:_bView isTrue:YES];
            }else {
                [self answerQuestionWithView:_bView isTrue:NO];
            }
            break;
        case ANSWER_C:
            if (correctAnswerKey == ANSWER_C) {
                [self answerQuestionWithView:_cView isTrue:YES];
            }else {
                [self answerQuestionWithView:_cView isTrue:NO];
            }
            break;
        case ANSWER_D:
            if (correctAnswerKey == ANSWER_D) {
                [self answerQuestionWithView:_dView isTrue:YES];
            }else {
                [self answerQuestionWithView:_dView isTrue:NO];
            }
            break;
    }
    questionIndex ++;

    if (questionIndex < questions.count) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:QUESTION_DELAY_TIME];
    } else {
        [self finishGame];
    }
}

- (IBAction)playAgainButtonAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [OYUtils analyticsLogEventWithName:@"Play_Again"];
}

- (IBAction)shareButtonAction:(id)sender {
    [OYUtils analyticsLogEventWithName:@"Share_Score"];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *png = UIImagePNGRepresentation(img); // or you can use JPG or PDF
    
    NSArray *sharedObjects = @[png];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeMessage,
                                                     UIActivityTypeAssignToContact,
//                                                     UIActivityTypeSaveToCameraRoll,
//                                                     UIActivityTypePostToTwitter,
//                                                     UIActivityTypePostToFacebook
                                                     ];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)playSound {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
        NSString *path = [NSString stringWithFormat:@"%@/Sounds/score.m4a",[[NSBundle mainBundle] resourcePath]];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

- (void)showScore{
    // Analytics
    //========================================================================
    [OYUtils analyticsSetScreenName:@"Score"];
    
    // Blur Effect
    //========================================================================
    _scoreView.hidden = NO;
    _replayButton.hidden = NO;
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:blurEffectView];
    [self.view bringSubviewToFront:_scoreView];
    [self.view bringSubviewToFront:_replayButton];

    // Score Label Update w/ Animation
    //========================================================================
    int scoreTotal = correctCount * CORRECT_MULTIPLIER - falseCount * FALSE_MULTIPLIER;
    
    float animationPeriod = 10;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 1; i <= scoreTotal/5; i ++) {
            usleep(animationPeriod/100 * 1500000); // sleep in microseconds
            dispatch_async(dispatch_get_main_queue(), ^{
                _scoreLabel.text = [NSString stringWithFormat:@"%d", i*5];
                [self playSound];
            });
        }
    });
    
    _correctLabel.text = [NSString stringWithFormat:@"%i",correctCount];
    _wrongLabel.text = [NSString stringWithFormat:@"%i",falseCount];
}

#pragma mark - Ad Delegates
//========================================================================''
- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-1404994284442192/3698440545"];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
    [self showScore];
    [[OYUtils sharedObject].sharedPlayer play];
    scoreBoard = YES;
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}

@end
