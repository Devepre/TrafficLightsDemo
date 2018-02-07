#import "DELControllerWorld.h"
#import "DELControllerWorldUIDelegate.h"

@interface DELControllerWorldUI : DELControllerWorld

@property (weak, nonatomic) id<DELControllerWorldUIDelegate> delegate;

@end
