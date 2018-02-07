#import "DELLight.h"

@implementation DELLight

//Designated initializer
- (instancetype)initWithLightsArray:(NSMutableArray *)array  {
    self = [super init];
    if (self) {
        _lightStates = array;
    }
    return self;
}

- (instancetype)init {
    return [self initWithLightsArray:[[NSMutableArray alloc] init]];
}

- (void)addStateWithInterval:(NSUInteger)interval andLightStateColor:(LightColor)color  {
    DELLightState *state = [[DELLightState alloc] initWithInterval:[NSNumber numberWithUnsignedInteger:interval] andColor:color];
    [[self lightStates] addObject:state];
}

- (void)setNightStateWithInterval:(NSUInteger)interval andLightStateColor:(LightColor)color {
    [self setNightLightState:[[DELLightState alloc] initWithInterval:[NSNumber numberWithUnsignedInteger:interval] andColor:color]];
}

- (void)recieveOneTick {
    DebugLog(@"calling: %s", __func__);
    self.currentTicks++;
    NSNumber *intervalNumber = self.nightMode ? [self.nightLightState interval] : [[[self lightStates] objectAtIndex:self.currentStateNumber] interval];
    if ([intervalNumber integerValue] == self.currentTicks) {
        [self changeStatusToNext];
    }
}

- (void)changeStatusToNext {
    self.currentTicks = 0;
    
    if (self.nightMode) {
        [self setNightMode:NO];
        [self setCurrentStateNumber:0];
    } else {
        NSUInteger maxStateNumber = [[self lightStates] count];
        self.currentStateNumber = [self currentStateNumber] == --maxStateNumber ? 0 : ++self.currentStateNumber;
    }
    [self.delegate recieveLightChange:self];
    DebugLog(@"!_change status_! to: %@\n", self);
}

- (NSString *)description {
    DELLightState *currentLightState = self.nightMode ? [self nightLightState] : [[self lightStates] objectAtIndex:[self currentStateNumber]];
    NSString *currentState = [currentLightState description];
    NSString *result = [NSString stringWithFormat:@"%@ -> %@", [self name], currentState];
    
    return result;
}

@end
