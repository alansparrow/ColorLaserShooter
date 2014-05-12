//
//  GCHelper.h
//  Incredible Eggs
//
//  Created by Alan Sparrow on 5/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GCHelper : NSObject
{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (retain) NSMutableDictionary* earnedAchievementCache;
@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic) NSString *identifierHighestScore;
@property (nonatomic) NSString *identifierLongestStreak;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)reportScore: (int64_t) score forLeaderboardID: (NSString*) category;
- (void)submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete;
- (void)resetAchievements;
- (void)checkAchievement:(int64_t) score;

@end
