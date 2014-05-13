//
//  GameMenuScene.m
//  ColorShooter1
//
//  Created by Alan Sparrow on 5/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameMenuScene.h"

#import "GameStartScene.h"
#import "GCHelper.h"
#import "SharedObject.h"
#import "AppInfo.h"
#import "AppDelegate.h"
#import "IAPTableViewController.h"


@implementation GameMenuScene
{
    CCPhysicsNode *_physicsNode;
    
    NSArray *_ballNo;
}

- (void)didLoadFromCCB
{
    [SharedObject sharedObject].points = 5;
    
    // Game Center
    [[GCHelper sharedInstance] authenticateLocalUser];
    [[GCHelper sharedInstance] setIdentifierHighestScore:GC_INDENTIFIER_HIGHEST_SCORE];
    
    
    
    _ballNo = @[@"RedBall", @"GreenBall", @"BlueBall", @"YellowBall", @"OrangeBall", @"VioletBall"];
    
    for (int i = 0; i < 6; i++) {
        CCNode *ball = [CCBReader load:_ballNo[i]];
        ball.positionType = CCPositionTypeNormalized;
        ball.position = ccp(0.5f, 0.55f);
        ball.scale = 1.5f;
        
        [_physicsNode addChild:ball];
    }
    
    
    

    
    
    // Ads
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app showAdBanner];
}

- (void)play
{
    NSLog(@"Play button pressed");
    CCScene *scene = [CCBReader loadAsScene:@"GameStartScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)showScore
{
    NSLog(@"Show score button pressed");
    
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardViewController != NULL)
    {
        leaderboardViewController.category = GC_INDENTIFIER_HIGHEST_SCORE;
        leaderboardViewController.timeScope = GKLeaderboardTimeScopeWeek;
        leaderboardViewController.leaderboardDelegate = self;
        [[CCDirector sharedDirector] presentViewController: leaderboardViewController animated: YES completion:nil];
    }
    
}


- (void)share
{
    NSLog(@"Share button pressed");
    NSString *text = [NSString stringWithFormat:@"Box Jumping: This game is an ART!!! What is your longest streak ^?^ #boxjumping"];
    NSURL *url = [NSURL URLWithString:@"http://goo.gl/kF3oX0"];
    NSArray *objectsToShare = @[text, url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]
                                            initWithActivityItems:objectsToShare
                                            applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    
    
    [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:nil];
    
}

- (void)showShop
{
    NSLog(@"Shop button pressed");
    IAPTableViewController *shopViewController = [[IAPTableViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:shopViewController];
    [[CCDirector sharedDirector] presentViewController:navController animated:YES completion:nil];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
}
@end
