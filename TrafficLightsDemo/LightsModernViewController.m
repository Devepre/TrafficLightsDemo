#import "LightsModernViewController.h"
#import "DELLLightView.h"
#import "DELControllerWorldUI.h"
#import "DELZombieService.h"

float __scaleForZombieImages = 1.7f;
BOOL __areZombiesCreated = NO;

@interface LightsModernViewController ()

@property (strong, nonatomic) NSMutableArray<DELLLightView *> *lightViewsArray;
@property (assign, nonatomic) BOOL areLightViewsAttached;
@property (strong, nonatomic) DELControllerWorldUI *worldController;
@property (assign, nonatomic) int countOfPossibleLightStates;
@property (strong, nonatomic) DELLightService *lightService;
@property (assign, nonatomic) double defaultLightViewCordinateX;
@property (assign, nonatomic) double defaultLightViewCordinateY;
@property (assign, nonatomic) double defaultLightViewStateWidthAndHeight;
@property (assign, nonatomic) double lightViewStateAlpha;
@property (assign, nonatomic) double lightViewBlinkDuration;

@end

@implementation LightsModernViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initValues];
}

- (void)initValues {
    //default coordinates are approximately in a center of screen
    self.defaultLightViewCordinateX = self.view.frame.size.width / 2;
    self.defaultLightViewCordinateY = self.view.frame.size.height / 2;
    self.defaultLightViewStateWidthAndHeight = 50.f;
    self.lightViewStateAlpha = .05f;
    self.lightViewBlinkDuration = .2f;
    self.countOfPossibleLightStates = 6;
    
    self.areLightViewsAttached = NO;
    self.lightViewsArray = [[NSMutableArray alloc] init];
}

- (void)startWorld {
    if (!self.worldController) {
        self.worldController = [[DELControllerWorldUI alloc] init];
    }
    self.worldController.delegate = self;
    self.lightService = [[DELLightService alloc] init];
    [self.worldController start];
}

- (void)recieveWorldChange:(DELControllerWorldUI *)controllerWorldUI {
    [UIView beginAnimations:@"" context:nil];
    for (DELLight *currentLightModel in controllerWorldUI.lightsArray) {
        DELLightState *currentLightState = [self.lightService getCurrentStateForLight:currentLightModel];
        LightColor currentLightColors = currentLightState.color;
        
        //get LightView item according to LightModel item index
        NSUInteger idx = [controllerWorldUI.lightsArray indexOfObject:currentLightModel];
        DELLLightView *currentLightView = [self.lightViewsArray objectAtIndex:idx];
        
        [self checkInColors:currentLightColors for:currentLightView];
        
        //zombies fun
        int randomX = (arc4random() % (int)(self.view.frame.size.width / 2) ) + self.view.frame.size.width / 2;
        int randomY = (arc4random() % (int)(self.view.frame.size.height / 8) - self.view.frame.size.width / 8);
        if (!__areZombiesCreated) {
            [DELZombieService createMovingZombieAtView:self.view
                                                  andX:randomX
                                                  andY:self.view.frame.size.height / 2 + randomY
                                              andScale:__scaleForZombieImages];
            if ([currentLightModel nightMode] && [currentLightModel.possibleLights count] == 3) {
                [DELZombieService createAttackingZombieAtView:self.view andX:currentLightView.frame.origin.x + 20
                                                         andY:currentLightView.frame.origin.y + 10
                                                     andScale:__scaleForZombieImages];
            }
        }
        if (![currentLightModel nightMode]) {
            [DELZombieService destroyAllZombies];
        }
    }
    __areZombiesCreated = YES;
     //end of zombies fun
    
    [UIView commitAnimations];
}

- (void)createLightViewWith:(NSMutableArray<UIColor *> *)colorsArray xCoord:(double)xCoord yCoord:(double)yCoord andWidth:(double)width {
    CGRect rect = CGRectMake(xCoord, yCoord, width, width);
    DELLLightView *lightView = [[DELLLightView alloc] initWithFrame:rect andColors:colorsArray];
    [self.lightViewsArray addObject:lightView];
    
    [self.view addSubview:lightView];
    [self attachGesturesToView:lightView];
}

