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
@property (nonatomic, strong) SKNode *nodeToThrow;
@property (nonatomic, strong) SKPhysicsBody *bodyToThrow;

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

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    switch (self.state) {
        case GameStateReadyToThrow: {
            NSParameterAssert(self.nodeToThrow);
            UITouch *touch = [touches anyObject];
            CGPoint touchPoint = [touch locationInNode:self];
            if ([self nodeAtPoint:touchPoint] == self.nodeToThrow){
                self.state = GameStateDragging;
            }
            break;
        }
        default: {
            break;
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.state != GameStateDragging){
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint touchPosition = [touch locationInNode:self];
    
    self.nodeToThrow.position = touchPosition;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.state != GameStateDragging){
        return;
    }
    CGVector force;
    force.dx = [self startPosition].x - self.nodeToThrow.position.x;
    force.dy = [self startPosition].y - self.nodeToThrow.position.y;
    force.dx = sqrtf(fabs(force.dx)) * 3;
    force.dy = sqrtf(fabs(force.dy)) * 3;
    NSParameterAssert(self.bodyToThrow);
    self.nodeToThrow.physicsBody = self.bodyToThrow;
    [self throwNode:self.nodeToThrow withForce:force];
}

#pragma mark - Game Mechanics

- (void)throwNode:(SKNode *)node withForce:(CGVector)force {
    
    
    self.state = GameStateThrowing;
    [node.physicsBody applyImpulse:force];
}

- (CGPoint)startPosition {
    SKNode *startPosition = [self childNodeWithName:@"StartPosition"];
    NSParameterAssert(startPosition);
    return startPosition.position;
}

- (void)putNodeToThrowToStartPosition:(SKNode *)aNode {
    NSParameterAssert(aNode);
    NSParameterAssert(aNode.physicsBody);
    
    [aNode removeFromParent];
    [self addChild:aNode];
    
    //Временно снимем с нода физическое тело, чтоб он никуда не уходил
    self.bodyToThrow  = aNode.physicsBody;
    aNode.physicsBody = nil;
    
    [aNode runAction:[SKAction moveTo:[self startPosition]
                             duration:1]
          completion:^{
              self.state = GameStateReadyToThrow;
              self.nodeToThrow = aNode;
              [self updateState];
          }];
}

- (SKNode *)nextNodeToThrow {
    return [self.objectsToThrow firstObject];
}

@end
