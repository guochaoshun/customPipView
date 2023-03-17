//
//  ULRadioDramaLrcView.m
//  ULRadioDrama
//
//  Created by 郭朝顺 on 2023/3/13.
//

#import "ULRadioDramaLrcView.h"
#import "Masonry.h"
#import "ULPipRowNode.h"

@interface ULRadioDramaLrcView ()

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;


@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIButton *collectionButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *nextButton;

@end


@implementation ULRadioDramaLrcView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubview];
    }
    return self;
}

- (void)initSubview {

    self.backgroundColor = [UIColor orangeColor];

    // 顶部歌词
    self.topLabel = [[UILabel alloc] init];
    [self addSubview:self.topLabel];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(10);
        make.left.equalTo(30);
        make.right.equalTo(10);
    }];

    // 底部歌词
    self.bottomLabel = [[UILabel alloc] init];
    [self addSubview:self.bottomLabel];
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLabel.mas_bottom).offset(5);
        make.left.equalTo(30);
        make.right.equalTo(10);
    }];

    // 遮罩视图
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.maskView = maskView;
    self.maskView.hidden = YES;

    /// 收藏按钮
    UIButton *collectionButton = [[UIButton alloc] init];
    collectionButton.backgroundColor = [UIColor redColor];
    [collectionButton addTarget:self action:@selector(collectionAciton:) forControlEvents:UIControlEventTouchUpInside];
    [maskView addSubview:collectionButton];
    [collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.centerY);
        make.centerX.equalTo(self.centerX).multipliedBy(0.6);
        make.width.height.equalTo(30);
    }];
    self.collectionButton = collectionButton;

    /// 播放暂停按钮
    UIButton *playButton = [[UIButton alloc] init];
    playButton.backgroundColor = [UIColor redColor];
    [playButton addTarget:self action:@selector(playAciton:) forControlEvents:UIControlEventTouchUpInside];
    [maskView addSubview:playButton];
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.centerY);
        make.centerX.equalTo(self.centerX);
        make.width.height.equalTo(30);
    }];
    self.playButton = playButton;

    /// 下一首按钮
    UIButton *nextButton = [[UIButton alloc] init];
    nextButton.backgroundColor = [UIColor redColor];
    [nextButton addTarget:self action:@selector(nextAciton:) forControlEvents:UIControlEventTouchUpInside];
    [maskView addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.centerY);
        make.centerX.equalTo(self.centerX).multipliedBy(1.4);
        make.width.height.equalTo(30);
    }];
    self.nextButton = nextButton;
}

- (void)updatePipCustomViewWithRowNode:(ULPipRowNode *)rowNode {
    self.topLabel.text = @"青花瓷-周杰伦";
    self.bottomLabel.text = rowNode.contentString;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if (self.maskView.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            self.maskView.hidden = NO;
            self.maskView.alpha = 1;
        } completion:^(BOOL finished) {

        }];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenMaskView) object:nil];
    [self performSelector:@selector(hiddenMaskView) withObject:nil afterDelay:3];

}

- (void)hiddenMaskView {
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        self.maskView.hidden = YES;
    }];
}


- (void)collectionAciton:(UIButton *)button {
    NSLog(@"collectionAciton");
}

- (void)playAciton:(UIButton *)button {
    NSLog(@"playAciton");

}

- (void)nextAciton:(UIButton *)button {
    NSLog(@"nextAciton");
}

- (void)doubleClick {
    NSLog(@"doubleClick");
}

@end
