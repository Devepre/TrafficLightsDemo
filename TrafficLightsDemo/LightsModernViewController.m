#import "LightsModernViewController.h"
#import "DELLLightView.h"
#import "DELControllerWorldUI.h"
#import "DELLightService.h"

@interface LightsModernViewController ()

@property (strong, nonatomic) NSMutableArray<DELLLightView *> *lightsHub;
@property (assign, nonatomic) BOOL areLightsAttached;
@property (strong, nonatomic) DELControllerWorldUI *worldController;

@property (assign, nonatomic) double defaultLightCordinateX;
@property (assign, nonatomic) double defaultLightCordinateY;
@property (assign, nonatomic) double defaultLightStateWidthHeight;
@property (assign, nonatomic) double lightStateAlpha;
@property (assign, nonatomic) double blinkDuration;

@end

@implementation LightsModernViewController

- (void)initValues {
    self.defaultLightCordinateX = self.view.frame.size.width / 2;
    self.defaultLightCordinateY = self.view.frame.size.height / 2;
    self.defaultLightStateWidthHeight = 50.f;
    self.lightStateAlpha = .05f;
    self.blinkDuration = .2f;
    
    self.areLightsAttached = NO;
    self.lightsHub = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initValues];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)startWorld {
    if (!self.worldController) {
        self.worldController = [[DELControllerWorldUI alloc] init];
    }
    _worldController.delegate = self;
    [self.worldController start];
}

- (void)recieveWorldChange:(DELControllerWorldUI *)controllerWorldUI {
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

- (void)createLightViewWith:(NSMutableArray<UIColor *> *)colorsArray xCoord:(double)xCoord yCoord:(double)yCoord andWidth:(double)width {
    CGRect rect = CGRectMake(xCoord, yCoord, width, width);
    DELLLightView *lightView = [[DELLLightView alloc] initWithFrame:rect andColors:colorsArray];
    [self.lightsHub addObject:lightView];
    
    [self.view addSubview:lightView];
    [self attachGesturesTo:lightView];
}

- (void)attachOneLight:(DELLight *)lightToAttach {
    NSMutableArray<UIColor *> *colorsArray = [[NSMutableArray alloc] init];
    UIColor *currentColor = nil;
    NSArray<DELLightState *> *possible = lightToAttach.possibleLights;
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
    
    [self createLightViewWith:colorsArray xCoord:self.defaultLightCordinateX yCoord:self.defaultLightCordinateY andWidth:self.defaultLightStateWidthHeight];
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
                [self blinkView:currentColorView withDuration:self.blinkDuration];
            } else if(off) {
                [self turnViewOff:currentColorView];
            }
            currentColorView = nil;
        }
    }
}

- (void)blinkView:(UIView *)view withDuration:(double)duration {
    view.alpha = self.lightStateAlpha;
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
    currentColorView.alpha = self.lightStateAlpha;
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
        [self resetWorld];
    } else {
        NSLog(@"Starting world button");
        [sender setTitle:@"Reset" forState:UIControlStateNormal];
        [self startWorld];
    }
    
}

- (void)resetWorld {
    for (DELLLightView *light in self.lightsHub) {
        [light removeFromSuperview];
    }
    self.worldController = nil;
    self.areLightsAttached = NO;
    self.lightsHub = [[NSMutableArray alloc] init];
}

- (BOOL)isWolrdReadyForAddingLight {
    if (self.worldController.working) {
        return NO;
    } else if (!self.worldController) {
        self.worldController = [[DELControllerWorldUI alloc] init];
    }
    return YES;
}

- (IBAction)addLightTypeA:(UIButton *)sender {
    if ([self isWolrdReadyForAddingLight]) {
        DELLight *newLight = [self.worldController addLightTypeA];
        [self attachOneLight:newLight];
    }
}

- (IBAction)addLightTypeB:(UIButton *)sender {
    if ([self isWolrdReadyForAddingLight]) {
        DELLight *newLight = [self.worldController addLightTypeB];
        [self attachOneLight:newLight];
    }
}

- (IBAction)addLightTypeC:(UIButton *)sender {
    if ([self isWolrdReadyForAddingLight]) {
        DELLight *newLight = [self.worldController addLightTypeC];
        [self attachOneLight:newLight];
    }
}

#pragma mark - Touches & Gestures

- (void)attachGesturesTo:(DELLLightView *)lightView {
    UIRotationGestureRecognizer *rotationGesture =
    [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationGesture.delegate = self;
    [lightView addGestureRecognizer:rotationGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [lightView addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [lightView addGestureRecognizer:tapGesture];
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

- (void)handleTapGesture:(UIRotationGestureRecognizer *)sender {
    [UIView beginAnimations:@"" context:nil];
    float rotationAngle = -M_PI / 2;
    rotationAngle+= sender.view.tag * M_PI / 2;
    sender.view.tag++;
    sender.view.transform = CGAffineTransformMakeRotation(rotationAngle);
    [UIView commitAnimations];
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
