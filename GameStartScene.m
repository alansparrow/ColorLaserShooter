//
//  GameStartScene.m
//  ColorShooter1
//
//  Created by Alan Sparrow on 5/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameStartScene.h"
#import "SharedObject.h"
#import "AppDelegate.h"

@implementation GameStartScene
{
    CCPhysicsNode *_physicsNode;
    CCNode *_cannon;
    CCNode *_lineCeil;
    CCNode *_lineFloor;
    CCNode *_lineLeft;
    CCNode *_lineRight;
    
    CCLabelTTF *_scoreLabel;
    
    int _maxBalls;
    BOOL _isBallsFired;
    NSMutableArray *_balls;
    
    int _bulletNum;
    int _colorID;
    NSArray *_bulletNo;
    NSArray *_bushNo;
    NSArray *_ballNo;
    NSArray *_ballClass;

}

- (void)didLoadFromCCB
{
    // enable touch
    self.userInteractionEnabled = TRUE;
    
    [SharedObject randomColorID];
    
    _ballNo = @[@"RedBall", @"GreenBall", @"BlueBall", @"YellowBall", @"OrangeBall", @"VioletBall"];
    
    CCNode *ball = [CCBReader load:_ballNo[[SharedObject sharedObject].colorID]];
    ball.positionType = CCPositionTypeNormalized;
    ball.position = ccp(0.5f, 0.55f);
    ball.scale = 2.0f;
    
    [self addChild:ball];
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app showAdBanner];
}


- (void)startGame
{
    NSLog(@"Go to MainScene");
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}
@end
