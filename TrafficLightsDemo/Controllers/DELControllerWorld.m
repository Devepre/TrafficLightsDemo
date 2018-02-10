#import "DELControllerWorld.h"

@implementation DELControllerWorld {
    double _timeQuant;
    DELLightService *_lightService;
}

//Designated initializer
- (instancetype)initWithTimeQuant:(double)timeQuant {
    self = [super init];
    if (self) {
        self.lightsArray = [[NSMutableArray alloc] init];
        _timeQuant = timeQuant;
    }
    return self;
}

- (instancetype)init {
    return [self initWithTimeQuant:1];
}

- (void)start {
    _lightService = [[DELLightService alloc] init];
    [self createDefaultLights];
    [self doUpdateView];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:_timeQuant repeats:YES block:^(NSTimer * _Nonnull timer) {
        for (DELLight *currentLight in self.lightsArray) {
            [_lightService recieveOneTickForLight:currentLight];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)createDefaultLights {
    int q = 2;
    
    //First Light
    DELLight *lightRoadOne = [_lightService createLightWithName:@"#1" andDelegate:self];
    [_lightService addStateToLight:lightRoadOne withInterval:9*q andLightStateColor:LightColorRed];
    [_lightService addStateToLight:lightRoadOne withInterval:1*q andLightStateColor:LightColorRed         | LightColorYellow];
    [_lightService addStateToLight:lightRoadOne withInterval:8*q andLightStateColor:LightColorLGreen];
    [_lightService addStateToLight:lightRoadOne withInterval:1*q andLightStateColor:LightColorLGreen      | LightColorBlinking];
    [_lightService addStateToLight:lightRoadOne withInterval:1*q andLightStateColor:LightColorYellow];
    [_lightService addStateToLight:lightRoadOne withInterval:5*q andLightStateColor:LightColorRed];
    [_lightService setToLight:lightRoadOne possibleLights:[[NSArray<DELLightState *> alloc]initWithObjects:[[DELLightState alloc] initWithInterval:0 andColor:LightColorRed], [[DELLightState alloc] initWithInterval:0 andColor:LightColorYellow], [[DELLightState alloc] initWithInterval:0 andColor:LightColorLGreen], nil]];
     
     
    
    //Second Light
    DELLight *lightRoadTwo = [_lightService createLightWithName:@"#2" andDelegate:self];
    [_lightService addStateToLight:lightRoadTwo withInterval:8*q andLightStateColor:LightColorLGreen];
    [_lightService addStateToLight:lightRoadTwo withInterval:1*q andLightStateColor:LightColorLGreen        | LightColorBlinking];
    [_lightService addStateToLight:lightRoadTwo withInterval:1*q andLightStateColor:LightColorYellow];
    [_lightService addStateToLight:lightRoadTwo withInterval:14*q andLightStateColor:LightColorRed];
    [_lightService addStateToLight:lightRoadTwo withInterval:1*q andLightStateColor:LightColorRed           | LightColorYellow];
    [_lightService setToLight:lightRoadTwo possibleLights:[[NSArray<DELLightState *> alloc]initWithObjects:[[DELLightState alloc] initWithInterval:0 andColor:LightColorRed], [[DELLightState alloc] initWithInterval:0 andColor:LightColorYellow], [[DELLightState alloc] initWithInterval:0 andColor:LightColorLGreen], nil]];
    
    //First Pedestrian Light
    DELLight *lightPedestrianOne = [_lightService createLightWithName:@"#3 Pedestrian" andDelegate:self];
    [_lightService addStateToLight:lightPedestrianOne withInterval:20*q andLightStateColor:LightColorRed];
    [_lightService addStateToLight:lightPedestrianOne withInterval:3*q andLightStateColor:LightColorLGreen];
    [_lightService addStateToLight:lightPedestrianOne withInterval:1*q andLightStateColor:LightColorLGreen  | LightColorBlinking];
    [_lightService addStateToLight:lightPedestrianOne withInterval:1*q andLightStateColor:LightColorRed];
    [_lightService setToLight:lightPedestrianOne possibleLights:[[NSArray<DELLightState *> alloc]initWithObjects:[[DELLightState alloc] initWithInterval:0 andColor:LightColorRed], [[DELLightState alloc] initWithInterval:0 andColor:LightColorLGreen], nil]];
    
    //adding created Lights to World array
    [[self lightsArray] addObject:lightRoadOne];
    [[self lightsArray] addObject:lightRoadTwo];
    [[self lightsArray] addObject:lightPedestrianOne];
    
    //Night mode
    [_lightService setNightStateToLight:lightRoadOne withInterval:3 andLightStateColor:LightColorYellow | LightColorBlinking];
    [_lightService setNightStateToLight:lightRoadTwo withInterval:3 andLightStateColor:LightColorYellow | LightColorBlinking];
    [_lightService setNightStateToLight:lightPedestrianOne withInterval:3 andLightStateColor:LightColorOff];
    
    [_lightService setNightMode:YES forLight:lightRoadOne];
    [_lightService setNightMode:YES forLight:lightRoadTwo];
    [_lightService setNightMode:YES forLight:lightPedestrianOne];
}

- (void)recieveLightChange:(DELLight *)lightChanged {
//    DebugLog(@"changed object is: %@", lightChanged);
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
