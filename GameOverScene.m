//
//  GameOverScene.m
//  ColorShooter1
//
//  Created by Alan Sparrow on 5/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOverScene.h"
#import "SharedObject.h"
#import "GCHelper.h"
#import "AppDelegate.h"

NSString *const HighestScorePrefKey = @"HighestScore";
NSString *const WillShowAdvPrefKey = @"WillShowAdv";
NSString *const HasLaunchedOncePrefKey = @"HasLaunchedOnce";

@implementation GameOverScene
{
    CCLabelTTF *_highestScoreLabel;
    CCLabelTTF *_scoreLabel;
}

- (void)didLoadFromCCB
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d", [[SharedObject sharedObject] points]];
    _highestScoreLabel.string = [NSString stringWithFormat:@"%d", [[SharedObject sharedObject] highestScore]];
    
    if ([SharedObject sharedObject].points > [SharedObject sharedObject].highestScore) {
        // Store highest score into user iPhone
        [SharedObject sharedObject].highestScore = [SharedObject sharedObject].points;
        [[NSUserDefaults standardUserDefaults] setInteger:[SharedObject sharedObject].highestScore forKey:HighestScorePrefKey];
        
        // Upload highest score to Game Center
        [[GCHelper sharedInstance] reportScore:[SharedObject sharedObject].highestScore
                              forLeaderboardID:[GCHelper sharedInstance].identifierHighestScore];
        
        NSLog(@"Inside 1");
    }
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app showAdBanner];
}

- (void)share
{
    NSLog(@"Share button pressed");
    NSString *text = [NSString stringWithFormat:@"Color Laser Shooter: This game is so interesting!!! What is your highest score ^?^ #colorlasershooter"];
    NSURL *url = [NSURL URLWithString:@"http://goo.gl/AstvdK"];
    NSArray *objectsToShare = @[text, url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]
                                            initWithActivityItems:objectsToShare
                                            applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    
    
    [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:nil];
}

- (void)restart
{
    CCScene *scene = [CCBReader loadAsScene:@"GameMenuScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}
@end
