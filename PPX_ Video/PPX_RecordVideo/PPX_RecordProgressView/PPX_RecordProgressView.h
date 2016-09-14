//
//  PPX_RecordProgressView.h
//  PPX_ Video
//
//  Created by pipixia on 16/9/13.
//  Copyright © 2016年 pipixia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPX_RecordProgressView : UIView

@property (assign, nonatomic) CGFloat progress;//当前进度
@property (strong, nonatomic) UIColor *progressBgColor;//进度条背景颜色
@property (strong, nonatomic) UIColor *progressColor;//进度条颜色
@property (assign, nonatomic) CGFloat loadProgress;//加载好的进度
@property (strong, nonatomic) UIColor *loadProgressColor;//已经加载好的进度颜色

@end
