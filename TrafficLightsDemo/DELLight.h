#import <Foundation/Foundation.h>
#import "DELLightDelegate.h"
#import "DELLightState.h"

@interface DELLight : NSObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL nightMode;
@property (strong, nonatomic) DELLightState *nightLightState;
@property (strong, nonatomic) NSMutableArray<DELLightState *> *lightStates;
@property (assign, nonatomic) NSUInteger currentStateNumber;
@property (assign, nonatomic) NSUInteger currentTicks;
@property (weak, nonatomic) id<DELLightDelegate> delegate;

- (instancetype)initWithLightsArray:(NSMutableArray<DELLightState *> *)array NS_DESIGNATED_INITIALIZER;
- (instancetype)init;
- (void)addStateWithInterval:(NSUInteger)interval andLightStateColor:(LightColor)color;
- (void)setNightStateWithInterval:(NSUInteger)interval andLightStateColor:(LightColor)color;
- (void)recieveOneTick;
- (void)changeStatusToNext;

@end
