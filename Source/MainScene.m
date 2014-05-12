//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "RedBall.h"
#import "RedBullet.h"
#import "RedBush.h"

#import "BlueBall.h"
#import "BlueBullet.h"
#import "BlueBush.h"

#import "YellowBall.h"
#import "YellowBullet.h"
#import "YellowBush.h"

#import "OrangeBall.h"
#import "OrangeBullet.h"
#import "OrangeBush.h"

#import "VioletBall.h"
#import "VioletBullet.h"
#import "VioletBush.h"

#import "GreenBall.h"
#import "GreenBullet.h"
#import "GreenBush.h"

#import "SharedObject.h"
#import "AppDelegate.h"


#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderBall,
    DrawingOrderBullet,
    DrawingOrderCannon,
    DrawingOrderBush
};

@implementation MainScene
{
    CCPhysicsNode *_physicsNode;
    CCNode *_cannon;
    CCNode *_lineCeil;
    CCNode *_lineFloor;
    CCNode *_lineLeft;
    CCNode *_lineRight;
    CCSprite *_clearLabel;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_targetLabel;
    
    int _maxBalls;
    BOOL _isBallsFired;

    NSMutableArray *_balls;
    
    int _bulletNum;
    int _colorID;
    NSArray *_bulletNo;
    NSArray *_bushNo;
    NSArray *_ballNo;
    NSArray *_ballClass;
    
    BOOL _isClear;
    
    
    CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject_Shoot;
  	SystemSoundID	soundFileObject_Die;
   	SystemSoundID	soundFileObject_HitRightBall;
   	SystemSoundID	soundFileObject_HitWrongBall;
   	SystemSoundID	soundFileObject_BallShoot;
    SystemSoundID	soundFileObject_Wrong;
    SystemSoundID	soundFileObject_Right;
}


- (void)didLoadFromCCB
{
    // enable touch
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    
    _cannon.zOrder = DrawingOrderCannon;
    [_lineCeil physicsBody].collisionType = @"wall";
    [_lineFloor physicsBody].collisionType = @"floorwall";
    [_lineLeft physicsBody].collisionType = @"wall";
    [_lineRight physicsBody].collisionType = @"wall";
    
    _bulletNo = @[@"RedBullet", @"GreenBullet", @"BlueBullet", @"YellowBullet", @"OrangeBullet", @"VioletBullet"];
    _bushNo = @[@"RedBush", @"GreenBush", @"BlueBush", @"YellowBush", @"OrangeBush", @"VioletBush"];
    _ballNo = @[@"RedBall", @"GreenBall", @"BlueBall", @"YellowBall", @"OrangeBall", @"VioletBall"];
    _ballClass = @[[RedBall class], [GreenBall class], [BlueBall class], [YellowBall class], [OrangeBall class], [VioletBall class]];
    // random color code for this game
    _colorID = [SharedObject sharedObject].colorID;
    
    // Load the bush
    CCNode *bush = [CCBReader load:_bushNo[_colorID]];
    bush.zOrder = DrawingOrderBush;
    bush.positionType = CCPositionTypeNormalized;
    NSLog(@"%f %f", _cannon.positionInPoints.x, _cannon.positionInPoints.y);
    bush.position = ccp(0.5f, 0.02f);
    bush.scale = 0.5f;
    [_physicsNode addChild:bush];
    
    // Fire the balls!
    _isBallsFired = FALSE;
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", [[SharedObject sharedObject] points]];

    // Not clear
    _isClear = FALSE;
    
    // Random num of target ball
    [SharedObject randomTargetBalls];
    [SharedObject sharedObject].finishedBalls = 0;
    _targetLabel.string = [NSString stringWithFormat:@"%d / %d", 0, [[SharedObject sharedObject] targetBalls]];
    
    // Load sounds
    NSURL *laserShootSound = [[NSBundle mainBundle] URLForResource:@"lasershoot" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) laserShootSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Shoot);
    
    NSURL *ballShootSound = [[NSBundle mainBundle] URLForResource:@"ballshot" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) ballShootSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_BallShoot);
    
    NSURL *dieSound = [[NSBundle mainBundle] URLForResource:@"uhoh" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) dieSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Die);
    
    NSURL *hitRightSound = [[NSBundle mainBundle] URLForResource:@"Ting" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) hitRightSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_HitRightBall);
    
    NSURL *hitWrongSound = [[NSBundle mainBundle] URLForResource:@"thump" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) hitWrongSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_HitWrongBall);
    
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app hideAdBanner];

}

