# PPX_VideoRecording
1,引入类库
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
2,引入头文件
#import "PPX_RecordEngine.h"
#import "PPX_RecordProgressView.h"
3,代理方法
<PPX_RecordEngineDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
4,#pragma mark - set、get方法 开启视频 -
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
5,之后想怎么搞怎么搞
