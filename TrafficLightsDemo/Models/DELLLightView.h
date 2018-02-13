#import <UIKit/UIKit.h>
#import "DELLight.h"

@interface DELLLightView : UIView

@property (strong, nonatomic) NSMutableArray<UIImageView *> *lightStatesImages;

- (instancetype)initWithFrame:(CGRect)frame andColors:(NSArray<UIColor *> *)colors;

@end
