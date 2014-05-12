//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"


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
    
    int _maxBalls;
    BOOL _isBallsFired;
    NSMutableArray *_balls;
    
    int _bulletNum;
    int _colorID;
    NSArray *_bulletNo;
    NSArray *_bushNo;
    NSArray *_ballNo;
}


- (void)didLoadFromCCB
{
    // enable touch
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    
    _cannon.zOrder = DrawingOrderCannon;
    
    _bulletNo = @[@"RedBullet", @"GreenBullet", @"BlueBullet", @"YellowBullet", @"OrangeBullet", @"VioletBullet"];
    _bushNo = @[@"RedBush", @"GreenBush", @"BlueBush", @"YellowBush", @"OrangeBush", @"VioletBush"];
    _ballNo = @[@"RedBall", @"GreenBall", @"BlueBall", @"YellowBall", @"OrangeBall", @"VioletBall"];
    
    // random color code for this game
    _colorID = arc4random_uniform(6);
    
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
    
}

- (void)fireBalls
{
    // 5 - 10
    int numOfBalls = arc4random_uniform(6) + 5;
    // 1 - 5;
    int numOfTargetBalls = arc4random_uniform(numOfBalls) + 1;
    
    for (int i = 0; i <= numOfBalls; i++) {
        
        
        CCNode *ball = [CCBReader load:_ballNo[_colorID]];
        ball.zOrder = DrawingOrderBall;
        ball.positionType = CCPositionTypeNormalized;
        ball.position = ccp(0.5f, 0.02f);
        
        int shootAngle = arc4random_uniform(90) + 1;
        // 45 - 135 degree
        shootAngle += 45;
        
        CGPoint unitVector = ccpForAngle(DEGREES_TO_RADIANS(shootAngle));
        [_physicsNode addChild:ball];
        
        [ball.physicsBody applyImpulse:ccpMult(unitVector, 1000.f)];

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
    
    [bullet.physicsBody applyImpulse:ccpMult(unitVector, 1000.f)];
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

@end
