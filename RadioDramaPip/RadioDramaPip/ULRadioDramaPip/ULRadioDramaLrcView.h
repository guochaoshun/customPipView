//
//  ULRadioDramaLrcView.h
//  ULRadioDrama
//
//  Created by 郭朝顺 on 2023/3/13.
//

#import <UIKit/UIKit.h>
#import "ULPipManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ULRadioDramaLrcView : UIView<ULPipManagerViewDelegate>

- (void)updatePipCustomViewWithRowNode:(ULPipRowNode *)rowNode;

@end

NS_ASSUME_NONNULL_END
