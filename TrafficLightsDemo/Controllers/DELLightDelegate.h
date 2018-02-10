#import <Foundation/Foundation.h>
@class DELLight;

@protocol DELLightDelegate <NSObject>

- (void) recieveLightChange:(DELLight *) light;

@end
