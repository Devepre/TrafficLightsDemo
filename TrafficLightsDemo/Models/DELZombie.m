#import "DELZombie.h"

@interface DELZombie()

@property (strong, nonatomic) UIImage *zombieImage;
@property (assign, nonatomic) float zombieWidth;
@property (assign, nonatomic) float zombieHeight;
@property (assign, nonatomic) float zombieMargin;
@property (assign, nonatomic) float zombieStartX;
@property (assign, nonatomic) float zombieStartY;
@property (assign, nonatomic) float zombieFramesCount;
@property (assign, nonatomic) float scaleFactor;

@end

@implementation DELZombie

- (instancetype)initWithImageNamed:(NSString *)imageName startX:(int)zombieStartX startY:(int)zombieStartY andWidth:(int)zombieWidth andHeight:(int)zombieHeight andFramesCount:(int)zombieFramesCount andMarginBetweenFrames:(int)zombieMargin andScaleFactor:(float)scale {
    self = [super init];
    if (self) {
        _zombieImage = [UIImage imageNamed:imageName];
        _zombieWidth = zombieWidth * scale;
        _zombieHeight = zombieHeight * scale;
        _zombieMargin = zombieMargin * scale;
        _zombieStartX = zombieStartX;
        _zombieStartY = zombieStartY;
        _zombieFramesCount = zombieFramesCount;
        _scaleFactor = scale;
        
        CGSize currentSize = _zombieImage.size;
        currentSize.width*= _scaleFactor;
        currentSize.height*= _scaleFactor;
        _zombieImage = [self imageWithImage:_zombieImage convertToSize:currentSize];
    }
    return self;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)goZombieInView:(UIView *)gameView fromView:(UIImageView *)playerView {
    self.worldView = gameView;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.zombieImage CGImage], CGRectMake(self.zombieMargin / 2, 0,
                                                                                          self.zombieWidth,
                                                                                          self.zombieHeight));
    
    //create an array of both images for the animation
    NSMutableArray *zombieArray = [[NSMutableArray alloc]init];
    [zombieArray addObject:[UIImage imageWithCGImage:imageRef]];
    for (int i = 1; i < self.zombieFramesCount; i++) {
        CGImageRef imageRef = CGImageCreateWithImageInRect([self.zombieImage CGImage], CGRectMake(
                                                                                              i * (self.zombieWidth + self.zombieMargin * 2),
                                                                                              0,
                                                                                              self.zombieWidth,
                                                                                              self.zombieHeight));
        [zombieArray addObject:[UIImage imageWithCGImage:imageRef]];
    }
    
    self.zombieRect = CGRectMake(self.zombieStartX, self.zombieStartY, self.zombieWidth, self.zombieHeight);
    self.zombieView = [[UIImageView alloc] initWithFrame: self.zombieRect];
    
    //set the start image
    [self.zombieView setImage: [UIImage imageWithCGImage:imageRef]];
    
    //animate the image view with the zombie array of images
    self.zombieView.animationImages = zombieArray;
    
    //how often do we want to change the image? every 1/9rd of a second
    self.zombieView.animationDuration = 0.9;
    
    //add the animation to the Game's View
    [self.worldView addSubview: self.zombieView];
    
    //start the zombie's image animation
    [self.zombieView startAnimating];
    
    if (self.moving) {
        self.zombieTimer = [NSTimer scheduledTimerWithTimeInterval:.03
                                                            target:self
                                                          selector:@selector(moveZombie)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    
}

- (void)moveZombie {
    self.zombieRect = CGRectOffset(self.zombieRect, -1, 0);
    self.zombieView.frame = self.zombieRect;
    if(self.zombieRect.origin.x < 10) {
        [self.zombieTimer invalidate];
        self.zombieTimer = nil;
        [self.zombieView removeFromSuperview];
    }
}

- (void)performHarakiri {
    [self.zombieView removeFromSuperview];
}

@end
