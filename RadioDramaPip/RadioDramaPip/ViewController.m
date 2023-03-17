//
//  ViewController.m
//  RadioDramaPip
//
//  Created by 郭朝顺 on 2023/3/13.
//

#import "ViewController.h"
#import "ULPipManager.h"
#import "ULRadioDramaLrcView.h"


@interface ViewController ()<ULPipManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];



    
    // 这部分代码 等点击播放广播剧的时候再调用,暂停播放要有对应的停止方法
    ULPipManager *pipManager = [ULPipManager shareManager];
    pipManager.delegate = self;
    [self.view.layer insertSublayer:pipManager.playerLayer atIndex:0];


    ULRadioDramaLrcView *lrcView = [[ULRadioDramaLrcView alloc] init];
    [pipManager configCustomView:lrcView];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    ULPipManager *pipManager = [ULPipManager shareManager];
    [pipManager startPictureInPicture];
}


@end
