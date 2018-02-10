#import <Foundation/Foundation.h>
@class DELControllerWorldUI;

@protocol DELControllerWorldUIDelegate <NSObject>

- (void) recieveWorldChange:(DELControllerWorldUI *) controllerWorldUI;

@end
