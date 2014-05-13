//
//  SharedObject.m
//  IncredibleBox
//
//  Created by Alan Sparrow on 5/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SharedObject.h"


@implementation SharedObject

+ (SharedObject *)sharedObject
{
    static SharedObject *sharedObject = nil;
    if (!sharedObject) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        {
            // app already launched
        }
        else
        {
            // Init SharedObject for the very first time
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"HighestScore"];
        }

        // Check purchases
        // If he is pro user
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.alansparrow.colorshooter.noads"]) {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"IsProUser"];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"IsProUser"];
        }

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        sharedObject = [[super allocWithZone:nil] init];
        sharedObject.points = 0;
        
        // Load saved info
        sharedObject.highestScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighestScore"];
        sharedObject.isProUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsProUser"];
        
    }
    
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedObject];
}

+ (void)randomColorID
{
    SharedObject *sharedObject = [SharedObject sharedObject];
    sharedObject.colorID = arc4random_uniform(6);
}

+ (void)randomTargetBalls
{
    SharedObject *sharedObject = [SharedObject sharedObject];
    sharedObject.targetBalls = arc4random_uniform(6) + 4;
}

@end
