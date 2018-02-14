#import "DELControllerWorld.h"

int q = 1;

@implementation DELControllerWorld {
    double _timeQuant;
    DELLightService *_lightService;
}

//Designated initializer
- (instancetype)initWithTimeQuant:(double)timeQuant {
    self = [super init];
    if (self) {
        _lightsArray = [[NSMutableArray alloc] init];
        _lightService = [[DELLightService alloc] init];
        _timeQuant = timeQuant;
    }
    return self;
}

- (instancetype)init {
    return [self initWithTimeQuant:1];
}

- (void)stop {
    DebugLog(@"Timer invalidating...");
    self.working = NO;
    [self.timer invalidate];
}

- (void)start {
    self.working = YES;
//    [self createDefaultLights];
    [self doUpdateView];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeQuant repeats:YES block:^(NSTimer * _Nonnull timer) {
        for (DELLight *currentLight in self.lightsArray) {
            [_lightService recieveOneTickForLight:currentLight];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)createDefaultLights {
    [self addLightTypeA];
    [self addLightTypeB];
    [self addLightTypeC];
}

- (DELLight *)addLightTypeA {
    //First Light
    DELLight *lightRoadOne = [_lightService createLightWithName:@"#1" andDelegate:self];
    [_lightService addStateToLight:lightRoadOne withInterval:9*q andLightStateColor:LightColorRed];
    [_lightService addStateToLight:lightRoadOne withInterval:1*q andLightStateColor:LightColorRed         | LightColorYellow];
    [_lightService addStateToLight:lightRoadOne withInterval:8*q andLightStateColor:LightColorLGreen];
    [_lightService addStateToLight:lightRoadOne withInterval:1*q andLightStateColor:LightColorLGreen      | LightColorBlinking];
    [_lightService addStateToLight:lightRoadOne withInterval:1*q andLightStateColor:LightColorYellow];
    [_lightService addStateToLight:lightRoadOne withInterval:5*q andLightStateColor:LightColorRed];
    [_lightService setToLight:lightRoadOne possibleLights:[[NSArray<DELLightState *> alloc]initWithObjects:[[DELLightState alloc] initWithInterval:0 andColor:LightColorRed], [[DELLightState alloc] initWithInterval:0 andColor:LightColorYellow], [[DELLightState alloc] initWithInterval:0 andColor:LightColorLGreen], nil]];
    
    //Night mode
    [_lightService setNightStateToLight:lightRoadOne withInterval:3 andLightStateColor:LightColorYellow | LightColorBlinking];
    [_lightService setNightMode:YES forLight:lightRoadOne];
    
    [[self lightsArray] addObject:lightRoadOne];
    
    return lightRoadOne;
}

- (DELLight *)addLightTypeB {
    //Second Light
    DELLight *lightRoadTwo = [_lightService createLightWithName:@"#2" andDelegate:self];
    [_lightService addStateToLight:lightRoadTwo withInterval:8*q andLightStateColor:LightColorLGreen];
    [_lightService addStateToLight:lightRoadTwo withInterval:1*q andLightStateColor:LightColorLGreen        | LightColorBlinking];
    [_lightService addStateToLight:lightRoadTwo withInterval:1*q andLightStateColor:LightColorYellow];
    [_lightService addStateToLight:lightRoadTwo withInterval:14*q andLightStateColor:LightColorRed];
    [_lightService addStateToLight:lightRoadTwo withInterval:1*q andLightStateColor:LightColorRed           | LightColorYellow];
    [_lightService setToLight:lightRoadTwo possibleLights:[[NSArray<DELLightState *> alloc]initWithObjects:[[DELLightState alloc] initWithInterval:0 andColor:LightColorRed], [[DELLightState alloc] initWithInterval:0 andColor:LightColorYellow], [[DELLightState alloc] initWithInterval:0 andColor:LightColorLGreen], nil]];
    
    //Night mode
    [_lightService setNightStateToLight:lightRoadTwo withInterval:3 andLightStateColor:LightColorYellow | LightColorBlinking];
    [_lightService setNightMode:YES forLight:lightRoadTwo];
    
    [[self lightsArray] addObject:lightRoadTwo];
    
    return lightRoadTwo;
}

- (DELLight *)addLightTypeC {
    //First Pedestrian Light
    DELLight *lightPedestrianOne = [_lightService createLightWithName:@"#3 Pedestrian" andDelegate:self];
    [_lightService addStateToLight:lightPedestrianOne withInterval:20*q andLightStateColor:LightColorRed];
    [_lightService addStateToLight:lightPedestrianOne withInterval:3*q andLightStateColor:LightColorLGreen];
    [_lightService addStateToLight:lightPedestrianOne withInterval:1*q andLightStateColor:LightColorLGreen  | LightColorBlinking];
    [_lightService addStateToLight:lightPedestrianOne withInterval:1*q andLightStateColor:LightColorRed];
    [_lightService setToLight:lightPedestrianOne possibleLights:[[NSArray<DELLightState *> alloc]initWithObjects:[[DELLightState alloc] initWithInterval:0 andColor:LightColorRed], [[DELLightState alloc] initWithInterval:0 andColor:LightColorLGreen], nil]];
    
    //Night mode
    [_lightService setNightStateToLight:lightPedestrianOne withInterval:3 andLightStateColor:LightColorOff];
    [_lightService setNightMode:YES forLight:lightPedestrianOne];
    
    [[self lightsArray] addObject:lightPedestrianOne];
    
    return lightPedestrianOne;
}

- (void)recieveLightChange:(DELLight *)lightChanged {
//    DebugLog(@"changed object is: %@", [_lightService descriptionForLight:lightChanged]);
    [self doUpdateView];
}

- (void)doUpdateView {
    NSDate *currentDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm'm' ss's' SSSS'ms'"];
    NSString *formattedDateString = [dateFormatter stringFromDate:currentDate];
    printf("%s\n%s\n", [formattedDateString UTF8String], [[self description] UTF8String]);
}

- (NSString *)description {
    NSMutableString *arrayDescription = [[NSMutableString alloc] init];
    for (DELLight *currentLight in self.lightsArray) {
        [arrayDescription appendString:[_lightService descriptionForLight:currentLight]];
        [arrayDescription appendString:@"\n"];
    }
    
    return arrayDescription;
}

@end
