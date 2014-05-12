//
//  SharedObject.h
//  IncredibleBox
//
//  Created by Alan Sparrow on 5/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface SharedObject : NSObject
{
    
}

@property (nonatomic) int points;
@property (nonatomic) int targetBalls;
@property (nonatomic) int finishedBalls;
@property (nonatomic) int colorID;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) int highestScore;
@property (nonatomic) BOOL isProUser;

+ (SharedObject *)sharedObject;
+ (void)randomColorID;
+ (void)randomTargetBalls;

@end
