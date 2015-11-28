//
//  PL1FastFoodGameScene.m
//  FastFoodIsEvil
//
//  Created by Nikolay Shubenkov on 23/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "PL1FastFoodGameScene.h"
#import "SKAction+SoundFilePlay.h"

typedef NS_ENUM(NSInteger, GameState) {
    GameStateInitial,
    GameStateReadyToThrow,
    GameStateDragging,
    GameStateThrowing
};


@interface PL1FastFoodGameScene ()

@property (nonatomic) GameState state;
@property (nonatomic, strong) NSMutableArray *objectsToThrow;

@end

@implementation PL1FastFoodGameScene

#pragma mark - Setup

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    self.physicsWorld.speed = 0.3;
    [self initContent];
    [self runAction:[SKAction waitForDuration:1] completion:^{
        [self updateState];
    }];
}

- (void)initContent {
    SKPhysicsBody *border = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    border.friction = 0;
    self.physicsBody = border;
    self.objectsToThrow = [NSMutableArray arrayWithObject:[self childNodeWithName:@"meatball"]];
}

#pragma mark - UpdateState

- (void)updateState {
    switch (self.state) {
        case GameStateInitial: {
            [self putNodeToThrowToStartPosition:[self nextNodeToThrow]];
            NSLog(@"Сейчас переместим кого-то в рогатку");
            break;
        }
        case GameStateReadyToThrow:{
            NSLog(@"Можно швырять наш нод");
            break;
        }
        default: {
            NSParameterAssert(NO);
            break;
        }
    }
}

#pragma mark - Game Mechanics

- (void)putNodeToThrowToStartPosition:(SKNode *)aNode {
    NSParameterAssert(aNode);
    SKNode *startPosition = [self childNodeWithName:@"StartPosition"];
    NSParameterAssert(startPosition);
    
    [aNode runAction:[SKAction moveTo:startPosition.position
                             duration:1]
          completion:^{
              self.state = GameStateReadyToThrow;
              [self updateState];
          }];
}

- (SKNode *)nextNodeToThrow {
    return [self.objectsToThrow firstObject];
}

@end