- (void)fireBalls
{
    // 5 - 10
    int numOfBalls = 6; //arc4random_uniform(6) + 5;
    
    for (int i = 0; i < numOfBalls; i++) {
        
        
        CCNode *ball = [CCBReader load:_ballNo[i]];
        [ball physicsBody].collisionType = @"ball";
        ball.zOrder = DrawingOrderBall;
        ball.positionType = CCPositionTypeNormalized;
        ball.position = ccp(0.5f, 0.02f);
        
        int shootAngle = arc4random_uniform(90) + 1;
        // 45 - 135 degree
        shootAngle += 45;
        
        CGPoint unitVector = ccpForAngle(DEGREES_TO_RADIANS(shootAngle));
        [_physicsNode addChild:ball];
        
        [ball.physicsBody applyImpulse:ccpMult(unitVector, 300.f)];
        
        AudioServicesPlaySystemSound(soundFileObject_BallShoot);
    }
    
    // -1 for the default ball
    for (int i = 0; i < [SharedObject sharedObject].targetBalls-1; i++) {
        CCNode *ball = [CCBReader load:_ballNo[_colorID]];
        [ball physicsBody].collisionType = @"ball";
        ball.zOrder = DrawingOrderBall;
        ball.positionType = CCPositionTypeNormalized;
        ball.position = ccp(0.5f, 0.02f);
        
        int shootAngle = arc4random_uniform(90) + 1;
        // 45 - 135 degree
        shootAngle += 45;
        
        CGPoint unitVector = ccpForAngle(DEGREES_TO_RADIANS(shootAngle));
        [_physicsNode addChild:ball];
        
        [ball.physicsBody applyImpulse:ccpMult(unitVector, 300.f)];
        
        AudioServicesPlaySystemSound(soundFileObject_BallShoot);
    }
    
    
}

- (void)update:(CCTime)delta
{
    if (!_isBallsFired) {
        [self fireBalls];
        _isBallsFired = TRUE;
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self rotateCannon:[touch locationInNode:self]];
    [self fireBullet:[touch locationInNode:self]];
    
}

- (void)fireBullet:(CGPoint) touchPoint
{
    CGPoint offset = ccpSub(touchPoint, _cannon.positionInPoints);
    CGPoint unitVector = ccpNormalize(offset);
    
    CCNode *bullet = [CCBReader load:_bulletNo[_colorID]];
    [bullet physicsBody].collisionType = @"bullet";
    bullet.zOrder = DrawingOrderBullet; // zOrder
    
    bullet.positionType =  CCPositionTypePoints;
    bullet.position = _cannon.positionInPoints;
    
    
    float angle = 0.f;
    if (offset.x >= 0.f) {
        angle = RADIANS_TO_DEGREES(ccpAngle(ccp(0.f, 500.f), offset));
    } else {
        angle = -1 * RADIANS_TO_DEGREES(ccpAngle(ccp(0.f, 500.f), offset));
    }
    
    bullet.rotation = angle;
    bullet.scaleX = 0.6f;
    bullet.scaleY = 0.3f;
    [_physicsNode addChild:bullet];
    
    [bullet.physicsBody applyImpulse:ccpMult(unitVector, 1200.f)];
    
    AudioServicesPlaySystemSound(soundFileObject_Shoot);
}

