library story_designer;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:story_designer/widgets/go_back.dart';

class EditableItem {
  Offset position = Offset(0.4, 0.4);
  double scale = 1.0;
  double rotation = 0.0;
  ItemType type;
  String value;
  Color color;
  int textStyle;
  double fontSize;
  int fontFamily;
}

enum ItemType { Image, Text }

class StoryDesigner extends StatefulWidget {
  final String filePath;
  StoryDesigner({Key key, this.filePath}) : super(key: key);

  @override
  _StoryDesignerState createState() => _StoryDesignerState();
}

class _StoryDesignerState extends State<StoryDesigner> {
  static GlobalKey previewContainer = new GlobalKey();

  // ActiceItem
  EditableItem _activeItem;
  // item initial position
  Offset _initPos;
  // item current position
  Offset _currentPos;
  // item current scale
  double _currentScale;
  // item current rotation
  double _currentRotation;
  // is item in action
  bool _inAction = false;
  // List of all editableitems
  List<EditableItem> stackData = [];
  // is textfield shown
  bool isTextInput = false;
  // current textfield text
  String currentText = "";
  // current textfield color
  Color currentColor = Color(0xffffffff);
  // current textfield colorpicker color
  Color pickerColor = Color(0xffffffff);
  // current textfield style
  int currentTextStyle = 0;
  // current textfield fontsize
  double currentFontSize = 26.0;
  // current textfield fontfamily list
  List<String> fontFamilyList = [
    "Lato",
    "Montserrat",
    "Lobster",
    "Spectral SC",
    "Dancing Script",
    "Oswald",
    "Turret Road",
    "Noto Serif",
    "Anton"
  ];
  // current textfield fontfamily
  int currentFontFamily = 0;
  // is activeitem moved to delete position
  bool isDeletePosition = false;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: GestureDetector(
            onScaleStart: (details) {
              if (_activeItem == null) return;

              _initPos = details.focalPoint;
              _currentPos = _activeItem.position;
              _currentScale = _activeItem.scale;
              _currentRotation = _activeItem.rotation;
            },
            onScaleUpdate: (details) {
              if (_activeItem == null) return;
              final delta = details.focalPoint - _initPos;
              final left = (delta.dx / screen.width) + _currentPos.dx;
              final top = (delta.dy / screen.height) + _currentPos.dy;
              setState(() {
                _activeItem.position = Offset(left, top);
                _activeItem.rotation = details.rotation + _currentRotation;
                _activeItem.scale = details.scale * _currentScale;
              });
            },
            onTap: () {
              setState(() {
                isTextInput = !isTextInput;
                _activeItem = null;
              });
              if (currentText.isNotEmpty) {
                setState(() {
                  stackData.add(
                    EditableItem()
                      ..type = ItemType.Text
                      ..value = currentText
                      ..color = currentColor
                      ..textStyle = currentTextStyle
                      ..fontSize = currentFontSize
                      ..fontFamily = currentFontFamily,
                  );
                  currentText = "";
                });
              }
            },
            child: Stack(
              children: [
                RepaintBoundary(
                  key: previewContainer,
                  child: Stack(
                    children: [
                      Container(color: Colors.black54),
                      Visibility(
                        visible: stackData[0].type == ItemType.Image,
                        child: Center(
                          child: Image.file(new File(stackData[0].value)),
                        ),
                      ),
                      ...stackData.map(_buildItemWidget).toList(),
                      Visibility(
                        visible: isTextInput,
                        child: Container(
                          height: screen.height,
                          width: screen.width,
                          color: Colors.black.withOpacity(0.4),
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: screen.width / 1.5,
                                  child: Container(
                                    padding: currentTextStyle != 0
                                        ? EdgeInsets.only(
                                            left: 7,
                                            right: 7,
                                            top: 5,
                                            bottom: 5,
                                          )
                                        : EdgeInsets.all(0),
                                    decoration: currentTextStyle != 0
                                        ? BoxDecoration(
                                            color: currentTextStyle == 1
                                                ? Colors.black.withOpacity(1.0)
                                                : Colors.white.withOpacity(1.0),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(4),
                                            ),
                                          )
                                        : BoxDecoration(),
                                    child: TextField(
                                      autofocus: true,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        fontFamilyList[currentFontFamily],
                                      ).copyWith(
                                        color: currentColor,
                                        fontSize: currentFontSize,
                                      ),
                                      cursorColor: currentColor,
                                      minLines: 1,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        border: new UnderlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: new UnderlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                      onChanged: (input) {
                                        setState(() => currentText = input);
                                      },
                                      onSubmitted: (input) {
                                        if (input.isNotEmpty) {
                                          setState(() {
                                            stackData.add(
                                              EditableItem()
                                                ..type = ItemType.Text
                                                ..value = currentText
                                                ..color = currentColor
                                                ..textStyle = currentTextStyle
                                                ..fontSize = currentFontSize
                                                ..fontFamily =
                                                    currentFontFamily,
                                            );
                                            currentText = "";
                                          });
                                        } else {
                                          setState(() => currentText = "");
                                        }
                                        setState(() {
                                          isTextInput = !isTextInput;
                                          _activeItem = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                child: Container(
                                  width: screen.width,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.color_lens_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          // raise the [showDialog] widget
                                          showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Pick a color!'),
                                                content: SingleChildScrollView(
                                                  child: ColorPicker(
                                                    pickerColor: pickerColor,
                                                    onColorChanged: (color) {
                                                      setState(() {
                                                        pickerColor = color;
                                                      });
                                                    },
                                                    labelTypes: [],
                                                    pickerAreaHeightPercent:
                                                        0.8,
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Got it'),
                                                    onPressed: () {
                                                      setState(() {
                                                        currentColor =
                                                            pickerColor;
                                                      });
                                                      Navigator.of(ctx).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Container(
                                          padding: currentTextStyle != 0
                                              ? EdgeInsets.only(
                                                  left: 7,
                                                  right: 7,
                                                  top: 5,
                                                  bottom: 5,
                                                )
                                              : EdgeInsets.all(0),
                                          decoration: currentTextStyle != 0
                                              ? BoxDecoration(
                                                  color: currentTextStyle == 1
                                                      ? Colors.black
                                                          .withOpacity(1.0)
                                                      : Colors.white
                                                          .withOpacity(1.0),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(4),
                                                  ),
                                                )
                                              : BoxDecoration(),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: currentTextStyle != 2
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (currentTextStyle < 2) {
                                            setState(() => currentTextStyle++);
                                          } else {
                                            setState(
                                                () => currentTextStyle = 0);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: screen.height / 2 - 45,
                                left: -120,
                                child: Transform(
                                  alignment: FractionalOffset.center,
                                  // Rotate sliders by 90 degrees
                                  transform: new Matrix4.identity()
                                    ..rotateZ(270 * 3.1415927 / 180),
                                  child: SizedBox(
                                    width: 300,
                                    child: Slider(
                                        value: currentFontSize,
                                        min: 14,
                                        max: 74,
                                        activeColor: Colors.white,
                                        inactiveColor:
                                            Colors.white.withOpacity(0.4),
                                        onChanged: (input) {
                                          setState(() {
                                            currentFontSize = input;
                                          });
                                        }),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 50,
                                left: screen.width / 6,
                                child: Center(
                                  child: Container(
                                    width: screen.width / 1.5,
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: ListView.builder(
                                      itemCount: fontFamilyList.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              currentFontFamily = index;
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: index == currentFontFamily
                                                  ? Colors.white
                                                  : Colors.black,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                            child: Text(
                                              'Aa',
                                              style: GoogleFonts.getFont(
                                                fontFamilyList[index],
                                              ).copyWith(
                                                color:
                                                    index == currentFontFamily
                                                        ? Colors.black
                                                        : Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GoBack(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          // Share Btn
                          Visibility(
                            visible: !isTextInput,
                            child: Visibility(
                              visible: _activeItem == null,
                              child: InkWell(
                                onTap: () async {
                                  //done: save image and return captured image to previous screen
                                  RenderRepaintBoundary boundary =
                                      previewContainer.currentContext
                                              .findRenderObject()
                                          as RenderRepaintBoundary;
                                  ui.Image image = await boundary.toImage();
                                  final directory =
                                      (await getApplicationDocumentsDirectory())
                                          .path;
                                  ByteData byteData = await image.toByteData(
                                      format: ui.ImageByteFormat.png);
                                  Uint8List pngBytes =
                                      byteData.buffer.asUint8List();
                                  print(pngBytes);

                                  File imgFile = new File(
                                    '$directory/' +
                                        DateTime.now().toString() +
                                        '.png',
                                  );
                                  imgFile.writeAsBytes(pngBytes).then((value) {
                                    // done: return imgFile
                                    Navigator.of(context).pop(imgFile);
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: 40.0,
                                      width: 130,
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF0BCC83),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'Share',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Add Text
                          Visibility(
                            visible: !isTextInput,
                            child: InkWell(
                              child: Container(
                                margin: EdgeInsets.only(top: 32),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Add Text',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    Icon(
                                      Icons.textsms,
                                      color: Colors.white,
                                      size: !isDeletePosition ? 30 : 50,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  isTextInput = !isTextInput;
                                  _activeItem = null;
                                });
                                if (currentText.isNotEmpty) {
                                  setState(() {
                                    stackData.add(
                                      EditableItem()
                                        ..type = ItemType.Text
                                        ..value = currentText
                                        ..color = currentColor
                                        ..textStyle = currentTextStyle
                                        ..fontSize = currentFontSize
                                        ..fontFamily = currentFontFamily,
                                    );
                                    currentText = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete Button
                Visibility(
                  visible: !isTextInput,
                  child: Visibility(
                    visible: _activeItem != null,
                    child: Positioned(
                      bottom: 50,
                      child: Container(
                        width: screen.width,
                        child: Center(
                          child: Container(
                            height: !isDeletePosition ? 60.0 : 100,
                            width: !isDeletePosition ? 60.0 : 100,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.all(
                                Radius.circular(!isDeletePosition ? 30 : 50),
                              ),
                            ),
                            child: Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                              size: !isDeletePosition ? 30 : 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    stackData.add(
      EditableItem()
        ..type = ItemType.Image
        ..value = widget.filePath,
    );
    super.initState();
  }

  Widget _buildItemWidget(EditableItem e) {
    final screen = MediaQuery.of(context).size;
    // double centerHeightPosition = screen.height/2;
    // double centerWidthPosition = screen.width/2;

    var widget;
    switch (e.type) {
      case ItemType.Text:
        if (e.textStyle == 0) {
          widget = Text(
            e.value.toString(),
            style: GoogleFonts.getFont(fontFamilyList[e.fontFamily])
                .copyWith(color: e.color, fontSize: e.fontSize),
          );
        } else if (e.textStyle == 1) {
          widget = Container(
            padding: EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(1.0),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Text(
              e.value.toString(),
              style: GoogleFonts.getFont(fontFamilyList[e.fontFamily])
                  .copyWith(color: e.color, fontSize: e.fontSize),
            ),
          );
        } else if (e.textStyle == 2) {
          widget = Container(
            padding: EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(1.0),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Text(
              e.value.toString(),
              style: GoogleFonts.getFont(fontFamilyList[e.fontFamily])
                  .copyWith(color: e.color, fontSize: e.fontSize),
            ),
          );
        } else {
          widget = Text(
            e.value.toString(),
            style: GoogleFonts.getFont(fontFamilyList[e.fontFamily])
                .copyWith(color: e.color, fontSize: e.fontSize),
          );
        }
        break;
      case ItemType.Image:
        widget = Center();
        break;
      default:
        widget = Container();
    }

    // e.position = Offset(centerHeightPosition, centerWidthPosition);
    return Positioned(
      top: e.position.dy * screen.height,
      left: e.position.dx * screen.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (e.type != ItemType.Image) {
                if (_inAction) return;
                _inAction = true;
                _activeItem = e;
                _initPos = details.position;
                _currentPos = e.position;
                _currentScale = e.scale;
                _currentRotation = e.rotation;
              }
            },
            onPointerUp: (details) {
              _inAction = false;
              if (e.position.dy >= 0.8 &&
                  e.position.dx >= 0.0 &&
                  e.position.dx <= 1.0) {
                setState(() {
                  stackData.removeAt(stackData.indexOf(e));
                  _activeItem = null;
                });
              }
              setState(() {
                _activeItem = null;
              });
            },
            onPointerCancel: (details) {},
            onPointerMove: (details) {
              if (e.position.dy >= 0.8 &&
                  e.position.dx >= 0.0 &&
                  e.position.dx <= 1.0) {
                setState(() {
                  isDeletePosition = true;
                });
              } else {
                setState(() {
                  isDeletePosition = false;
                });
              }
            },
            child: widget,
          ),
        ),
      ),
    );
  }
}
