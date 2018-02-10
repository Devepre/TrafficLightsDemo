#import "DELLightService.h"

@implementation DELLightService

- (void)addStateToLight:(DELLight *)light withInterval:(NSUInteger)interval andLightStateColor:(LightColor)color  {
    DELLightState *state = [[DELLightState alloc] initWithInterval:[NSNumber numberWithUnsignedInteger:interval] andColor:color];
    [[light lightStates] addObject:state];
}

- (void)setNightStateToLight:(DELLight *)light withInterval:(NSUInteger)interval andLightStateColor:(LightColor)color {
    [light setValue:[[DELLightState alloc] initWithInterval:[NSNumber numberWithUnsignedInteger:interval] andColor:color] forKey:@"nightLightState"];
}

- (void)setToLight:(DELLight *)light possibleLights:(NSArray<DELLightState *> *)lights {
    [light setValue:lights forKey:@"possibleLights"];
}

//TODO
//- (void)setToLight:(DELLight *)light possibleLights:(LightColor *)firstArg, ...{
//    va_list args;
//    va_start(args, firstArg);
//    for (LightColor *arg = firstArg; arg != nil; arg = va_arg(args, LightColor*)) {
//
//    }
//    va_end(args);
//}

- (void)recieveOneTickForLight:(DELLight *)light {
//    DebugLog(@"calling: %s", __func__);
    [light setValue:[NSNumber numberWithUnsignedInteger:light.currentTicks + 1] forKey:@"currentTicks"];
    NSNumber *intervalNumber = [[light valueForKey:@"nightMode"] boolValue] ? [light.nightLightState interval] : [[[light lightStates] objectAtIndex:light.currentStateNumber] interval];
    if ([intervalNumber integerValue] == light.currentTicks) {
        [self changeStatusToNextForLight:light];
    }
}

- (void)changeStatusToNextForLight:(DELLight *)light {
    [light setValue:@0 forKey:@"currentTicks"];
    if ([[light valueForKey:@"nightMode"] boolValue]) {
        [light setValue:@NO forKey:@"nightMode"];
        [light setValue:@0 forKey:@"currentStateNumber"];
    } else {
        NSUInteger maxStateNumber = [[light lightStates] count];
        if (light.currentStateNumber == -- maxStateNumber) {
            [light setValue:@0 forKey:@"currentStateNumber"];
        } else {
            [light setValue:[NSNumber numberWithUnsignedInteger:light.currentStateNumber + 1] forKey:@"currentStateNumber"];
        }
    }
    [light.delegate recieveLightChange:light];
}

- (void)setNightMode:(BOOL)nightMode forLight:(DELLight *)light {
    [light setValue:@YES forKey:@"nightMode"];
}

- (DELLight *)createLightWithName:(NSString *)name andDelegate:(id<DELLightDelegate>)delegate {
    DELLight *lightNew = [[DELLight alloc] initWithName:name andDelegate:delegate];
    return lightNew;
}

- (DELLightState *)getCurrentStateForLight:(DELLight *)light {
    DELLightState *currentLightState = light.nightMode ? [light nightLightState] : [[light lightStates] objectAtIndex:[light currentStateNumber]];
    return currentLightState;
}

- (NSString *)descriptionForLight:(DELLight *)light {
    NSString *result = [NSString stringWithFormat:@"%@ -> %@", light.name, [[self getCurrentStateForLight:light] description]];
    
    return result;
}

@end

