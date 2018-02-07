#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) UIImageView *imageViewOne;
@property (weak, nonatomic) UIImageView *imageViewTwo;
@property (weak, nonatomic) UIImageView *imageViewThree;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView* imageViewOne = [[UIImageView alloc] initWithFrame:CGRectMake(170, 100, 100, 100)];
    imageViewOne.backgroundColor = [UIColor redColor];
    self.imageViewOne = imageViewOne;
    
    UIImageView* imageViewTwo = [[UIImageView alloc] initWithFrame:CGRectMake(170, 200, 100, 100)];
    imageViewTwo.backgroundColor = [UIColor yellowColor];
    self.imageViewTwo = imageViewTwo;
    
    UIImageView* imageViewThree = [[UIImageView alloc] initWithFrame:CGRectMake(170, 300, 100, 100)];
    imageViewThree.backgroundColor = [UIColor greenColor];
    self.imageViewThree = imageViewThree;
    
    [self.view addSubview:imageViewOne];
    [self.view addSubview:imageViewTwo];
    [self.view addSubview:imageViewThree];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self moveView:self.imageViewTwo];
}

- (void) moveView:(UIView*) view {
    CGRect rect = self.view.bounds;
    rect = CGRectInset(rect, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
    double duration = 0.5f;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         view.backgroundColor = [UIColor clearColor];
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"animation finished! %d", finished);
                     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
