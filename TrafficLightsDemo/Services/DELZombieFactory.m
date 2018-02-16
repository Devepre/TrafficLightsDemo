#import "DELZombieFactory.h"

@implementation DELZombieFactory

+ (void)createAttackingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale {
    NSString *zombieAttackImage = @"zombie_attack_alpha.png";
    DELZombie *zombieAttack = [[DELZombie alloc] initWithImageNamed:zombieAttackImage
                                                             startX:1000
                                                             startY:350
                                                           andWidth:45
                                                          andHeight:48
                                                     andFramesCount:27
                                             andMarginBetweenFrames:2
                                                     andScaleFactor:scale];
    [zombieAttack goZombieInView:view fromView:nil];
    
}

+ (void)createMovingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale {
    NSString *zombieMovingImage = @"zombie_moving_alpha.png";
    DELZombie *zombieMoving = [[DELZombie alloc] initWithImageNamed:zombieMovingImage
                                                             startX:700
                                                             startY:350
                                                           andWidth:39
                                                          andHeight:48
                                                     andFramesCount:10
                                             andMarginBetweenFrames:2
                                                     andScaleFactor:scale];
    [zombieMoving setMoving:YES];
    [zombieMoving goZombieInView:view fromView:nil];
}

+ (void)createStandingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale {
    NSString *zombieStandingImage = @"zombie_standing_alpha.png";
    DELZombie *zombieStanding = [[DELZombie alloc] initWithImageNamed:zombieStandingImage
                                                               startX:400
                                                               startY:350
                                                             andWidth:37
                                                            andHeight:48
                                                       andFramesCount:10
                                               andMarginBetweenFrames:0
                                                       andScaleFactor:scale];
    [zombieStanding goZombieInView:view fromView:nil];
    
}

@end
