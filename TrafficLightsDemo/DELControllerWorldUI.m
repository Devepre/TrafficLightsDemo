#import "DELControllerWorldUI.h"

@implementation DELControllerWorldUI

- (void)doUpdateView {
//    super
//    [self doUpdateView]
    [self.delegate recieveWorldChange:self];
    NSLog(@"Pretty new view is here!");
}

@end
