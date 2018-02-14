#import "LightsModernViewController.h"
#import "DELLLightView.h"
#import "DELControllerWorldUI.h"
#import "DELLightService.h"

@interface LightsModernViewController ()

@property (strong, nonatomic) NSMutableArray<DELLLightView *> *lightsHub;
@property (assign, nonatomic) BOOL areLightsAttached;
@property (strong, nonatomic) DELControllerWorldUI *worldController;

@end

@implementation LightsModernViewController

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

- (void)recieveWorldChange:(DELControllerWorldUI *)controllerWorldUI {
    if (!self.areLightsAttached) {
        [self attachLights:controllerWorldUI.lightsArray];
    }

    [UIView beginAnimations:@"" context:nil];
    for (DELLight *currentLightModel in controllerWorldUI.lightsArray) {
        DELLightService *lightService = [[DELLightService alloc] init];
        DELLightState *currentLightState = [lightService getCurrentStateForLight:currentLightModel];
        LightColor currentLightColors = currentLightState.color;
        
        NSUInteger idx = [controllerWorldUI.lightsArray indexOfObject:currentLightModel];
        DELLLightView *currentLightUI = [self.lightsHub objectAtIndex:idx];
        
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
        
        CGRect rect = CGRectMake(xCoord, 100, 50, 50);
        DELLLightView *lightView = [[DELLLightView alloc] initWithFrame:rect andColors:colorsArray];
        [self.lightsHub addObject:lightView];
        
        [self.view addSubview:lightView];
        [self attachGesturesTo:lightView];
//        [self.view bringSubviewToFront:lightView];
        xCoord+= 100;
        i++;
    }
    self.areLightsAttached = YES;
}

- (void)checkInColors:(LightColor)currentLightColors for:(DELLLightView *)currentLightUI {
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

- (void)switchColorArray:(NSMutableArray *)array On:(BOOL)on forLight:(DELLLightView *)currentLightUI {
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

- (void)hideAllColorsForLightUI:(DELLLightView *)currentLightUI andArray:(NSMutableArray *)array {
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
                break;
            }
        }
        if (!colorFound) {
            [self turnViewOff:image];
        }
    } 
}

- (void)turnViewOff:(UIView *)currentColorView {
    [currentColorView.layer removeAllAnimations];
    currentColorView.alpha = .15;
}

- (UIView *)findViewWithColor:(LightColor)enumColor inLight:(DELLLightView *)currentLightUI {
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

#pragma mark - buttons handling
- (IBAction)stopStartViewLights:(UIButton *)sender {
    if (self.worldController.working) {
        [sender setTitle:@"Start" forState:UIControlStateNormal];
        [self.worldController stop];
        [self stopLights];
    } else {
        [sender setTitle:@"Power off" forState:UIControlStateNormal];
        [self startWorld];
    }
    
}

- (void)stopLights {
    for (DELLLightView *light in self.lightsHub) {
        for (UIView *view in light.lightStatesImages) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Touches & Gestures

- (void)attachGesturesTo:(DELLLightView *)lightView {
    UIRotationGestureRecognizer* rotationGesture =
    [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationGesture.delegate = self;
    [lightView addGestureRecognizer:rotationGesture];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [lightView addGestureRecognizer:panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    static CGPoint initialCenter;
    if (sender.state == UIGestureRecognizerStateBegan) {
        initialCenter = sender.view.center;
    }
    CGPoint translation = [sender translationInView:sender.view.superview]; //superview is critical for Panning rotated objects!
    sender.view.center = CGPointMake(initialCenter.x + translation.x, initialCenter.y + translation.y);
}

- (void)handleRotation:(UIRotationGestureRecognizer *)sender {
    static CGFloat initialRotation;
    if (sender.state == UIGestureRecognizerStateBegan) {
        initialRotation = atan2f(sender.view.transform.b, sender.view.transform.a);
    }
    CGFloat newRotation = initialRotation + sender.rotation;
    sender.view.transform = CGAffineTransformMakeRotation(newRotation);
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
