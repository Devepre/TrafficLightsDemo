#import "ViewController.h"
#import "DELControllerWorldUI.h"

@interface ViewController ()

@property (weak, nonatomic) UIImageView *imageViewOne;
@property (weak, nonatomic) UIImageView *imageViewTwo;
@property (weak, nonatomic) UIImageView *imageViewThree;

@property (strong, nonatomic) NSMutableArray *images;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _images = [[NSMutableArray alloc] init];
    
    [self createLightWithXcoord:170 andYcoord:100 andWidth:50 andColors:[[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], nil]];

}

- (void)createLightWithXcoord:(CGFloat)coordX andYcoord:(CGFloat)coordY andWidth:(CGFloat)width andColors:(NSArray<UIColor *> *)colors {
    CGFloat currentX = coordX;
    CGFloat currentY = coordY;
    for (UIColor *currentColor in colors) {
        UIImageView *imageViewCurrent = [self createLightViewWithColor:currentColor andCoordX:currentX andCoordY:currentY andWidth:width andHeight:width];
        [self.images addObject:imageViewCurrent];
        [self.view addSubview:imageViewCurrent];
        
//        currentX+= width;
        currentY+= width;
    }
}

- (UIImageView *)createLightViewWithColor:(UIColor *)color andCoordX:(CGFloat)coordX andCoordY:(CGFloat)coordY andWidth:(CGFloat)width andHeight:(CGFloat)height  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(coordX, coordY, width, height)];
    imageView.backgroundColor = color;

    return imageView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self blinkView:self.imageViewTwo withDuration:0.5f];
    [self blinkView:[self.images objectAtIndex:1] withDuration:0.5f];
    
    
    DELControllerWorldUI *world = [[DELControllerWorldUI alloc] init];
//    [world start];
}

- (void) blinkView:(UIView *)view withDuration:(double)duration {
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         view.backgroundColor = [UIColor clearColor];
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"animation finished with result %d", finished);
                     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
