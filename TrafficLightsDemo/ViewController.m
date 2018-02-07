#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) UIImageView *imageViewOne;
@property (weak, nonatomic) UIImageView *imageViewTwo;
@property (weak, nonatomic) UIImageView *imageViewThree;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imageViewOne = [self createLightViewWithColor:[UIColor redColor] andCoordX:170 andCoordY:100 andWidth:100 andHeight:100];
    self.imageViewOne = imageViewOne;
    
    UIImageView *imageViewTwo = [self createLightViewWithColor:[UIColor yellowColor] andCoordX:170 andCoordY:200 andWidth:100 andHeight:100];
    self.imageViewTwo = imageViewTwo;
    
    UIImageView *imageViewThree = [self createLightViewWithColor:[UIColor greenColor] andCoordX:170 andCoordY:300 andWidth:100 andHeight:100];
    self.imageViewThree = imageViewThree;
    
    [self.view addSubview:imageViewOne];
    [self.view addSubview:imageViewTwo];
    [self.view addSubview:imageViewThree];
}

- (UIImageView *)createLightViewWithColor:(UIColor *)color andCoordX:(CGFloat)coordX andCoordY:(CGFloat)coordY andWidth:(CGFloat)width andHeight:(CGFloat)height  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(coordX, coordY, width, height)];
    imageView.backgroundColor = color;

    return imageView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self blinkView:self.imageViewTwo withDuration:0.5f];
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
