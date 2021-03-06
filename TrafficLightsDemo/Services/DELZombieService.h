#import <Foundation/Foundation.h>
#import "DELZombie.h"

@interface DELZombieService : NSObject

+ (void)createAttackingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale;
+ (void)createMovingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale;
+ (void)createStandingZombieAtView:(UIView *)view andX:(int)startX andY:(int)startY andScale:(float)scale;
+ (void)destroyAllZombies;

@end
