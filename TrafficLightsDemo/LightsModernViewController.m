#import "LightsModernViewController.h"
#import "DELLLightView.h"
#import "DELControllerWorldUI.h"
#import "DELLightUI.h"
#import "DELLightService.h"

@interface LightsModernViewController ()

@property (strong, nonatomic) NSMutableArray<DELLLightView *> *lightsHub;
@property (assign, nonatomic) BOOL areLightsAttached;
@property (strong, nonatomic) DELControllerWorldUI *worldController;
@property (weak, nonatomic) UIView* draggingView;
@property (assign, nonatomic) CGPoint touchOffset;

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

-(IBAction)unwindToMainViewController:(UIStoryboardSegue *)segue {
    ;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self logTouches:touches withMethod:@"touchesBegan"];
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.view];
    UIView* view = [self.view hitTest:pointOnMainView withEvent:event];
    if (![view isEqual:self.view]) {
        self.draggingView = view;
        [self.view bringSubviewToFront:self.draggingView];
        CGPoint touchPoint = [touch locationInView:self.draggingView];
        self.touchOffset = CGPointMake(CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                       CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
        //[self.draggingView.layer removeAllAnimations];
        [UIView animateWithDuration:0.3
                         animations:^{
//                             self.draggingView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                             self.draggingView.alpha = 0.7f;
                         }];
    } else {
        self.draggingView = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self logTouches:touches withMethod:@"touchesMoved"];
    if (self.draggingView) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        CGPoint correction = CGPointMake(pointOnMainView.x + self.touchOffset.x,
                                         pointOnMainView.y + self.touchOffset.y);
        self.draggingView.center = correction;
    }
    
}

- (void) onTouchesEnded {
    [UIView animateWithDuration:0.3
                     animations:^{
//                         self.draggingView.transform = CGAffineTransformIdentity;
                         self.draggingView.alpha = 1.f;
                     }];
    self.draggingView = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self logTouches:touches withMethod:@"touchesEnded"];
    [self onTouchesEnded];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self logTouches:touches withMethod:@"touchesCancelled"];
    [self onTouchesEnded];
}


- (void) logTouches:(NSSet*)touches withMethod:(NSString*) methodName {
    NSMutableString* string = [NSMutableString stringWithString:methodName];
    for (UITouch* touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        [string appendFormat:@" %@", NSStringFromCGPoint(point)];
    }
    NSLog(@"%@", string);
}

- (IBAction)startTestViewLights:(UIButton *)sender {
    
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
