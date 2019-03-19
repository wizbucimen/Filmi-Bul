//
//  AppDelegate.m
//  FilmiBul
//
//  Created by Orcun Yuksel on 16/02/2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "AppDelegate.h"


@import Firebase;

@interface AppDelegate () <GADRewardBasedVideoAdDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Use Firebase library to configure APIs.
    [FIRApp configure];
    
    // Initialize the Google Mobile Ads SDK.
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1404994284442192~4727138101"];
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:@"ca-app-pub-1404994284442192/3670929500"];
    [self firstTimeOpen];
    
    return YES;
}

- (void)firstTimeOpen{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"secondLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSoundOn"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isMusicOn"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAdsOn"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"secondLaunch"];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"en" forKey:@"LanguageCode"];

        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]];
        NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        if ([languageCode isEqualToString:@"tr"] || [languageCode isEqualToString:@"en"]) {
            [[NSUserDefaults standardUserDefaults] setValue:languageCode forKey:@"LanguageCode"];
        }

        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]];
    NSLog(@"%@", rewardMessage);
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load.");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
