import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:tracker_test/src/features/devices/data/models/data_model.dart';
import 'package:tracker_test/src/features/devices/presentation/blue_listing_screen.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';

import 'package:tracker_test/src/features/math/rr_peaks_detection.dart';

class EsportSessionForm extends StatefulWidget {
  final List<ListDataModel> dataSession;
  const EsportSessionForm({Key? key, required this.dataSession})
      : super(key: key);

  @override
  State<EsportSessionForm> createState() => _EsportSessionFormState();
}

class _EsportSessionFormState extends State<EsportSessionForm> {
  final _textController = TextEditingController();
  bool _customText = true;
  var _inputFileText = '';
  RRPeaksDetection rrFunctions = RRPeaksDetection();
  late List<dynamic> lowPassSolution = [],
      highPassSolution = [],
      derivatePassSolution = [],
      powPassSolution = [],
      windowSolution = [],
      normalizeSolution = [],
      peaksSolution = [],
      rrPeaksSolution = [],
      timeArr = [];
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);

  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget customAppBar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.longArrowAltLeft)),
          Expanded(
              child: Center(
            child: Text("Resultados".toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 25)),
          )),
          IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.cloudUploadAlt)),
          IconButton(
              onPressed: () {
                setFileForm(context);
              },
              icon: const FaIcon(FontAwesomeIcons.fileExcel)),
        ],
      ),
    );
  }

  Widget setMetricView(BuildContext context, String titleMetric,
      String unitMetric, int valueMetric) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(titleMetric,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$valueMetric",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 40,
                          color: Colors.cyan[600])),
                  const SizedBox(width: 5),
                  Text(unitMetric,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.cyan[800])),
                ],
              ),
            ],
          ),
        ));
  }

  void setFileForm(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              height: 400.0,
              decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0))),
              child: StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: const BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text("Importar resultados en CVS Excel",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                          SwitchListTile.adaptive(
                              title: const Text(
                                  "Definir nombre automaticamente: "),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: _customText,
                              onChanged: (bool value) {
                                setState(() {
                                  _customText = value;
                                });
                              }),
                          _customText
                              ? Text("nombre del archivo: $_inputFileText")
                              : TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Nombre del archivo',
                                    hintText: 'Ingresa nombre del archivo',
                                    errorText: _errorText,
                                  ),
                                  keyboardType: TextInputType.text,
                                  controller: _textController,
                                  onChanged: (value) =>
                                      setState(() => {_inputFileText = value}),
                                ),
                          ElevatedButton(
                              onPressed: () {
                                if (!_customText) {
                                  getCsv(_inputFileText, context);
                                } else {
                                  String autoFileName =
                                      "${randomAlpha(8)}_${randomNumeric(8)}";
                                  setState(
                                      () => {_inputFileText = autoFileName});
                                  getCsv(autoFileName, context);
                                }
                              },
                              child: const Text("Guardar archivo")),
                        ],
                      ));
                },
              ),
            ),
          );
        });
  }

  String? get _errorText {
    final validCharacters = RegExp(r'^[a-zA-Z0-9_\-=@,\.;]+$');
    final text = _textController.value.text;

    if (text.isEmpty) {
      return "El campo no puede estar vacio";
    } else if (text.length < 4) {
      return "El nombre es demasiado corto";
    } else if (!validCharacters.hasMatch(text)) {
      return "No puede tener caracteres especiales";
    }
    return null;
  }

  getCsv(String autoFileName, BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String dir =
        (await getExternalStorageDirectory())!.absolute.path + "/sessions";

    final savedDir = Directory(dir);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    for (var i = 0; i < widget.dataSession.length; i++) {
      derivatePassSolution.insert(i,0);
      powPassSolution.insert(i,0);
      windowSolution.insert(i,0);
      normalizeSolution.insert(i,0);
      peaksSolution.insert(i,0);
      rrPeaksSolution.insert(i,0);
    }


    metricsCalculs();
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Session'];

    List<String> dataList = [
      'Valor',
      'LowPass',
      'HighPass',
      'Derivative',
      'Pow',
      'Window',
      'Peaks'
    ];

    sheetObject.insertRowIterables(dataList, 0);

    List<List<num?>> colCrudeData = [];
    List<num?> colDerivativePassData = [],
        colPowPassData = [],
        colWindowPassData = [],
        colNormalizeData = [],
        colPeakPassData = [],
        colRRPeakPassData = [];
    int colIndex = 0;

    

    for (var i = 0; i < widget.dataSession.length; i++) {
      colCrudeData
          .insert(i, [widget.dataSession[i].value, derivatePassSolution[i], powPassSolution[i],windowSolution[i], normalizeSolution[i], peaksSolution[i], rrPeaksSolution[i]]);
    }

    for (var element in colCrudeData) {
      sheetObject.appendRow(element);
    }

    var fileBytes = excel.save();
    File(join("$dir/$autoFileName.xlsx"))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
  }

  void metricsCalculs() {
    rrFunctions.init(widget.dataSession.length);
    derivatePassSolution = rrFunctions.setDerivativeFilter(widget.dataSession);
    powPassSolution = rrFunctions.setPowPassFilter(derivatePassSolution);
    windowSolution = rrFunctions.setWindowFilter(powPassSolution);
    normalizeSolution = rrFunctions.setNormalizeSignal(windowSolution);
    peaksSolution = rrFunctions.setFindPeaks(normalizeSolution);
    var acuTime = 0.0;
    for (var i = 0; i < peaksSolution.length; i++) {
      acuTime += 13.333;
      timeArr.insert(i, acuTime);
    }
    rrPeaksSolution = rrFunctions.setRRDetection(peaksSolution, timeArr);

    print("Progress 100%");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 80, 5, 2),
            child: SingleChildScrollView(
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 1,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "Promedio RR", "ms", 155),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "Promedio F.C", "LPM", 55),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "F.C Mínima", "LPM", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "F.C Máxima", "LPM", 175),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "SDNN", "ms", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "RMSSD", "ms", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "NN50", "", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "pNN50", "%", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "SD1", "ms", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "SD2", "ms", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "Pico B.F.", "Hz", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "Pico A.F", "Hz", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "Potencia B.F", "ms^2", 75),
                  ),
                  StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 1,
                      child:
                          setMetricView(context, "Potencia A.F", "ms^2", 75)),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(
                        context, "Potencia Logarítmica B.F", "", 75),
                  ),
                  StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 1,
                      child: setMetricView(
                          context, "Potencia Logarítmica A.F", "", 75)),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "% B.F", "%", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "% A.F", "%", 75),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 1,
                    child: setMetricView(context, "Tasa de Potenica", "", 75),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 70,
              child:
                  Container(color: Colors.black, child: customAppBar(context)))
        ],
      )),
    );
  }
}
