#import "DELLightState.h"

@implementation DELLightState

//designated initializer
- (instancetype)initWithInterval:(NSNumber *)interval andColor:(LightColor)color {
    self = [super init];
    if (self) {
        _color = color;
        _interval = interval;
    }
    return self;
}

- (NSString *)description {
    NSArray *colorTypeStrings = @[@"off", @"blinking", @"red", @"green", @"yellow", @"custom"];
    NSMutableArray *enabledColorTypes = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < [colorTypeStrings count]; i++) {
        NSUInteger enumBitValueToCheck = 1 << i;
        if ([self color] & enumBitValueToCheck)
            [enabledColorTypes addObject:[colorTypeStrings objectAtIndex:i]];
    }
    
    NSString *result = enabledColorTypes.count > 0 ?
    [enabledColorTypes componentsJoinedByString:@":"] :
    @"no options";
    
    return result;
}

@end
