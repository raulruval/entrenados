import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget cachedNetworkImage(
    String mediaUrl, context, bool inTile) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    height: !inTile
        ? MediaQuery.of(context).size.width * 0.5
        : MediaQuery.of(context).size.width * 0.3,
    width: !inTile
        ? MediaQuery.of(context).size.width * 0.5
        : MediaQuery.of(context).size.width * 0.3,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(20.0),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
