import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          sliderTheme: const SliderThemeData(
            // activeTrackColor: Colors.red,
            // inactiveTrackColor: Colors.green,
            // thumbColor: Colors.blue,
            // overlayColor: Colors.red,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 5),
          )),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const perspectiveVal = 0.001;

  Matrix4 baseMatrix = Matrix4.identity()..setEntry(3, 2, perspectiveVal);
  late Matrix4 currentMatrix;

  double angleX = 0, angleY = 0, angleZ = 0, distance = 16;
  Alignment alignment = Alignment.center;

  @override
  initState() {
    super.initState();
    currentMatrix = baseMatrix.clone();
  }

  _reset() {
    baseMatrix = Matrix4.identity()..setEntry(3, 2, perspectiveVal);
    distance = 16;
    _setTransform(0, 0, 0, 1);
  }

  _setBaseMatrixEntry(int storage, double value) {
    setState(() {
      baseMatrix.storage[storage] = value;
    });
  }

  _setTransform(double? x, y, z, [double? scaleMultiplier]) {
    if (x != null) angleX = x;
    if (y != null) angleY = y;
    if (z != null) angleZ = z;
    // if (scaleMultiplier != null) scale = scaleMultiplier;
    currentMatrix = baseMatrix.clone()
      ..rotateX(angleX)
      ..rotateY(angleY)
      ..rotateZ(angleZ);
    // ..setEntry(3, 3, scale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Flutter Matrix Transform by Chris Marx'),
        actions: [
          TextButton.icon(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
            icon: const Icon(Icons.code),
            label: const Text('Github'),
            onPressed: () {
              launchUrl(Uri.parse('https://github.com/ChrisMarxDev'));
            },
          ),
          TextButton.icon(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
            icon: const Icon(Icons.message),
            label: const Text('Twitter'),
            onPressed: () {
              launchUrl(Uri.parse('https://twitter.com/ChrisMarxDev'));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final bool isSmallDisplay = constraints.maxWidth < 600;
        return Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 5,
              child: ListView(
                padding: const EdgeInsets.only(
                    top: 24, bottom: 96, left: 32, right: 32),
                children: [
                  if (isSmallDisplay)
                    Padding(
                      padding: const EdgeInsets.only(top: 64, bottom: 128),
                      child: TransformStack(
                          currentMatrix: currentMatrix,
                          alignment: alignment,
                          baseMatrix: baseMatrix,
                          distance: distance),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            _reset();
                          },
                          child: const Text('Reset')),
                    ],
                  ),
                  ConfigurableMatrixDescription(
                    matrix: baseMatrix,
                    onChanged: _setBaseMatrixEntry,
                  ),
                  Wrap(
                    children: [
                      const Text('Alignment of the transform: '),
                      ElevatedButton(
                          onPressed: alignment == Alignment.center
                              ? null
                              : () =>
                                  setState(() => alignment = Alignment.center),
                          child: const Text('Center')),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: alignment == Alignment.topLeft
                              ? null
                              : () =>
                                  setState(() => alignment = Alignment.topLeft),
                          child: const Text('TopLeft')),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: alignment == Alignment.centerRight
                              ? null
                              : () => setState(
                                  () => alignment = Alignment.centerRight),
                          child: const Text('CenterRight')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RotationSlider(
                      label: 'X Rotation: ${angleX.toStringAsFixed(2)}',
                      onChanged: (val) => _setTransform(val, null, null),
                      value: angleX),
                  RotationSlider(
                      label: 'Y Rotation: ${angleY.toStringAsFixed(2)}',
                      onChanged: (val) => _setTransform(null, val, null),
                      value: angleY),
                  RotationSlider(
                      label: 'Z Rotation: ${angleZ.toStringAsFixed(2)}',
                      onChanged: (val) => _setTransform(null, null, val),
                      value: angleZ),
                  RotationSlider(
                      label:
                          'Stack density X,Y,Z: ${distance.toStringAsFixed(2)}',
                      min: 0,
                      max: 24,
                      onChanged: (val) => setState(() {
                            distance = val;
                          }),
                      value: distance),
                  // MatrixDescription(label: 'Base Matrix', matrix: baseMatrix),
                  const SizedBox(
                    height: 24,
                  ),
                  MatrixDescription(
                      label: 'Result Matrix',
                      matrix: baseMatrix.clone()
                        ..translate(distance, distance, distance)
                        ..multiply(currentMatrix)),
                ],
              ),
            ),
            if (!isSmallDisplay)
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: TransformStack(
                    currentMatrix: currentMatrix,
                    alignment: alignment,
                    baseMatrix: baseMatrix,
                    distance: distance),
              ),
          ],
        );
      }),
    );
  }
}

class TransformStack extends StatelessWidget {
  const TransformStack({
    Key? key,
    required this.currentMatrix,
    required this.alignment,
    required this.baseMatrix,
    required this.distance,
  }) : super(key: key);

