//
//  PPX_RecordVideoViewController.m
//  PPX_ Video
//
//  Created by pipixia on 16/9/13.
//  Copyright © 2016年 pipixia. All rights reserved.
//

#import "PPX_RecordVideoViewController.h"
#import "PPX_RecordEngine.h"
#import "PPX_RecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    PPX_VideoRecord = 0,
    PPX_VideoLocation,
};

@interface PPX_RecordVideoViewController ()<PPX_RecordEngineDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (nonatomic, strong) PPX_RecordEngine            *recordEngine;
@property (nonatomic, assign) BOOL                        allowRecord;    //允许录制
@property (nonatomic, assign) UploadVieoStyle             videoStyle;     //视频的类型
@property (nonatomic, strong) UIImagePickerController     *moviePicker;   //视频选择器
@property (nonatomic, strong) MPMoviePlayerViewController *playerVC;
@property (nonatomic, strong) PPX_RecordProgressView      *progressView;


@property (nonatomic, strong) UIButton     *flashLightBtn;     //闪光灯
@property (nonatomic, strong) UIButton     *changeCameraBtn;   //摄像头前后
@property (nonatomic, strong) UIButton     *recordNextBtn;     //下一步
@property (nonatomic, strong) UIButton     *recordBtn;         //录制按钮
@property (nonatomic, strong) UIButton     *locationVideoBtn;  //本地视频
@property (nonatomic, strong) UIView       *topViewTop;        //顶部 view
@property (nonatomic, strong) UIView       *bottomView;        //底部 view

@end


@implementation PPX_RecordVideoViewController

- (void)dealloc {
    _recordEngine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:[_playerVC moviePlayer]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recordEngine shutdown];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.allowRecord = YES;
    self.view.backgroundColor = [UIColor blackColor];
    [self creatTopView];
    [self creatbottomView];
   
    
}
- (void)creatTopView
{
    self.topViewTop = [[UIView alloc]init];
    self.topViewTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
    self.topViewTop.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.topViewTop];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"closeVideo"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(20, 30, 19, 19);
    [self.topViewTop addSubview:backButton];
    
    self.changeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeCameraBtn.frame = CGRectMake(SCREEN_WIDTH/2-80, 20, 50, 34);
    [self.changeCameraBtn setBackgroundImage:[UIImage imageNamed:@"changeCamera"] forState:UIControlStateNormal];
    [self.changeCameraBtn addTarget:self action:@selector(changeCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topViewTop addSubview:self.changeCameraBtn];
    
    self.flashLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashLightBtn setBackgroundImage:[UIImage imageNamed:@"flashlightOff"] forState:UIControlStateNormal];
    [self.flashLightBtn setBackgroundImage:[UIImage imageNamed:@"flashlightOn"] forState:UIControlStateSelected];
    [self.flashLightBtn addTarget:self action:@selector(flashLightAction) forControlEvents:UIControlEventTouchUpInside];
    self.flashLightBtn.frame = CGRectMake(SCREEN_WIDTH/2+30, 20, 50, 34);
    [self.topViewTop addSubview:self.flashLightBtn];
    
    self.recordNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordNextBtn setBackgroundImage:[UIImage imageNamed:@"videoNext"] forState:UIControlStateNormal];
    [self.recordNextBtn addTarget:self action:@selector(recordNextAction) forControlEvents:UIControlEventTouchUpInside];
    self.recordNextBtn.frame = CGRectMake(SCREEN_WIDTH-40, 30, 12, 22);
    [self.topViewTop addSubview:self.recordNextBtn];
}
- (void)creatbottomView
{
    self.bottomView = [[UIView alloc]init];
    self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200);
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    
    self.progressView = [[PPX_RecordProgressView alloc]init];
    self.progressView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    self.progressView.progressBgColor = [UIColor blueColor];
    self.progressView.progressColor = [UIColor redColor];
    [self.bottomView addSubview:self.progressView];

    
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"videoRecord"] forState:UIControlStateNormal];
    [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateSelected];
    [self.recordBtn addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    self.recordBtn.frame = CGRectMake((SCREEN_WIDTH-80)/2, 60, 80, 80);
    [self.bottomView addSubview:self.recordBtn];
    
    self.locationVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.locationVideoBtn setBackgroundImage:[UIImage imageNamed:@"locationVideo"] forState:UIControlStateNormal];
    self.locationVideoBtn.frame = CGRectMake(SCREEN_WIDTH-100, 65, 70, 70);
    [self.locationVideoBtn addTarget:self action:@selector(locationVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.locationVideoBtn];
}
#pragma mark - set、get方法 开启视频 -
- (PPX_RecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[PPX_RecordEngine alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

- (UIImagePickerController *)moviePicker {
    if (_moviePicker == nil) {
        _moviePicker = [[UIImagePickerController alloc] init];
        _moviePicker.delegate = self;
        _moviePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _moviePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    return _moviePicker;
}
#pragma mark - PPX_RecordEngineDelegate
- (void)recordProgress:(CGFloat)progress {
    if (progress >= 1) {
        [self recordAction:self.recordBtn];
        self.allowRecord = NO;
    }
    self.progressView.progress = progress;
}

#pragma mark - Apple相册选择代理
//选择了某个照片的回调函数/代理回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        //获取视频的名称
        NSString * videoPath=[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
        NSRange range =[videoPath rangeOfString:@"trim."];//匹配得到的下标
        NSString *content=[videoPath substringFromIndex:range.location+5];
        //视频的后缀
        NSRange rangeSuffix=[content rangeOfString:@"."];
        NSString * suffixName=[content substringFromIndex:rangeSuffix.location+1];
        //如果视频是mov格式的则转为MP4的
        if ([suffixName isEqualToString:@"MOV"]) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            __weak typeof(self) weakSelf = self;
            [self.recordEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
                
                [weakSelf.moviePicker dismissViewControllerAnimated:YES completion:^{
                    weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
                    [[weakSelf.playerVC moviePlayer] prepareToPlay];
                    
                    [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
                    [[weakSelf.playerVC moviePlayer] play];
                }];
            }];
        }
    }
}
#pragma mark -当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerVC dismissMoviePlayerViewControllerAnimated];
    self.playerVC = nil;
}

