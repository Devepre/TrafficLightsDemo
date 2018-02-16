#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DELZombie : NSObject

@property CGRect zombieRect;
@property UIImageView *zombieView;
@property (strong) NSTimer *zombieTimer;
@property UIView *worldView;
@property (assign, nonatomic, getter = isMoving) BOOL moving;

- (instancetype)initWithImageNamed:(NSString *)imageName startX:(int)zombieStartX startY:(int)zombieStartY andWidth:(int)zombieWidth andHeight:(int)zombieHeight andFramesCount:(int)zombieFramesCount andMarginBetweenFrames:(int)zombieMargin andScaleFactor:(float)scale;
- (void)goZombieInView:(UIView *)gameView fromView:(UIImageView *)playerView;

- (void)performHarakiri;
@end
