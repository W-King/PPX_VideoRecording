//
//  PPX_RecordEngine.h
//  PPX_ Video
//
//  Created by pipixia on 16/9/13.
//  Copyright © 2016年 pipixia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>


typedef NS_ENUM(NSUInteger, VieoErrorType) {
    PPX_VieoError_RearCamera = 0,
    PPX_VieoError_FrontFacingCamera,
    PPX_VieoError_Microphone,
};

@protocol PPX_RecordEngineDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@optional
- (void)vieoErrorType:(VieoErrorType)vieoErrorType;

@end

@interface PPX_RecordEngine : NSObject


@property (atomic, assign, readonly) BOOL isCapturing;//正在录制
@property (atomic, assign, readonly) BOOL isPaused;//是否暂停
@property (atomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (atomic, assign) CGFloat maxRecordTime;//录制最长时间
@property (weak, nonatomic) id<PPX_RecordEngineDelegate>delegate;
@property (atomic, strong) NSString *videoPath;//视频路径

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;
//启动录制功能
- (void)startUp;
//关闭录制功能
- (void)shutdown;
//开始录制
- (void) startCapture;
//暂停录制
- (void) pauseCapture;
//停止录制
- (void) stopCaptureHandler:(void (^)(UIImage *movieImage))handler;
//继续录制
- (void) resumeCapture;
//开启闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;
//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
//将mov的视频转成mp4
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler;

@end
