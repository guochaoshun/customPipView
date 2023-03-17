//
//  ULPipManager.m
//  RadioDramaPip
//
//  Created by 郭朝顺 on 2023/3/14.
//

#import "ULPipManager.h"
#import "Masonry.h"
#import "ULPipRowNode.h"

@interface ULPipManager ()<AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) AVPictureInPictureController *pipController;

@property (nonatomic, strong) UIView<ULPipManagerViewDelegate> *customView;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGRect startFrame;

@end

@implementation ULPipManager

+ (instancetype)shareManager {

    static dispatch_once_t onceToken;
    static ULPipManager *manager = nil;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[ULPipManager alloc] init];
        }
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initPip];
    }
    return self;
}

- (void)initPip {

    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        [self setupPlayer];
        [self setupNoti];

    } else {
        NSLog(@"PictureInPicture is not Supported");
    }

}

- (void)configCustomView:(UIView<ULPipManagerViewDelegate> *)customView {
    self.customView = customView;
}



// 开启画中画
- (void)startPictureInPicture {

    NSLog(@"gcs --startPictureInPicture %@",[UIApplication sharedApplication].windows);
    if (!self.pipController.isPictureInPictureActive) {
        [self.pipController startPictureInPicture];
    }
}

- (void)stopPictureInPicture {
    if (self.pipController.isPictureInPictureActive) {
        NSLog(@"stopPictureInPicture");
        [self.pipController stopPictureInPicture];
    }
}


#pragma mark -AVPictureInPictureControllerDelegate
// 即将开启画中画
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    self.playerLayer.frame = self.startFrame;
    NSLog(@"即将开启画中画");

    UIWindow *targetWindow = [self findPipWindow];
    if (targetWindow) {
        targetWindow.canResizeToFitContent = NO;
        [targetWindow addSubview:self.customView];
        [self.customView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(targetWindow);
        }];

        [self testLrc];
    }
}

// 开启画中画完成
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"开启画中画完成");

}

/// 开启画中画失败, 原因
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"开启画中画失败, %@",error);
}

// 即将关闭画中画
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"即将关闭画中画");

}

/// 关闭画中画完成
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"关闭画中画完成");
    _pipController = nil;
    [self pipController];
    self.playerLayer.frame = self.startFrame;
}


/// 关闭画中画
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    NSLog(@"关闭画中画完成,保存用户UI");

    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    UIWindow *pipWindow = [self findPipWindow];
    [UIView animateWithDuration:0.25 animations:^{
        self.playerLayer.frame = CGRectMake(0, screenHeight-1, pipWindow.frame.size.width, pipWindow.frame.size.height);
    }];


    if (completionHandler) {
        completionHandler(YES);
    }
}

- (AVPictureInPictureController *)pipController {

    if (_pipController == nil) {
        _pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
        _pipController.delegate = self;
        // 隐藏播放按钮、快进快退按钮
        // TODO: 郭朝顺,危险操作
        // 0: 顶部叉号,恢复按钮,中间 快退 播放 快进按钮, 底部播放进度条; 默认样式
        // 1: 只有左右叉号和恢复2个按钮
        // 2: 无任何按钮,视频以原始大小展示
        // 3以后: 不显示视频内容,显示loading,中间无按钮
        if ([_pipController respondsToSelector:@selector(setControlsStyle:)]) {
            [_pipController setValue:@(1) forKey:@"controlsStyle"];
        }
    }
    return _pipController;
}


/// 查找画中画视图窗口
- (UIWindow *)findPipWindow {
    UIWindow *targetWindow = nil;
    // avplayer所在的window类型为PGHostedWindow && 不是keyWindow && windowLevel为-10000000
    // https://stackoverflow.com/questions/48176804/what-is-pghostedwindow-in-window-hierarcy-on-ipad-and-how-to-prevent-their-creat
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *tempWindow in windows) {
        if ([tempWindow isKindOfClass:NSClassFromString(@"PGHostedWindow")] && tempWindow.isKeyWindow == NO) {
            targetWindow = tempWindow;
            break;
        }
    }
    return targetWindow;
}


- (void)setupPlayer {

    @try {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES withOptions:1 error:&error];
    } @catch (NSException *exception) {
        NSLog(@"AVAudioSession发生错误");
    }
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    self.startFrame = CGRectMake(0, 0, screenWidth, screenHeight-40);

    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
    playerLayer.frame = self.startFrame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer = playerLayer;


    // 视频的比例会影响画中画视图高度,和手势双击放大缩小
//    NSURL *mp4Video = [[NSBundle mainBundle] URLForResource:@"方形视频" withExtension:@"MP4"];
//    NSURL *mp4Video = [[NSBundle mainBundle] URLForResource:@"竖向视频" withExtension:@"MP4"];
//    NSURL *mp4Video = [[NSBundle mainBundle] URLForResource:@"横向视频" withExtension:@"MP4"];
    NSURL *mp4Video = [[NSBundle mainBundle] URLForResource:@"横向视频_2" withExtension:@"MP4"];
    AVAsset *asset = [AVAsset assetWithURL:mp4Video];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    playerLayer.player = player;
    player.muted = YES;
    player.allowsExternalPlayback = YES;
    self.player = player;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:)  name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];


    [self pipController];

}

- (void)setupNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

/// 回到前台, 移除画中画
- (void)applicationEnterForeground:(NSNotification *)notice {
    if (self.player.rate > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopPictureInPicture];
        });
    } else {
        [self.player play];
        NSLog(@"player恢复播放");
    }
}
/// 退后台, 显示画中画
- (void)applicationDidEnterBackground:(NSNotification *)notice {
//    [self startPictureInPicture];
}



- (void)moviePlayDidEnd:(NSNotification*)notification{
    AVPlayerItem*item = [notification object];
    [item seekToTime:kCMTimeZero completionHandler:nil];
    [self.player play];
}


- (NSArray *)lrcArray {
    NSArray *array = @[
        @"素眉勾勒秋千话北风龙转丹",
        @"屏层鸟绘的牡丹一如你梳妆",
        @"黯然腾香透过窗心事我了然",
        @"宣纸上皱边直尺各一半",
        @"油色渲染侍女图因为被失藏",
        @"而你嫣然的一笑如含苞待放",
        @"你的美一缕飘散",
        @"去到我去不了的地方"];
    return array;
}

- (void)testLrc {

    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }

    __block NSInteger i = 0;

    ULPipRowNode *rowNode = [[ULPipRowNode alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {

        NSString *contentStr = self.lrcArray[i];
        rowNode.contentString = contentStr;
        [self.customView updatePipCustomViewWithRowNode:rowNode];
        i++;
        if (i>= self.lrcArray.count) {
            i = 0;
        }
    }];
}



@end
