#import <Foundation/Foundation.h>

@interface DELLightState : NSObject

typedef NS_OPTIONS(NSUInteger, LightColor) {
    LightColorOff               = 1 << 0,
    LightColorBlinking          = 1 << 1,
    LightColorRed               = 1 << 2,
    LightColorLGreen            = 1 << 3,
    LightColorYellow            = 1 << 4,
    LightColorCustom            = 1 << 5,
    //placeholder
};

@property (strong, nonatomic) NSNumber *interval;
@property (assign, nonatomic) LightColor color;

- (instancetype)initWithInterval:(NSNumber *)interval andColor:(LightColor)color;

@end
