//
//  DCVideoRecorder.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/10.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCVideoRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "DCVideoUtil.h"
#import "DCVideoModel.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define MaxRecordTime 20

@interface DCVideoRecorder ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic,strong)AVCaptureSession *session;
@property (nonatomic,strong)AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong)AVCaptureDeviceInput *audioInput;
@property (nonatomic,strong)AVCaptureMovieFileOutput *fileOutput;
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong)UIView *superView;

@property (nonatomic,strong)AVCaptureStillImageOutput *imageOutput;

@property (nonatomic,strong)DCVideoModel *currentModel;

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger recordTime;


@end

@implementation DCVideoRecorder

#pragma mark - lazy
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _session.sessionPreset=AVCaptureSessionPreset1280x720;
        }
    }
    return _session;
}


- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (id)initWithSuperView:(UIView *)view{
    self = [super init];
    if (self) {
        self.superView = view;
        [self run];
    }
    return self;
}

- (void)run {
    [self setUpInit];
    [self setUpVideo];
    [self setUpAudio];
    [self setUpFileOut];
    [self setUpPreviewLayer];
    [self.session startRunning];
}

- (void)setUpInit {
    
}

//设置视频输入源
- (void)setUpVideo {
    AVCaptureDevice *videoCaptureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    NSError *error = nil;
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:videoCaptureDevice error:&error];
    if (error) {
        NSLog(@"videoCaptureDevice error");
        return;
    }
    self.imageOutput = [[AVCaptureStillImageOutput alloc]init];
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
}

//设置音频输入
- (void)setUpAudio {
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error = nil;
    self.audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"audioCaptureDevice error");
        return;
    }
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
}

//设置写入文件
- (void)setUpFileOut {
    self.fileOutput = [[AVCaptureMovieFileOutput alloc]init];
    AVCaptureConnection *captureConnection = [self.fileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    CGSize outputSize = [UIScreen mainScreen].bounds.size;
    NSInteger numPixels = outputSize.width * outputSize.height;
    //每像素比特
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    //视频属性
    NSDictionary *videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                       AVVideoWidthKey : @(outputSize.height),
                                       AVVideoHeightKey : @(outputSize.width),
                                       AVVideoCompressionPropertiesKey : compressionProperties };
    [self.fileOutput setOutputSettings:videoCompressionSettings forConnection:captureConnection];
    if ([captureConnection isVideoStabilizationSupported]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    captureConnection.videoOrientation = [self.previewLayer connection].videoOrientation;
    if ([self.session canAddOutput:self.fileOutput]) {
        [self.session addOutput:self.fileOutput];
    }
}

//设置预览图层的frame
- (void)setUpPreviewLayer {
    CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    if (self.superView) {
        rect = self.superView.bounds;
    }
    self.previewLayer.frame = rect;
    [self.superView.layer insertSublayer:self.previewLayer atIndex:0];
}


- (void)startRecordWithFilePath:(NSString *)path {
    self.recordTime = 0;
    [self writeDataToFile:path];
}

- (void)stopRecord{
    [self.fileOutput stopRecording];
    [self stop];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)stop {
    [self.session stopRunning];
}

- (void)runing {
    [self.session startRunning];
}

- (void)takePhoto:(void(^)(UIImage *image))complier {
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        complier(nil);
        return;
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            complier(nil);
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        UIImage *image = [UIImage imageWithData:imageData];
        complier(image);
    }];
}

- (void)writeDataToFile:(NSString *)path {
    NSURL *videoUrl = [NSURL fileURLWithPath:path];
    [self.fileOutput startRecordingToOutputFileURL:videoUrl recordingDelegate:self];
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark - AVCaptureFileOutputRecordingDelegate 
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"开始写入");
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeStart) userInfo:nil repeats:YES];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"写入完成");
}

- (void)timeStart {
    self.recordTime += 1;
    if (self.recordTime >= MaxRecordTime) {
//        [self stopRecord:nil];
    }
}




@end
