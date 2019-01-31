import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

typedef TapFun = bool Function();


class TapCover extends StatefulWidget {
  final TapFun _tapFun;

  final String _url;


  /// constructor function
  TapCover(this._tapFun,this._url);

  @override
  State<StatefulWidget> createState() => TapCoverState();
}

class TapCoverState extends State<TapCover> {

  bool _offstage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
        offstage: _offstage,
        child: GestureDetector(
          onTap:(){
             bool offstage = widget._tapFun();
             setState(() {
               _offstage = offstage;
             });
          },
          child: widget._url == null ?
          Container(
            color: Colors.red,
          ) : new CachedNetworkImage(
            imageUrl: widget._url,
          ),
        )
    );
  }
}