#pragma mark - 本地视频点击视频
- (void)locationVideoAction{
    self.videoStyle = PPX_VideoLocation;
    [self.recordEngine shutdown];
    [self presentViewController:self.moviePicker animated:YES completion:nil];
}
#pragma mark - 返回点击事件
- (void)dismissAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 开始和暂停录制事件
- (void)recordAction:(UIButton *)sender
{
    if (self.allowRecord) {
        self.videoStyle =  PPX_VideoRecord;
        self.recordBtn.selected = !self.recordBtn.selected;
        if (self.recordBtn.selected) {
            if (self.recordEngine.isCapturing) {
                [self.recordEngine resumeCapture];
            }else {
                [self.recordEngine startCapture];
            }
        }else {
            [self.recordEngine pauseCapture];
        }
        [self topViewFrame];
    }

}
#pragma mark - 根据状态调整view的展示情况
- (void)topViewFrame {
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.recordBtn.selected) {
            self.topViewTop.frame = CGRectMake(0, -64, SCREEN_WIDTH, 64);
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }else {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            self.topViewTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);

        }
        if (self.videoStyle == PPX_VideoRecord) {
            self.locationVideoBtn.alpha = 0;
        }
    } completion:nil];
}
#pragma mark - 切换前后摄像头
- (void)changeCameraAction{
    self.changeCameraBtn.selected = !self.changeCameraBtn.selected;
    if (self.changeCameraBtn.selected == YES) {
        //前置摄像头
        [self.recordEngine closeFlashLight];
        self.flashLightBtn.selected = NO;
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}
#pragma mark - 开关闪光灯
- (void)flashLightAction{
    if (self.changeCameraBtn.selected == NO) {
        self.flashLightBtn.selected = !self.flashLightBtn.selected;
        if (self.flashLightBtn.selected == YES) {
            [self.recordEngine openFlashLight];
        }else {
            [self.recordEngine closeFlashLight];
        }
    }
}
#pragma mark - 录制下一步点击事件
- (void)recordNextAction{
    if (_recordEngine.videoPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
            [[weakSelf.playerVC moviePlayer] prepareToPlay];
            
            [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
            [[weakSelf.playerVC moviePlayer] play];
        }];
    }else {
        NSLog(@"请先录制视频~");
    }
}

@end
