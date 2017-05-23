//
//  DCAddWaterMark.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/9.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCAddWaterMark.h"
#import <UIKit/UIKit.h>


@interface DCAddWaterMark ()

@property (nonatomic,strong) CALayer *waterLayer;
@property (nonatomic,strong) AVMutableComposition *mutableComposition;
@property (nonatomic,strong) AVMutableVideoComposition *mutableVideoComposition;
@property (nonatomic,strong) AVAssetExportSession *exportSession;
@end

@implementation DCAddWaterMark

- (void)performWithAsset:(AVAsset*)asset path:(NSString *)path {
    self.waterLayer = nil;
    CGSize videoSize;
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    CMTime instertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    //step 1
    if (!self.mutableComposition) {
        self.mutableComposition = [AVMutableComposition composition];
        if (assetVideoTrack != nil) {
            AVMutableCompositionTrack *compostionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compostionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:instertionPoint error:&error];
        }
        if (assetAudioTrack != nil) {
            AVMutableCompositionTrack *compostionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compostionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:instertionPoint error:&error];
        }
    }
    
    //step 2
    if ([self.mutableComposition tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        if (!self.mutableVideoComposition) {
            self.mutableVideoComposition = [AVMutableVideoComposition videoComposition];
            self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
            self.mutableVideoComposition.renderSize = assetVideoTrack.naturalSize;
            AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.mutableComposition duration]);
            
            AVAssetTrack *videoTrack = [self.mutableComposition tracksWithMediaType:AVMediaTypeVideo][0];
            AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            passThroughInstruction.layerInstructions = @[passThroughLayer];
            self.mutableVideoComposition.instructions = @[passThroughInstruction];
        }
        videoSize = self.mutableVideoComposition.renderSize;
        self.waterLayer = [self watermarkLayerForSize:videoSize];
    }
    if (error == nil) {
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        self.waterLayer.position = CGPointMake(videoSize.width/2, videoSize.height/4);
        [parentLayer addSublayer:self.waterLayer];
        self.mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        
        //导出视频
        
        AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:assetAudioTrack];
        [mixParameters setVolumeRampFromStartVolume:1 toEndVolume:0 timeRange:CMTimeRangeMake(kCMTimeZero, self.mutableComposition.duration)];
        
        AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
        mutableAudioMix.inputParameters = @[mixParameters];
        
        self.exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.mutableComposition copy] presetName:AVAssetExportPreset960x540];
        self.exportSession.videoComposition = self.mutableVideoComposition;
        self.exportSession.audioMix = mutableAudioMix;
        self.exportSession.outputURL = [NSURL fileURLWithPath:path];
        self.exportSession.outputFileType=AVFileTypeQuickTimeMovie;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^(void){
            switch (self.exportSession.status) {
                case AVAssetExportSessionStatusCompleted:
                    [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:path]];
//                    [asset ];
                    // Step 3
                    // Notify AVSEViewController about export completion
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Failed:%@",self.exportSession.error);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Canceled:%@",self.exportSession.error);
                    break;
                default:
                    break;
            }
        }];

        
    }else {
        
    }
}

- (void)writeVideoToPhotoLibrary:(NSURL *)url
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"Video could not be saved");
        }
    }];
}

- (CALayer*)watermarkLayerForSize:(CGSize)videoSize
{
    // Create a layer for the title
    CALayer *_watermarkLayer = [CALayer layer];
    
    // Create a layer for the text of the title.
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = @"AVSE";
    titleLayer.foregroundColor = [[UIColor whiteColor] CGColor];
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.bounds = CGRectMake(0, 0, videoSize.width/2, videoSize.height/2);
    titleLayer.backgroundColor = [UIColor redColor].CGColor;
    // Add it to the overall layer.
    [_watermarkLayer addSublayer:titleLayer];
    
    return _watermarkLayer;
}

@end
