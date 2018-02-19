#import "DELZombieService.h"

NSMutableArray<DELZombie *> *__zombies;

@implementation DELZombieService

+ (void)createAttackingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale {
    NSString *zombieAttackImage = @"zombie_attack_alpha.png";
    DELZombie *zombieAttack = [[DELZombie alloc] initWithImageNamed:zombieAttackImage
                                                             startX:startX
                                                             startY:startY
                                                           andWidth:45
                                                          andHeight:48
                                                     andFramesCount:27
                                             andMarginBetweenFrames:2
                                                     andScaleFactor:scale];
    [self addZombieToFactory:zombieAttack];
    [zombieAttack goZombieInView:view fromView:nil];
    
}

+ (void)createMovingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale {
    NSString *zombieMovingImage = @"zombie_moving_alpha.png";
    DELZombie *zombieMoving = [[DELZombie alloc] initWithImageNamed:zombieMovingImage
                                                             startX:startX
                                                             startY:startY
                                                           andWidth:39
                                                          andHeight:48
                                                     andFramesCount:10
                                             andMarginBetweenFrames:2
                                                     andScaleFactor:scale];
    [self addZombieToFactory:zombieMoving];
    [zombieMoving setMoving:YES];
    [zombieMoving goZombieInView:view fromView:nil];
}

+ (void)createStandingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale {
    NSString *zombieStandingImage = @"zombie_standing_alpha.png";
    DELZombie *zombieStanding = [[DELZombie alloc] initWithImageNamed:zombieStandingImage
                                                               startX:startX
                                                               startY:startY
                                                             andWidth:37
                                                            andHeight:48
                                                       andFramesCount:10
                                               andMarginBetweenFrames:0
                                                       andScaleFactor:scale];
    [self addZombieToFactory:zombieStanding];
    [zombieStanding goZombieInView:view fromView:nil];
    
}

+ (void)destroyAllZombies {
    for (int i = 0; i < __zombies.count; i++) {
        DELZombie *aliveZombie = [__zombies objectAtIndex:i];
        [aliveZombie performHarakiri];
        aliveZombie = nil;
    }
}

+ (void)addZombieToFactory:(DELZombie *)zombie {
    if (!__zombies) {
        __zombies = [[NSMutableArray alloc] init];
    }
    if (zombie) {
        [__zombies addObject:zombie];
    }
}

@end
