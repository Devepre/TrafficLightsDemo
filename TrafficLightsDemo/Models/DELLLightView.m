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
        self.backgroundColor = UIColor.blackColor;
    }
    return self;
}

- (void)createSubViewsWithStartXcoord:(CGFloat)coordX andStartYcoord:(CGFloat)coordY andWidth:(CGFloat)width andColors:(NSArray<UIColor *> *)colors {
    if (self) {
        CGFloat currentX = 0;
        CGFloat currentY = 0;
        for (UIColor *currentColor in colors) {
            UIImageView *imageViewCurrent = [self createLightViewWithColor:currentColor andCoordX:currentX andCoordY:currentY andWidth:width andHeight:width];
            [self.lightStatesImages addObject:imageViewCurrent];
            [self addSubview:imageViewCurrent];
            currentY+= width;
        }
    }

    float border = 3;
    CALayer * externalBorder = [CALayer layer];
    externalBorder.frame = CGRectMake(-border, -border, self.frame.size.width + border * 2, self.frame.size.height + border * 2);
    externalBorder.borderColor = UIColor.lightGrayColor.CGColor;
    externalBorder.borderWidth = border;

    [self.layer addSublayer:externalBorder];
    self.layer.masksToBounds = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.translatesAutoresizingMaskIntoConstraints = true;
    
}

- (UIImageView *)createLightViewWithColor:(UIColor *)color andCoordX:(CGFloat)coordX andCoordY:(CGFloat)coordY andWidth:(CGFloat)width andHeight:(CGFloat)height  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(coordX, coordY, width, height)];
    imageView.backgroundColor = color;
    
    //round corners
    imageView.layer.cornerRadius = width / 2;
    imageView.clipsToBounds = YES;
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    imageView.layer.borderWidth = 1;
    
    return imageView;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
