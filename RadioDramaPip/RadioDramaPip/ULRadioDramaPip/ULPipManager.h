//
//  ULPipManager.h
//  RadioDramaPip
//
//  Created by 郭朝顺 on 2023/3/14.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ULPipRowNode;
@protocol ULPipManagerViewDelegate <NSObject>

- (void)updatePipCustomViewWithRowNode:(ULPipRowNode *)rowNode;

@end

@protocol ULPipManagerDelegate <NSObject>


@end


@interface ULPipManager : NSObject

@property (nonatomic, weak) id<ULPipManagerDelegate> delegate;

@property (nonatomic, strong, readonly) AVPlayer *player;

@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;

@property (nonatomic, strong, readonly) AVPictureInPictureController *pipController;

@property (nonatomic, strong, readonly) UIView<ULPipManagerViewDelegate> *customView;

+ (instancetype)shareManager;

- (void)configCustomView:(UIView<ULPipManagerViewDelegate> *)customView;

// 开启画中画
- (void)startPictureInPicture;
// 关闭画中画
- (void)stopPictureInPicture;

/// 查找画中画视图窗口
- (UIWindow *)findPipWindow;

@end

NS_ASSUME_NONNULL_END
