#import <Foundation/Foundation.h>
#import "DELLight.h"

@interface DELLightService : NSObject

- (DELLight *)createLightWithName:(NSString *)name andDelegate:(id<DELLightDelegate>)delegate ;
- (void)addStateToLight:(DELLight *)light withInterval:(NSUInteger)interval andLightStateColor:(LightColor)color;
- (void)setNightStateToLight:(DELLight *)light withInterval:(NSUInteger)interval andLightStateColor:(LightColor)color;
- (void)recieveOneTickForLight:(DELLight *)light;
- (void)changeStatusToNextForLight:(DELLight *)light;
- (void)setNightMode:(BOOL)nightMode forLight:(DELLight *)light;
- (DELLightState *)getCurrentStateForLight:(DELLight *)light;
- (NSString *)descriptionForLight:(DELLight *)light;
- (void)setToLight:(DELLight *)light possibleLights:(NSArray<DELLightState *> *)lights;

@end

