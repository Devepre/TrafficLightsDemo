#import "LightsViewController.h"
#import "DELControllerWorldUI.h"
#import "DELLightUI.h"
#import "DELLightService.h"

@interface LightsViewController ()

@property (strong, nonatomic) NSMutableArray<DELLightUI *> *lightsHub;
@property (assign, nonatomic) BOOL areLightsAttached;
@property (strong, nonatomic) DELControllerWorldUI *worldController;

@end

@implementation LightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startWorld];
}

- (void)startWorld {
    //initializing block
    _lightsHub = [[NSMutableArray alloc] init];
    _areLightsAttached = NO;
    _worldController = [[DELControllerWorldUI alloc] init];
    _worldController.delegate = self;
    [self.worldController start];
}

//creating Light
- (void)createLightWithXcoord:(CGFloat)coordX andYcoord:(CGFloat)coordY andWidth:(CGFloat)width andColors:(NSArray<UIColor *> *)colors {
    CGFloat currentX = coordX;
    CGFloat currentY = coordY;
    
    DELLightUI *lightUI = [[DELLightUI alloc] init];
    NSMutableArray<UIImageView *> *images = [[NSMutableArray alloc] init];
    
    for (UIColor *currentColor in colors) {
        UIImageView *imageViewCurrent = [self createLightViewWithColor:currentColor andCoordX:currentX andCoordY:currentY andWidth:width andHeight:width];
        
        [lightUI.lightStatesImages addObject:imageViewCurrent];
        [images addObject:imageViewCurrent];
        [self.contentView addSubview:imageViewCurrent];
        currentY+= width;
    }
    
    [lightUI setLightStatesImages:images];
    [self.lightsHub addObject:lightUI];
    
}

- (UIImageView *)createLightViewWithColor:(UIColor *)color andCoordX:(CGFloat)coordX andCoordY:(CGFloat)coordY andWidth:(CGFloat)width andHeight:(CGFloat)height  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(coordX, coordY, width, height)];
    imageView.backgroundColor = color;
    [self turnViewOff:imageView];
    
    imageView.layer.cornerRadius = width / 2;
    imageView.clipsToBounds = YES;
    
    return imageView;
}

- (void)blinkView:(UIView *)view withDuration:(double)duration {
    view.alpha = 0.15;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)recieveWorldChange:(DELControllerWorldUI *)controllerWorldUI {
    [UIView beginAnimations:@"" context:nil];
    
    if (!self.areLightsAttached) {
        [self attachLights:controllerWorldUI.lightsArray];
    }
    
    for (DELLight *currentLightModel in controllerWorldUI.lightsArray) {
        DELLightService *lightService = [[DELLightService alloc] init];
        DELLightState *currentLightState = [lightService getCurrentStateForLight:currentLightModel];
        LightColor currentLightColors = currentLightState.color;
        
        NSUInteger idx = [controllerWorldUI.lightsArray indexOfObject:currentLightModel];
        DELLightUI *currentLightUI = [self.lightsHub objectAtIndex:idx];
        
        [self checkInColors:currentLightColors for:currentLightUI];
    }
    [UIView commitAnimations];
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
    [self hideAllColorsForLightUI:currentLightUI andArray:array];
    
    BOOL blinking = NO;
    BOOL off = NO;
    UIView *currentColorView  = nil;
    for (int i = 0; i < [array count]; i++) {
        LightColor enumColor = [[array objectAtIndex:i] unsignedIntegerValue];
        
        if (LightColorBlinking & enumColor) {
            blinking = YES;
        } else if (LightColorOff & enumColor) {
            off = YES;
        }
        
        if (!currentColorView) {
            currentColorView = [self findViewWithColor:enumColor inLight:currentLightUI];
//            currentColorView.hidden = !on;
            currentColorView.alpha = 1;
            
            if (blinking) {
                [self blinkView:currentColorView withDuration:0.2f];
            } else if(off) {
                [self turnViewOff:currentColorView];
            }
            currentColorView = nil;
        }
    }
}

- (void)turnViewOff:(UIView *)currentColorView {
    printf("\nTurning view of: %s %s\n", [[currentColorView description] UTF8String], [[currentColorView.backgroundColor description] UTF8String]);
    [currentColorView.layer removeAllAnimations];
    currentColorView.alpha = .15;
}

- (void)hideAllColorsForLightUI:(DELLightUI *)currentLightUI andArray:(NSMutableArray *)array {
//    for (UIView *image in currentLightUI.lightStatesImages) {
//        [self turnViewOff:image];
//    }
    BOOL colorFound = NO;
    LightColor currentColor = -1;
    for (UIView *image in currentLightUI.lightStatesImages) {
        colorFound = NO;
        for (int i = 0; i < [array count]; i++) {
            currentColor = [[array objectAtIndex:i] unsignedIntegerValue];
            if (image.backgroundColor == [self getUIColorFrom:currentColor]) {
                colorFound = YES;
                NSLog(@"Color found: %@ %@", image, image.backgroundColor);
                break;
            }
        }
        if (!colorFound) {
            [self turnViewOff:image];
        }
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

- (IBAction)stopViewLights:(UIButton *)sender {
    if (self.worldController.working) {
        [sender setTitle:@"Start" forState:UIControlStateNormal];
        [self.worldController stop];
        [self stopLights];
    } else {
        [sender setTitle:@"Powe off" forState:UIControlStateNormal];
        [self startWorld];
    }
    

}

- (void)stopLights {
    for (DELLightUI *light in self.lightsHub) {
        for (UIView *view in light.lightStatesImages) {
            [self turnViewOff:view];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