- (void)rotateCannon:(CGPoint) touchPoint
{
    CGPoint offset = ccpSub(touchPoint, _cannon.positionInPoints);
    
    float angle = 0.f;
    if (offset.x >= 0.f) {
        angle = RADIANS_TO_DEGREES(ccpAngle(ccp(0.f, 500.f), offset));
    } else {
        angle = -1 * RADIANS_TO_DEGREES(ccpAngle(ccp(0.f, 500.f), offset));
    }
    
    angle = angle - _cannon.rotation;
    CCActionRotateBy *r = [CCActionRotateBy actionWithDuration:0.1f angle:angle];
    
    CGPoint bounceOffset = ccpNormalize(offset);
    bounceOffset = ccp(bounceOffset.x / 50.f, bounceOffset.y / 50.f);
    CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.1f position:bounceOffset];
    CCActionInterval *reverseMovement = [moveBy reverse];
    CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
    CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
    //[self runAction:bounce];
    
    
    CCActionSequence *moveSequence = [CCActionSequence actionWithArray:@[r, bounce]];
    [_cannon runAction:moveSequence];
    
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)bullet ball:(CCNode *)ball
{
    NSLog(@"Bing!!");
    if ([ball isKindOfClass:_ballClass[_colorID]]) {
        NSLog(@"True");
        
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"Bang"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        explosion.position = ball.positionInPoints;
        // add the particle effect to the same node the egg is on
        [ball.parent addChild:explosion];
        [ball removeFromParent];
        
        AudioServicesPlaySystemSound(soundFileObject_HitRightBall);
        
        [SharedObject sharedObject].points += 2;
        [SharedObject sharedObject].finishedBalls += 1;
        NSLog(@"Finished balls: %d", [SharedObject sharedObject].finishedBalls);
        _scoreLabel.string = [NSString stringWithFormat:@"%d", [[SharedObject sharedObject] points]];
        _targetLabel.string = [NSString stringWithFormat:@"%d / %d", [SharedObject sharedObject].finishedBalls, [[SharedObject sharedObject] targetBalls]];
    } else {
        AudioServicesPlaySystemSound(soundFileObject_HitWrongBall);
    }
    [bullet removeFromParent];
    
    if ([SharedObject sharedObject].finishedBalls == [SharedObject sharedObject].targetBalls && !_isClear) {
        _isClear = TRUE;
        
        [UIView animateWithDuration:2.0
                         animations:^{
                             _clearLabel.opacity = 0.f;
                         }
                         completion:^(BOOL finished) {
                             [UIView beginAnimations:@"fade in" context:nil];
                             [UIView setAnimationDuration:1.0];
                             _clearLabel.opacity = 1.f;
                             [UIView commitAnimations];
                         }];
        
        [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(goToGameStartScene:) userInfo:nil repeats:NO];
    }
}

- (void)goToGameStartScene:(id)sender
{
    CCScene *scene = [CCBReader loadAsScene:@"GameStartScene"];
    [[CCDirector sharedDirector] replaceScene:scene];

}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)bullet wall:(CCNode *)wall
{
    [bullet removeFromParent];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)bullet floorwall:(CCNode *)floorwall
{
    [bullet removeFromParent];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball floorwall:(CCNode *)floorwall
{
    if ([ball isKindOfClass:_ballClass[_colorID]]) {
        NSLog(@"Game over");
        AudioServicesPlaySystemSound(soundFileObject_Die);
        
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"Die"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        explosion.position = ball.positionInPoints;
        // add the particle effect to the same node the egg is on
        [ball.parent addChild:explosion];
        [ball removeFromParent];
        
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(goToGameOverScene:) userInfo:nil repeats:NO];
        
    } else {
        if (!_isClear) {
            [SharedObject sharedObject].points--;
            _scoreLabel.string = [NSString stringWithFormat:@"%d", [[SharedObject sharedObject] points]];
        }
    }

    [ball removeFromParent];
}

- (void)goToGameOverScene:(id)sender
{
    CCScene *scene = [CCBReader loadAsScene:@"GameOverScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

@end
