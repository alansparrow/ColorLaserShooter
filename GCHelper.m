//
//  GCHelper.m
//  Incredible Eggs
//
//  Created by Alan Sparrow on 5/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GCHelper.h"
#import <GameKit/GameKit.h>
#import "AppInfo.h"

@implementation GCHelper

static GCHelper *sharedHelper = nil;


+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    // ios 6.0 and above
    [localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
        if (!error && viewcontroller)
        {
            [[CCDirector sharedDirector] presentViewController:viewcontroller animated:YES completion:nil];
        }
        else
        {
            [self checkLocalPlayer];
        }
    })];
    
}

- (void)checkLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if (localPlayer.isAuthenticated)
    {
        /* Perform additional tasks for the authenticated player here */
    }
    else
    {
        /* Perform additional tasks for the non-authenticated player here */
    }
}

- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    if (achievement)
    {
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 // Retain the achievement object and try again later (not shown).
             }
         }];
    }
    
    NSLog(@"In submitAch");
}

- (void) resetAchievements
{
	self.earnedAchievementCache= NULL;
	[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error)
     {
         if (error != nil)
         {
             // Retain the achievement object and try again later (not shown).
         }
     }];
    
}

- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) category
{
    
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSLog(@"%@", category);
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (error == NULL) {
                NSLog(@"Score Sent");
            } else {
                NSLog(@"Score Failed, %@",[error localizedDescription]);
            }
        });
    }];
    
}

- (void)checkAchievement:(int64_t) score
{
    switch (score) {
    }
}





@end
