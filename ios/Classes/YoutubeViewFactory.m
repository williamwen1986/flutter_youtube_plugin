//
//  YoutubeViewFactory.m
//  Runner
//
//  Created by wen william on 2019/1/22.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import "YoutubeViewFactory.h"
#import <youtube-ios-player-helper/YTPlayerView.h>

@interface YoutubeViewFactory()
@property (strong,nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@end


@interface YoutubeViewObject : NSObject<FlutterPlatformView,YTPlayerViewDelegate>
@property (nonatomic) CGRect frame;
@property (nonatomic) int64_t viewId;
@property (nonatomic) float startTime;
@property (strong ,nonatomic) NSString* feedId;
@property (strong ,nonatomic) YTPlayerView* player;
@property (nonatomic) BOOL autoPlay;
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                       feedId:(NSString *)feedId
                         args:(id)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

@implementation YoutubeViewFactory

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        self.messenger = messenger;
    }
    return self;
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args
{
    YoutubeViewObject * o = [[YoutubeViewObject alloc] initWithFrame:frame viewIdentifier:viewId feedId:[args objectForKey:@"feedId"] args:args binaryMessenger:self.messenger];
    return o;
}

@end

@implementation YoutubeViewObject

- (void)playerView:(nonnull YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    NSLog(@"YTPlayerState %@",@(state));
    if(state == kYTPlayerStatePlaying){
        if (!self.autoPlay) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [playerView pauseVideo];
            });
            self.autoPlay = true;
        }
    }
}


- (void)playerViewDidBecomeReady:(nonnull YTPlayerView *)playerView
{
    NSLog(@"playerViewDidBecomeReady");
    [playerView playVideo];
    [playerView seekToSeconds:self.startTime allowSeekAhead:YES];
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    feedId:(NSString *)feedId
                         args:(id) args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        self.player = [[YTPlayerView alloc] initWithFrame:self.frame];
        NSDictionary *playvarsDic = @{ @"controls" : @1, @"playsinline" : @1, @"autohide" : @1, @"showinfo" : @1, @"autoplay": @1, @"modestbranding" : @1 };
        [self.player loadWithVideoId:feedId playerVars:playvarsDic];
        self.player.delegate = self;
        self.startTime = [[args objectForKey:@"startTime"] floatValue];
        self.autoPlay = [[args objectForKey:@"isPlaying"] boolValue];
        NSString* channelName = [NSString stringWithFormat:@"plugins.flutter.io/youtube_%lld", viewId];
        FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf onMethodCall:call result:result];
        }];
    }
    return self;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([[call method] isEqualToString:@"play"]) {
        [self.player playVideo];
        result(nil);
    } else if ([[call method] isEqualToString:@"pause"]) {
        [self.player pauseVideo];
        result(nil);
    } else if ([[call method] isEqualToString:@"stop"]) {
        [self.player stopVideo];
        result(nil);
    } else if ([[call method] isEqualToString:@"currentTime"]) {
        result(@([self.player currentTime]));
    } else if ([[call method] isEqualToString:@"isPlaying"]) {
        result(@([self.player playerState] == kYTPlayerStatePlaying));
    } else if ([[call method] isEqualToString:@"seek"]) {
        [self.player seekToSeconds:[call.arguments floatValue] allowSeekAhead:YES];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}


- (UIView*)view
{
    return self.player;
}

-(void)dealloc
{
    NSLog(@"");
}

@end
