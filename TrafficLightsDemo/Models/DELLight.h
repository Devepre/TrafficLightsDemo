#import <Foundation/Foundation.h>
#import "DELLightDelegate.h"
#import "DELLightState.h"

@interface DELLight : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) BOOL nightMode;
@property (strong, nonatomic, readonly) DELLightState *nightLightState;
@property (strong, nonatomic, readonly) NSArray<DELLightState *> *possibleLights;
//@property (assign, nonatomic, readonly) LightColor *possibleLights;   //todo
@property (strong, nonatomic, readonly) NSMutableArray<DELLightState *> *lightStates;
@property (assign, nonatomic, readonly) NSUInteger currentStateNumber;
@property (assign, nonatomic, readonly) NSUInteger currentTicks;
@property (weak, nonatomic) id<DELLightDelegate> delegate;

- (instancetype)initWithName:(NSString *)name andDelegate:(id<DELLightDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end
