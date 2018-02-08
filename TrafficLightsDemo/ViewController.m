#import "ViewController.h"
#import "DELControllerWorldUI.h"
#import "DELLightUI.h"

@interface ViewController ()

//@property (weak, nonatomic) UIImageView *imageViewOne;
//@property (strong, nonatomic) NSMutableArray<UIImageView *> *lightStatesImages;
@property (strong, nonatomic) NSMutableArray<DELLightUI *> *lightsHub;
@property (assign, nonatomic) BOOL areLightsAttached;

@property (strong, nonatomic) DELControllerWorldUI *worldController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initializing block
//    _lightStatesImages = [[NSMutableArray alloc] init];
    _lightsHub = [[NSMutableArray alloc] init];
    _areLightsAttached = NO;
    _worldController = [[DELControllerWorldUI alloc] init];
    _worldController.delegate = self;
    
//    [self createLightWithXcoord:170 andYcoord:100 andWidth:50 andColors:[[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], nil]];

}

//creating Light
- (void)createLightWithXcoord:(CGFloat)coordX andYcoord:(CGFloat)coordY andWidth:(CGFloat)width andColors:(NSArray<UIColor *> *)colors {
    CGFloat currentX = coordX;
    CGFloat currentY = coordY;
    
    DELLightUI *lightUI = [[DELLightUI alloc] init];
    NSMutableArray<UIImageView *> *images = [[NSMutableArray alloc] init];
    
    for (UIColor *currentColor in colors) {
        UIImageView *imageViewCurrent = [self createLightViewWithColor:currentColor andCoordX:currentX andCoordY:currentY andWidth:width andHeight:width];
//        [self.lightStatesImages addObject:imageViewCurrent];
        
        [lightUI.lightStatesImages addObject:imageViewCurrent];
//        [self.lightsHub addObject:lightUI];
        [images addObject:imageViewCurrent];

        [self.view addSubview:imageViewCurrent];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self blinkView:[self.lightStatesImages objectAtIndex:1] withDuration:0.5f];
    
    [self.worldController start];
}

- (void) blinkView:(UIView *)view withDuration:(double)duration {
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         view.backgroundColor = [UIColor clearColor];
                     }
                     completion:^(BOOL finished) {
//                         NSLog(@"animation finished with result %d", finished);
                     }];
    
}

- (void)recieveWorldChange:(DELControllerWorldUI *)controllerWorldUI {
    NSMutableArray<DELLight *> *lightsArray = controllerWorldUI.lightsArray;
    
    if (!self.areLightsAttached) { //first iteration
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
    
    //each iteration
    for (DELLight *currentLightModel in controllerWorldUI.lightsArray) {
        DELLightState *currentLightState = currentLightModel.nightMode ? [currentLightModel nightLightState] : [[currentLightModel lightStates] objectAtIndex:[currentLightModel currentStateNumber]];
        LightColor currentLightColors = currentLightState.color;
        
        NSUInteger idx = [controllerWorldUI.lightsArray indexOfObject:currentLightModel];
        DELLightUI *currentLightUI = [self.lightsHub objectAtIndex:idx];
        
        [self checkInColors:currentLightColors for:currentLightUI];
    }
    
}

- (void)checkInColors:(LightColor)currentLightColors for:(DELLightUI *)currentLightUI {
    LightColor enumColor = 1;
    for (int i = 0; i < 6; i++ ) {
        enumColor<<=1;
        if (enumColor & currentLightColors) {
            [self switchColor:enumColor On:YES forLight:currentLightUI];
        } else {
            [self switchColor:enumColor On:NO forLight:currentLightUI];
        }
    }
}

- (void)switchColor:(LightColor)enumColor On:(BOOL)on forLight:(DELLightUI *)currentLightUI {
    UIView *currentColorView = [self findViewWithColor:enumColor inLight:currentLightUI];
    currentColorView.hidden = !on;
    if (LightColorBlinking & enumColor) {
        [self blinkView:currentColorView withDuration:0.5f];
    } else if(LightColorOff & enumColor) {
        currentColorView.hidden = YES;
    }
}

- (UIView *)findViewWithColor:(LightColor)enumColor inLight:(DELLightUI *)currentLightUI {
    for (UIView *view in currentLightUI.lightStatesImages) {
        UIColor *colorFromEnum = [self getUIColorFrom:enumColor];
        if ([view.backgroundColor isEqual:colorFromEnum]) {
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

-(void)hideAllViews {
    if (self.lightsHub) {
        for (DELLightUI *lght in self.lightsHub) {
            for (UIImageView *imageView in lght.lightStatesImages) {
                imageView.hidden = YES;
            }
            NSLog(@"Hiding %@", [lght description]);
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
