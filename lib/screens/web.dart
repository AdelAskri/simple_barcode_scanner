// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';

/// Barcode scanner for web using iframe
class BarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
  final Widget? child;
  BarcodeScanner({
    super.key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    required this.onScanned,
    this.appBarTitle,
    this.centerTitle,
    this.child,
  });

  String createdViewId = DateTime.now().microsecondsSinceEpoch.toString();

  String? barcodeNumber;

  late StreamSubscription stream;

  @override
  Widget build(BuildContext context) {
    final html.IFrameElement iframe = html.IFrameElement()
      ..src = PackageConstant.barcodeFileWebPath
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..onLoad.listen((event) async {
        /// Barcode listener on success barcode scanned
        html.window.onMessage.listen((event) {
          /// If barcode is null then assign scanned barcode
          /// and close the screen otherwise keep scanning
          if (barcodeNumber == null) {
            barcodeNumber = event.data;
            onScanned(barcodeNumber!);
          }
        });
      });
    stream = iframe.onLoad.listen((event) async {
      /// Barcode listener on success barcode scanned
      html.window.onMessage.listen((event) {
        /// If barcode is null then assign scanned barcode
        /// and close the screen otherwise keep scanning
        if (barcodeNumber == null) {
          barcodeNumber = event.data;
          onScanned(barcodeNumber!);
        }
      });
    });

    ui.platformViewRegistry
        .registerViewFactory(createdViewId, (int viewId) => iframe);
    EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    // Check if the keyboard is open (bottom inset greater than zero)
    bool isKeyboardOpen = viewInsets.bottom > 0;
    if (isKeyboardOpen) stream.cancel();

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? kScanPageTitle),
        centerTitle: centerTitle,
      ),
      body: Column(
        children: [
          Expanded(
            child: HtmlElementView(
              viewType: createdViewId,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