- (void)attachOneLightView:(DELLight *)lightToAttach {
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
    
    [self createLightViewWith:colorsArray xCoord:self.defaultLightViewCordinateX yCoord:self.defaultLightViewCordinateY andWidth:self.defaultLightViewStateWidthAndHeight];
    self.areLightViewsAttached = YES;
}

- (void)checkInColors:(LightColor)currentLightColors for:(DELLLightView *)currentLightView {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    LightColor enumColor = 1;
    for (int i = 0; i < self.countOfPossibleLightStates; i++ ) {
        enumColor<<=1;
        if (enumColor & currentLightColors) {
            [array addObject:@(enumColor)];    //equals to -> [array addObject:[NSNumber numberWithUnsignedInteger:enumColor]];
        }
    }
    [self switchColorArray:array On:YES forLight:currentLightView];
}

- (void)switchColorArray:(NSMutableArray *)array On:(BOOL)on forLight:(DELLLightView *)currentLightView {
    [self hideAllColorsForLightView:currentLightView andArray:array];
    
    BOOL blinking = NO;
    BOOL off = NO;
    UIView *currentColorView = nil;
    for (int i = 0; i < array.count; i++) {
        LightColor enumColor = [[array objectAtIndex:i] unsignedIntegerValue];
        
        if (LightColorBlinking & enumColor) {
            blinking = YES;
        } else if (LightColorOff & enumColor) {
            off = YES;
        }
        
        if (!currentColorView) {
            currentColorView = [self findViewWithColor:enumColor inLight:currentLightView];
            currentColorView.alpha = 1;
            
            if (blinking) {
                [self blinkView:currentColorView withDuration:self.lightViewBlinkDuration];
            } else if(off) {
                [self turnViewOff:currentColorView];
            }
            currentColorView = nil;
        }
    }
}

- (void)blinkView:(UIView *)view withDuration:(double)duration {
    view.alpha = self.lightViewStateAlpha;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)hideAllColorsForLightView:(DELLLightView *)currentLightUI andArray:(NSMutableArray *)array {
    //    for (UIView *image in currentLightUI.lightStatesImages) {
    //        [self turnViewOff:image];
    //    }
    
    BOOL colorFound = NO;
    LightColor currentColor = -1;
    for (UIView *image in currentLightUI.lightStatesImages) {
        colorFound = NO;
        for (int i = 0; i < array.count; i++) {
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
    currentColorView.alpha = self.lightViewStateAlpha;
}

- (UIView *)findViewWithColor:(LightColor)enumColor inLight:(DELLLightView *)currentLightView {
    UIColor *colorFromEnum = [self getUIColorFrom:enumColor];
    for (UIView *view in currentLightView.lightStatesImages) {
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
    NSString *captionForButton = nil;
    if (self.worldController.working) {
        captionForButton = NSLocalizedString(@"StartButtonTextStart", @"Start the World title");
        [sender setTitle:captionForButton forState:UIControlStateNormal];
        [self.worldController stop];
        [self resetWorld];
    } else {
        captionForButton = NSLocalizedString(@"StartButtonTextReset", @"Reseting the World title");
        [sender setTitle:captionForButton forState:UIControlStateNormal];
        [self startWorld];
    }
    
}

- (void)resetWorld {
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"AttentionCaption", @"header for attention alert message reseting the World")
                                message:NSLocalizedString(@"AttentionMessageBody", @"message body for attention reseting the World")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    for (DELLLightView *light in self.lightViewsArray) {
        [light removeFromSuperview];
    }
    self.worldController = nil;
    self.areLightViewsAttached = NO;
    self.lightViewsArray = [[NSMutableArray alloc] init];
    __areZombiesCreated = NO;
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
    if (self.isWolrdReadyForAddingLight) {
        DELLight *newLight = [self.worldController addLightTypeA];
        [self attachOneLightView:newLight];
    }
}

- (IBAction)addLightTypeB:(UIButton *)sender {
    if (self.isWolrdReadyForAddingLight) {
        DELLight *newLight = [self.worldController addLightTypeB];
        [self attachOneLightView:newLight];
    }
}

- (IBAction)addLightTypeC:(UIButton *)sender {
    if (self.isWolrdReadyForAddingLight) {
        DELLight *newLight = [self.worldController addLightTypeC];
        [self attachOneLightView:newLight];
    }
}

#pragma mark - Touches & Gestures

- (void)attachGesturesToView:(DELLLightView *)lightView {
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
