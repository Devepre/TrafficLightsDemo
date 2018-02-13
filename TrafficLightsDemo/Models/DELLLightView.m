#import "DELLLightView.h"

@implementation DELLLightView

#pragma mark Object initializations

- (instancetype)initWithFrame:(CGRect)frame andColors:(NSArray<UIColor *> *)colors {
    CGRect myFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width * [colors count]);
    self = [super initWithFrame:myFrame];
    if (self) {
        self.lightStatesImages =[[NSMutableArray<UIImageView *> alloc] init];
        CGPoint point = frame.origin;
        [self createSubViewsWithStartXcoord:point.x andStartYcoord:point.y andWidth:frame.size.width andColors:colors];
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)createSubViewsWithStartXcoord:(CGFloat)coordX andStartYcoord:(CGFloat)coordY andWidth:(CGFloat)width andColors:(NSArray<UIColor *> *)colors {
    if (self) {
        CGFloat currentX = 0;
        CGFloat currentY = 0;
        
        //    DELLightUI *lightUI = [[DELLightUI alloc] init];
        //    NSMutableArray<UIImageView *> *images = [[NSMutableArray alloc] init];
        
        for (UIColor *currentColor in colors) {
            UIImageView *imageViewCurrent = [self createLightViewWithColor:currentColor andCoordX:currentX andCoordY:currentY andWidth:width andHeight:width];
            
            //        [lightUI.lightStatesImages addObject:imageViewCurrent];
            //        [images addObject:imageViewCurrent];
            [self.lightStatesImages addObject:imageViewCurrent];
            
            [self addSubview:imageViewCurrent];
            currentY+= width;
        }
        
        //    [lightUI setLightStatesImages:images];
        //    [self.lightsHub addObject:lightUI];
    }
}

- (UIImageView *)createLightViewWithColor:(UIColor *)color andCoordX:(CGFloat)coordX andCoordY:(CGFloat)coordY andWidth:(CGFloat)width andHeight:(CGFloat)height  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(coordX, coordY, width, height)];
    imageView.backgroundColor = color;
//    [self turnViewOff:imageView];
    
    imageView.layer.cornerRadius = width / 2;
    imageView.clipsToBounds = YES;
    
    return imageView;
}

#pragma mark - Object manipulating

//- (void)blinkView:(UIView *)view withDuration:(double)duration {
//    NSLog(@"BLINKING INSIDE");
//    view.alpha = 0.15;
//    [UIView animateWithDuration:duration
//                          delay:0
//                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
//                     animations:^{
//                         view.alpha = 1.0;
//                     }
//                     completion:nil];
//}
//
//- (void)turnViewOff:(UIView *)currentColorView {
//    printf("LOL_Turning view of: %s %s\n", [[currentColorView description] UTF8String], [[currentColorView.backgroundColor description] UTF8String]);
//    [currentColorView.layer removeAllAnimations];
//    currentColorView.alpha = .15;
//}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