  final Matrix4 currentMatrix;
  final Alignment alignment;
  final Matrix4 baseMatrix;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform(
              transform: currentMatrix,
              alignment: alignment,
              child: Stack(
                children: [
                  Transform(
                    transform: baseMatrix.clone()
                      ..translate(2 * distance, 2 * distance, 2 * distance),
                    // ..setEntry(3, 2, 0.001)
                    // ..rotateX(0.5)
                    // ..rotateY(0.5)
                    // ..rotateZ(0.5),
                    alignment: Alignment.center,
                    child: const ExampleCard(),
                  ),
                  Transform(
                    transform: baseMatrix.clone()
                      ..translate(distance, distance, distance),
                    // ..setEntry(3, 2, 0.001)
                    // ..rotateX(0.5)
                    // ..rotateY(0.5)
                    // ..rotateZ(0.5),
                    alignment: Alignment.center,
                    child: const ExampleCard(),
                  ),
                  Transform(
                    transform: baseMatrix.clone(),
                    // ..setEntry(3, 2, 0.001)
                    // ..rotateX(0.5)
                    // ..rotateY(0.5)
                    // ..rotateZ(0.5),
                    alignment: Alignment.center,
                    child: const ExampleCard(
                      selected: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ExampleCard extends StatelessWidget {
  const ExampleCard({
    Key? key,
    this.selected = false,
  }) : super(key: key);

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            border: Border.all(
                color: selected ? Colors.redAccent : Colors.black,
                width: selected ? 4 : 2),
            borderRadius: const BorderRadius.all(Radius.circular(16))),
        width: 100,
        height: 100,
      ),
    );
  }
}

class RotationSlider extends StatelessWidget {
  const RotationSlider({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.value,
    this.min,
    this.max,
  }) : super(key: key);

  final String label;
  final ValueChanged<double> onChanged;
  final double value;
  final double? min;
  final double? max;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Slider(
            value: value,
            min: min ?? (-2 * pi),
            max: max ?? (2 * pi),
            onChanged: onChanged),
      ],
    );
  }
}

class MatrixDescription extends StatelessWidget {
  final Matrix4 matrix;
  final String? label;

  const MatrixDescription({
    required this.matrix,
    this.label,
    Key? key,
  }) : super(key: key);

  static const fixed = 3;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Text(
        label ?? 'Matrix',
        style: const TextStyle(fontSize: 32),
      ),
      Text(
        '${matrix.storage[0].toStringAsFixed(fixed)}, ${matrix.storage[1].toStringAsFixed(fixed)}, ${matrix.storage[2].toStringAsFixed(fixed)}, ${matrix.storage[3].toStringAsFixed(fixed)}',
        style: const TextStyle(fontSize: 24),
      ),
      Text(
        '${matrix.storage[4].toStringAsFixed(fixed)}, ${matrix.storage[5].toStringAsFixed(fixed)}, ${matrix.storage[6].toStringAsFixed(fixed)}, ${matrix.storage[7].toStringAsFixed(fixed)}',
        style: const TextStyle(fontSize: 24),
      ),
      Text(
        '${matrix.storage[8].toStringAsFixed(fixed)}, ${matrix.storage[9].toStringAsFixed(fixed)}, ${matrix.storage[10].toStringAsFixed(fixed)}, ${matrix.storage[11].toStringAsFixed(fixed)}',
        style: const TextStyle(fontSize: 24),
      ),
      Text(
        '${matrix.storage[12].toStringAsFixed(fixed)}, ${matrix.storage[13].toStringAsFixed(fixed)}, ${matrix.storage[14].toStringAsFixed(fixed)}, ${matrix.storage[15].toStringAsFixed(fixed)}',
        style: const TextStyle(fontSize: 24),
      ),
    ]);
  }
}

class ConfigurableMatrixDescription extends StatelessWidget {
  final Matrix4 matrix;
  final void Function(int, double) onChanged;

  const ConfigurableMatrixDescription({
    required this.matrix,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  static const fixed = 3;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      const Text(
        'Base Matrix',
        style: TextStyle(fontSize: 32),
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[0],
            onChanged: (v) => onChanged(0, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[1],
            onChanged: (v) => onChanged(1, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[2],
            onChanged: (v) => onChanged(2, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[3],
            max: 0.008,
            min: 0,
            onChanged: (v) => onChanged(3, v),
          ),
        ],
      ),
      Row(
        children: [
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[4],
            onChanged: (v) => onChanged(4, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[5],
            onChanged: (v) => onChanged(5, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[6],
            onChanged: (v) => onChanged(6, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[7],
            max: 0.008,
            min: 0,
            onChanged: (v) => onChanged(7, v),
          ),
        ],
      ),
      Row(
        children: [
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[8],
            onChanged: (v) => onChanged(8, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[9],
            onChanged: (v) => onChanged(9, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[10],
            onChanged: (v) => onChanged(10, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[11],
            max: 0.008,
            min: 0,
            onChanged: (v) => onChanged(11, v),
          ),
        ],
      ),
      Row(
        children: [
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[12],
            min: -20,
            max: 20,
            onChanged: (v) => onChanged(12, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[13],
            min: -20,
            max: 20,
            onChanged: (v) => onChanged(13, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[14],
            min: -20,
            max: 20,
            onChanged: (v) => onChanged(14, v),
          ),
          ConfigurableMatrixDescriptionTile(
            value: matrix.storage[15],
            min: 0.3,
            onChanged: (v) => onChanged(15, v),
          ),
        ],
      )
    ]);
  }
}

class ConfigurableMatrixDescriptionTile extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final double min;
  final double max;

  const ConfigurableMatrixDescriptionTile({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = -4,
    this.max = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toStringAsFixed(5),
            maxLines: 1,
          ),
          Slider(min: min, max: max, value: value, onChanged: onChanged)
        ],
      ),
    );
  }
}
