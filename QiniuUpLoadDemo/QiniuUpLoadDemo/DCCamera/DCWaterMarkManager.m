//
//  DCWaterMarkManager.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/10.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCWaterMarkManager.h"
#import "DCPhotoPreview.h"
#import "DCLocationManager.h"
#import "DCVideoUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDAVAssetExportSession.h"
#import "DCVideoUtil.h"


@implementation DCWaterMarkManager{
    AVAssetExportSession *_assetExport;
    NSTimer *_exportProgressBarTimer;
    float preLayerWidth;//镜头宽
    float preLayerHeight;//镜头高
    float preLayerHWRate; //高，宽比
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)updateExportDisplay {
    CGFloat progress = _assetExport.progress;
    if (progress > .99) {
        [_exportProgressBarTimer invalidate];
        _exportProgressBarTimer = nil;
    }
    NSLog(@"%f  %@",progress,_exportProgressBarTimer);
}




-(void)createWatermark:(UIImage *)waterMarkImg video:(NSString *)videoPath complier:(void(^)(BOOL success,NSString *outputUrl))complier
{
    if (videoPath == nil) {
        return;
    }
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSData *data = [NSData dataWithContentsOfURL:videoURL];
    NSLog(@"水印前 %f   %@",data.length / 1024.0,videoURL);
    //1 创建AVAsset实例 AVAsset包含了video的所有信息 self.videoUrl输入视频的路径
    AVAsset *videoAsset = [AVAsset assetWithURL:videoURL];
    //     AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //    videoTrack.estimatedDataRate //比特率
    //    [DCVideoUtil deleteVideo:videoPath];
    DCVideoModel *model = [DCVideoUtil createNewVideo];
    //    [DCVideoUtil deleteVideo:model.videoAbsolutePath];
    
    
    NSURL *outPutURL = [NSURL fileURLWithPath:model.videoAbsolutePath];
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:videoAsset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = outPutURL;
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @540,
    AVVideoHeightKey: @960,
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @1500000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @1,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         BOOL success = NO;
         if (encoder.status == AVAssetExportSessionStatusCompleted)
         {
             NSLog(@"Video export succeeded");
             success = YES;
             NSData *data = [NSData dataWithContentsOfURL:outPutURL];
             NSLog(@"水印后 %f   %@",data.length / 1024.0,outPutURL);
         }
         else if (encoder.status == AVAssetExportSessionStatusCancelled)
         {
             NSLog(@"Video export cancelled");
         }
         else
         {
             NSLog(@"Video export failed with error: %@ (%d)", encoder.error.localizedDescription, encoder.error.code);
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             if (success) {
                 ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
                 [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outPutURL completionBlock:^(NSURL *assetURL, NSError *error) {
                     if (error) {
                         NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
                     }
                     NSLog(@"成功保存视频到相簿.");
                 }];
             }
             complier(success,model.videoAbsolutePath);
         });
     }];
    
    /*
     //2 创建AVMutableComposition实例. apple developer 里边的解释 【AVMutableComposition is a mutable subclass of AVComposition you use when you want to create a new composition from existing assets. You can add and remove tracks, and you can add, remove, and scale time ranges.】
     AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
     
     //3 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
     AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
     preferredTrackID:kCMPersistentTrackID_Invalid];
     //把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
     //获取duration的时候，不要用asset.duration，应该用track.timeRange.duration，用前者的时间不准确，会导致黑帧。同时AVURLAssetPreferPreciseDurationAndTimingKey设为YES
     AVAssetTrack *videoTrack1 = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
     [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack1.timeRange.duration)
     ofTrack:videoTrack1
     atTime:kCMTimeZero error:nil];
     
     NSArray *array = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
     if (array.count != 0) {
     AVAssetTrack *assetAudioTrack = array[0];
     AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
     [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack1.timeRange.duration) ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
     }
     
     //3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
     AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
     mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
     
     // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
     AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
     AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
     UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
     BOOL isVideoAssetPortrait_  = NO;
     CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
     if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
     videoAssetOrientation_ = UIImageOrientationRight;
     isVideoAssetPortrait_ = YES;
     }
     if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
     videoAssetOrientation_ =  UIImageOrientationLeft;
     isVideoAssetPortrait_ = YES;
     }
     if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
     videoAssetOrientation_ =  UIImageOrientationUp;
     }
     if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
     videoAssetOrientation_ = UIImageOrientationDown;
     }
     [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
     [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
     
     // 3.3 - Add instructions
     mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
     //AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
     AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
     
     CGSize naturalSize;
     if(isVideoAssetPortrait_){
     naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
     } else {
     naturalSize = videoAssetTrack.naturalSize;
     }
     
     float renderWidth, renderHeight;
     renderWidth = naturalSize.width;
     renderHeight = naturalSize.height;
     mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
     mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
     mainCompositionInst.frameDuration = CMTimeMake(1, 30);
     NSLog(@"比特率 : %f  帧率 : %f",[videoTrack estimatedDataRate] / 1000,[videoTrack nominalFrameRate]);
     
     
     //比特率是指每秒传送的比特(bit)数。单位为 bps(Bit Per Second)，比特率越高，传送数据速度越快。声音中的比特率是指将模拟声音信号转换成数字声音信号后，单位时间内的二进制数据量，是间接衡量音频质量的一个指标。 视频中的比特率（码率）原理与声音中的相同，都是指由模拟信号转换为数字信号后，单位时间内的二进制数据量。
     
     //
     NSString *logStr = [NSString stringWithFormat:@"%@&&%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"kLocationMsg"],[DCPhotoPreview currentDateStr]];
     [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize waterMark:[DCPhotoPreview ImageWithText:logStr]];
     
     ;
     // 4 - 输出路径
     //    DCVideoModel *model = [DCVideoUtil createNewVideo];
     NSURL* exportUrl = videoURL; //[NSURL fileURLWithPath:model.videoAbsolutePath];
     
     if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]){
     [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
     }
     
     // 5 - 视频文件输出
     AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
     presetName:AVAssetExportPreset960x540];
     exporter.outputURL=exportUrl;
     exporter.outputFileType = AVFileTypeQuickTimeMovie;
     exporter.shouldOptimizeForNetworkUse = YES;
     exporter.videoComposition = mainCompositionInst;
     _assetExport = exporter;
     _exportProgressBarTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateExportDisplay) userInfo:nil repeats:YES];
     
     [exporter exportAsynchronouslyWithCompletionHandler:^{
     BOOL success = NO;
     switch (exporter.status) {
     case AVAssetExportSessionStatusUnknown:
     NSLog(@"Unknown");
     break;
     case AVAssetExportSessionStatusWaiting:
     NSLog(@"Waiting");
     break;
     case AVAssetExportSessionStatusExporting:
     NSLog(@"Exporting");
     break;
     case AVAssetExportSessionStatusCompleted:
     {
     NSLog(@"Created new water mark image");
     success = YES;
     NSData *data = [NSData dataWithContentsOfURL:exportUrl];
     NSLog(@"水印后 %f   %@",data.length / 1024.0,exportUrl);
     
     
     
     
     }
     break;
     case AVAssetExportSessionStatusFailed:
     NSLog(@"Failed- %@", _assetExport.error);
     break;
     case AVAssetExportSessionStatusCancelled:
     NSLog(@"Cancelled");
     break;
     }
     dispatch_async(dispatch_get_main_queue(), ^{
     if (success) {
     ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
     [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exporter.outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
     if (error) {
     NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
     }
     NSLog(@"成功保存视频到相簿.");
     }];
     }
     complier(success);
     });
     
     }];
     */
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size waterMark:(UIImage *)image
{
    
    
    
    // 1 - Set up the text layer
    CALayer *aLayer = [CALayer layer];
    aLayer.contents = (id)image.CGImage;
    aLayer.frame = CGRectMake(size.width - image.size.width, 0, image.size.width,image. size.height);
    aLayer.contentsGravity = kCAGravityResizeAspect;
    
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:aLayer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}



@end
