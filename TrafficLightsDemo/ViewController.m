#import "ViewController.h"
#import "DELControllerWorldUI.h"
#import "DELLightUI.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray<DELLightUI *> *lightsHub;
@property (assign, nonatomic) BOOL areLightsAttached;
@property (strong, nonatomic) DELControllerWorldUI *worldController;

@end

@implementation ViewController
- (IBAction)startTouch:(UIButton *)sender {
    DebugLog(@"Start button pressed");
    [self.worldController start];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initializing block
    _lightsHub = [[NSMutableArray alloc] init];
    _areLightsAttached = NO;
    _worldController = [[DELControllerWorldUI alloc] init];
    _worldController.delegate = self;
    
}

//creating Light
- (void)createLightWithXcoord:(CGFloat)coordX andYcoord:(CGFloat)coordY andWidth:(CGFloat)width andColors:(NSArray<UIColor *> *)colors {
    UIView *view = self.contentView;
    
    CGFloat currentX = coordX;
    CGFloat currentY = coordY;
    
    DELLightUI *lightUI = [[DELLightUI alloc] init];
    NSMutableArray<UIImageView *> *images = [[NSMutableArray alloc] init];
    
    for (UIColor *currentColor in colors) {
        UIImageView *imageViewCurrent = [self createLightViewWithColor:currentColor andCoordX:currentX andCoordY:currentY andWidth:width andHeight:width];
        
        [lightUI.lightStatesImages addObject:imageViewCurrent];
        [images addObject:imageViewCurrent];
        [view addSubview:imageViewCurrent];
        currentY+= width;
    }
    
    [lightUI setLightStatesImages:images];
    [self.lightsHub addObject:lightUI];
    
}

- (UIImageView *)createLightViewWithColor:(UIColor *)color andCoordX:(CGFloat)coordX andCoordY:(CGFloat)coordY andWidth:(CGFloat)width andHeight:(CGFloat)height  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(coordX, coordY, width, height)];
    imageView.backgroundColor = color;
    imageView.hidden = YES;
    
    return imageView;
}

- (void)blinkView:(UIView *)view withDuration:(double)duration {
    view.alpha = 0;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         view.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)recieveWorldChange:(DELControllerWorldUI *)controllerWorldUI {
    if (!self.areLightsAttached) {
        [self attachLights:controllerWorldUI.lightsArray];
    }
    
    for (DELLight *currentLightModel in controllerWorldUI.lightsArray) {
        DELLightState *currentLightState = currentLightModel.nightMode ? [currentLightModel nightLightState] : [[currentLightModel lightStates] objectAtIndex:[currentLightModel currentStateNumber]];
        LightColor currentLightColors = currentLightState.color;
        
        NSUInteger idx = [controllerWorldUI.lightsArray indexOfObject:currentLightModel];
        DELLightUI *currentLightUI = [self.lightsHub objectAtIndex:idx];
        
        [self checkInColors:currentLightColors for:currentLightUI];
    }
    
}

- (void)attachLights:(NSMutableArray<DELLight *> *)lightsArray {
    double xCoord = 20;
    int i = 0;
    for (DELLight *currentLight in lightsArray) {
        
        NSMutableArray<UIColor *> *colorsArray = [[NSMutableArray alloc] init];
        UIColor *currentColor = nil;
        NSArray<DELLightState *> *possible = currentLight.possibleLights;
        for (DELLightState *currentLightState in possible) {
            LightColor currentLightColor = currentLightState.color;
            if (currentLightColor & LightColorRed) {
                currentColor = UIColor.redColor;
            } else if (currentLightColor & LightColorYellow) {
                currentColor = UIColor.yellowColor;
            } else if (currentLightColor & LightColorLGreen) {
                currentColor = UIColor.greenColor;
            } else {
                currentColor = UIColor.brownColor;
            }
            
            [colorsArray addObject:currentColor];
        }
        
        [self createLightWithXcoord:xCoord andYcoord:100 andWidth:50 andColors:colorsArray];
        xCoord+= 100;
        i++;
    }
    self.areLightsAttached = YES;
}

- (void)checkInColors:(LightColor)currentLightColors for:(DELLightUI *)currentLightUI {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    LightColor enumColor = 1;
    for (int i = 0; i < 6; i++ ) {
        enumColor<<=1;
        if (enumColor & currentLightColors) {
            [array addObject:[NSNumber numberWithUnsignedInteger:enumColor]];
        }
    }
    
    [self switchColorArray:array On:YES forLight:currentLightUI];
}

- (void)switchColorArray:(NSMutableArray *)array On:(BOOL)on forLight:(DELLightUI *)currentLightUI {
    [self hideAllColorsForLightUI:currentLightUI];
    
    BOOL blinking = NO;
    BOOL off = NO;
    UIView *currentColorView  = nil;
    for (int i = 0; i < [array count] ; i++) {
        LightColor enumColor = [[array objectAtIndex:i] unsignedIntegerValue];
        
        if (LightColorBlinking & enumColor) {
            blinking = YES;
        } else if (LightColorOff & enumColor) {
            off = YES;
        }
        
        if (!currentColorView) {
            currentColorView = [self findViewWithColor:enumColor inLight:currentLightUI];
            currentColorView.hidden = !on;
            if (blinking) {
                [self blinkView:currentColorView withDuration:0.2f];
            } else if(off) {
                currentColorView.hidden = YES;
            }
            currentColorView = nil;
        }
    }
    
}

- (void)hideAllColorsForLightUI:(DELLightUI *)currentLightUI {
    for (UIView *image in currentLightUI.lightStatesImages) {
        image.hidden = YES;
    }
}

- (UIView *)findViewWithColor:(LightColor)enumColor inLight:(DELLightUI *)currentLightUI {
    UIColor *colorFromEnum = [self getUIColorFrom:enumColor];
    for (UIView *view in currentLightUI.lightStatesImages) {
        if ([view.backgroundColor isEqual:colorFromEnum]) {
            [view.layer removeAllAnimations];
            return view;
        }
    }
    return nil;
}

- (UIColor *)getUIColorFrom:(LightColor)enumColor {
    UIColor *currentColor = nil;
    
    if (enumColor & LightColorRed) {
        currentColor = UIColor.redColor;
    } else if (enumColor & LightColorYellow) {
        currentColor = UIColor.yellowColor;
    } else if (enumColor & LightColorLGreen) {
        currentColor = UIColor.greenColor;
    } else {
        currentColor = UIColor.brownColor;
    }
    
    return currentColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

