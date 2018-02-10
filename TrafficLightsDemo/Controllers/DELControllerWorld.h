#import <Foundation/Foundation.h>
#import "DELLight.h"
#import "DELLightService.h"

@interface DELControllerWorld : NSObject<DELLightDelegate>

@property (strong, nonatomic) NSMutableArray<DELLight *> *lightsArray;

- (instancetype)initWithTimeQuant:(double)timeQuant NS_DESIGNATED_INITIALIZER;
- (instancetype)init;
- (void)start;
- (void)doUpdateView;

@end
