#import "DELControllerWorldUI.h"

@implementation DELControllerWorldUI

- (void)doUpdateView {
    [super doUpdateView];
    
    [self.delegate recieveWorldChange:self];
}

@end
