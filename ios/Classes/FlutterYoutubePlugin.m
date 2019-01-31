#import "FlutterYoutubePlugin.h"
#import <youtube-ios-player-helper/YTPlayerView.h>
#import "YoutubeViewFactory.h"

@implementation FlutterYoutubePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [registrar registerViewFactory:[[YoutubeViewFactory alloc] initWithMessenger:registrar.messenger]  withId:@"YoutubePlayer"];
}
@end
