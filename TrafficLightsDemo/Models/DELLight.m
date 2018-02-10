#import "DELLight.h"

@implementation DELLight

//Designated initializer
- (instancetype)initWithName:(NSString *)name andDelegate:(id<DELLightDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _name = name;
        _lightStates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)init {
    return [self initWithName:@"Default Name" andDelegate:nil];
}

@end
