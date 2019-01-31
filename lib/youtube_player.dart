import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_youtube_plugin/tap_cover.dart';
import 'package:flutter/services.dart';
import 'dart:io';

typedef ControllerDidCreateFun = void Function(YoutubeController controller);


class YoutubeController {

  final MethodChannel _channel;
  final YoutubePlayerState _youtubePlayerState;
  YoutubeController(this._channel,this._youtubePlayerState);

  void play(){
    _youtubePlayerState.coverTap();
    _channel.invokeMethod("play");
  }

  void stop(){
    _channel.invokeMethod("stop");
  }

  void pause(){
    _channel.invokeMethod("pause");
  }

  void seek(double time){
    _channel.invokeMethod("seek",time);
  }

  Future<bool> isPlaying() async {
    int  isPlaying =
    await _channel.invokeMethod('isPlaying');
    bool b = isPlaying != 0;
    return b;
  }

  Future<double> currentTime() async {
    double  currentTime =
    await _channel.invokeMethod('currentTime');
    return currentTime;
  }

}


class YoutubePlayer extends StatefulWidget {

  final String _coverUrl;

  final String _feedId;

  final ControllerDidCreateFun _controllerDidCreateFun;

  YoutubePlayer(this._controllerDidCreateFun,this._coverUrl,this._feedId);

  @override
  State<StatefulWidget> createState() => YoutubePlayerState();
}

class YoutubePlayerState extends State<YoutubePlayer> with WidgetsBindingObserver {

  //use for ios
  bool _hasPlay = false;
  bool _hasPause = false;
  double _seekTime = 0.0;
  YoutubeController _controller;
  bool _isPlaying = true;

  bool coverTap() {
    if(!_hasPlay){
      setState(() {
        _hasPlay = true;
      });
    }
    return true;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPlay) {
        Map<String,dynamic> args = new Map<String,dynamic>();
        args["startTime"] = _seekTime;
        args["isPlaying"] = _isPlaying;
        args["feedId"] = widget._feedId;
        var player = UiKitView(
          creationParams: args,
          creationParamsCodec:StandardMessageCodec(),
          viewType: 'YoutubePlayer',
          onPlatformViewCreated: (int id){
            MethodChannel channel = MethodChannel('plugins.flutter.io/youtube_$id');
            YoutubeController controller = YoutubeController(channel,this);
            _controller = controller;
            if(widget._controllerDidCreateFun != null){
              widget._controllerDidCreateFun(_controller);
            }
          },
          gestureRecognizers:
          <Factory<OneSequenceGestureRecognizer>>[
            new Factory<OneSequenceGestureRecognizer>(
                  () => new TapGestureRecognizer(),
            ),
          ].toSet(),
        );
        _seekTime = 0.0;
      return player;
    } else {
      return TapCover(coverTap,widget._coverUrl);
    }
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState:$state');
    if(Platform.isIOS){
      switch (state) {
        case AppLifecycleState.resumed:
          if(_hasPause){
            _hasPause = false;
            setState(() {
              _hasPlay = true;
            });
          }
          break;
        case AppLifecycleState.paused:
          setState(() {
            if(_hasPlay) {
              if(_controller != null){
                _controller.currentTime().then((double currentTime) {
                  _seekTime = currentTime;
                });
                _controller.isPlaying().then((bool b){
                  _isPlaying = b;
                  if(!_isPlaying){
                    _hasPause = false;
                    _seekTime = 0;
                  } else {
                    _hasPause = true;
                  }
                });
              }
              _hasPlay = false;
            }
          });
          break;
        default:
          break;
      }
    }

  }
}