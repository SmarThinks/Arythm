import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tracker_test/src/core/injection_container.dart';
import 'package:tracker_test/src/features/devices/data/models/data_model.dart';
import 'package:tracker_test/src/features/devices/data/models/device_modal.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_list_cubic.dart';
import 'package:tracker_test/src/features/devices/presentation/blue_listing_screen.dart';
import 'dart:convert' show utf8;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:tracker_test/src/features/devices/data/local/helpers/blue_device_extension.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:tracker_test/src/features/devices/presentation/session_export_form.dart';

import 'bloc/device_selected_cubic.dart';

class BlueStreamScreen extends StatefulWidget {
  final DeviceEntity device;
  const BlueStreamScreen({Key? key, required this.device}) : super(key: key);

  @override
  _BlueStreamScreenState createState() => _BlueStreamScreenState();
}

class _BlueStreamScreenState extends State<BlueStreamScreen>
    with WidgetsBindingObserver {
  final CountdownController _controller = CountdownController(autoStart: false);
  final int currentPage = 0;
  final pageController = PageController(
    initialPage: 0,
  );
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  List<ListDataModel>? chartData;
  ChartSeriesController? _chartSeriesController;

  Stream<List<int>>? readStream;
  BluetoothCharacteristic? writeStream;
  List<double>? traceDust = [];
  int checksum = 0;
  var xAxisCounter = 0;
  int _conuntDownSeconds = 0;
  List<ListDataModel> dataModelSave = [];

  bool _btnOneMin = false;
  bool _btnSixMin = false;
  bool _btnEightMin = false;
  bool _btnTenMin = false;
  @override
  void initState() {
    //set initial orentation to langscape
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance!.addObserver(this);
    chartData = getFirst();
    //dataModelSave = getFirst();
    setDiscoverBlueDeviceServices(widget.device as DeviceModel);
    WidgetsBinding.instance!.addPostFrameCallback((_) => _showStartDialog());

    //ToDo: Prender el Bluetooth cuando esté apagado!
  }

  List<ListDataModel> getFirst() {
    List<ListDataModel> simpleData = [];
    for (var i = 0; i < 1000; i++) {
      simpleData.add(ListDataModel(i, i += 1));
    }
    return simpleData;
  }

  setDiscoverBlueDeviceServices(DeviceModel device) async {
    const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
    const String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
    final BluetoothDevice blue = device.toBlueoothDevice();
    if (s1<DeviceSelectedCubit>().state.connected) {
      s1<DeviceSelectedCubit>().disconnect(widget.device);
      await blue.disconnect();
    }
    s1<DeviceSelectedCubit>().connect(widget.device);
    await blue.connect();
    List<BluetoothService> services = await blue.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUuid) {
            await blue.mtu.first;
            await blue.requestMtu(512);
            characteristic.setNotifyValue(!characteristic.isNotifying);
            readStream = characteristic.value;
            writeStream = characteristic;
          }
        }
      }
    }
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("state: $state");
/*     if (state == AppLifecycleState.inactive) {
      if (s1<DeviceSelectedCubit>().state.connected) {
        s1<DeviceSelectedCubit>().disconnect(widget.device);
      }
    } */
  }

  Future<void> _showStartDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        var height = MediaQuery.of(context).size.height;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          insetPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: Colors.transparent,
            child: Container(
              width: 300,
              height: height - 50,
              padding: const EdgeInsets.only(
                  top: 30.0, left: 15.0, right: 15.0, bottom: 10.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade900),
              ),
              child: PageView(controller: pageController, children: [
                !s1<DeviceSelectedCubit>().state.connected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Center(
                            child: Text("Intentando conectar al Arythm Device",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 23)),
                          ),
                          const CircularProgressIndicator(
                            backgroundColor: Colors.blueGrey,
                            color: Colors.blue,
                          ),
                          OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  setDiscoverBlueDeviceServices(
                                      widget.device as DeviceModel);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                  textStyle: TextStyle(
                                      color: Colors.blue[900], fontSize: 15),
                                  shadowColor: Colors.cyan[600]),
                              child: const Text("Reintentar")),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Center(
                            child: Text("Conectado a Arythm Device",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 23)),
                          ),
                          const FaIcon(FontAwesomeIcons.checkCircle,
                              size: 32, color: Colors.white),
                          OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  pageController.jumpToPage(1);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                  textStyle: TextStyle(
                                      color: Colors.blue[900], fontSize: 15),
                                  shadowColor: Colors.cyan[600]),
                              child: const Text("Continuar")),
                        ],
                      ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Iniciar una nueva sesión",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 23)),
                    const Text(
                        "Por favor, seleccione el tiempo en minutos que durará la prueba."),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                _conuntDownSeconds = 60;
                                setState(() {
                                  _btnOneMin = !_btnOneMin;
                                  _btnEightMin =
                                      _btnSixMin = _btnTenMin = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: _btnOneMin
                                    ? Colors.blue[300]
                                    : Colors.blue[900],
                                onPrimary: Colors.blue[900],
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: const Text(
                                  "1",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                _conuntDownSeconds = 360;
                                setState(() {
                                  _btnSixMin = !_btnSixMin;
                                  _btnEightMin =
                                      _btnOneMin = _btnTenMin = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: _btnSixMin
                                    ? Colors.blue[300]
                                    : Colors.blue[900],
                                onPrimary: Colors.blue[900],
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: const Text(
                                  "6",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                _conuntDownSeconds = 480;
                                setState(() {
                                  _btnEightMin = !_btnEightMin;
                                  _btnSixMin = _btnOneMin = _btnTenMin = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: _btnEightMin
                                    ? Colors.blue[300]
                                    : Colors.blue[900],
                                onPrimary: Colors.blue[900],
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: const Text(
                                  "8",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                _conuntDownSeconds = 600;
                                setState(() {
                                  _btnTenMin = !_btnTenMin;
                                  _btnSixMin =
                                      _btnOneMin = _btnEightMin = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: _btnTenMin
                                    ? Colors.blue[300]
                                    : Colors.blue[900],
                                onPrimary: Colors.blue[900],
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: const Text(
                                  "10",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ],
                    ),
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            pageController.jumpToPage(2);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                            textStyle: TextStyle(
                                color: Colors.blue[900], fontSize: 15),
                            shadowColor: Colors.cyan[600]),
                        child: const Text("Continuar"))
                  ],
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("¡Aviso Importante!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 23)),
                      const Text(
                          "Por favor, intente mantenerse lo más quieto posible durante el exámen para mejores resultados."),
                      OutlinedButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                              _controller.start();
                              writeStream?.write(utf8.encode('T1000'));
                            });
                          },
                          style: OutlinedButton.styleFrom(
                              textStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 15),
                              shadowColor: Colors.cyan[600]),
                          child: const Text("Empezar"))
                    ]),
              ]),
            ));
      },
    );
  }

  Widget _clockCountDown(BuildContext context) {
    return Countdown(
        controller: _controller,
        seconds: _conuntDownSeconds,
        build: (_, double time) => Text(
              formatDuration(time),
              style: const TextStyle(
                fontSize: 60,
              ),
            ),
        interval: const Duration(milliseconds: 100),
        onFinished: () {
          writeStream?.write(utf8.encode('T0000'));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hemos terminado con satisfacction!'),
            ),
          );
          print(dataModelSave.length);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EsportSessionForm(dataSession: dataModelSave)),
          );
        });
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
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const BlueListingScreen()))
                    .then((value) => {refresh()});
              },
              icon: const FaIcon(FontAwesomeIcons.longArrowAltLeft)),
          const Expanded(
              child: Center(
            child: Text("Arythm Device",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 22)),
          )),
          IconButton(
              onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.wrench)),
        ],
      ),
    );
  }

  getSimpleData(List<String> splitAux) {
    for (var item in splitAux) {
      print("element: ${item}, counter: $xAxisCounter");
      chartData!.removeAt(0);
      chartData!.add(ListDataModel(xAxisCounter++, num.parse(item)));
      dataModelSave.add(ListDataModel(xAxisCounter, num.parse(item)));
    }
    _chartSeriesController?.updateDataSource(
      addedDataIndexes: <int>[chartData!.length - 1],
      removedDataIndexes: <int>[0],
    );
  }

  setChangeButtonColor(String btnNumber) {
    setState(() {
      switch (btnNumber) {
        case '_btnOneMin':
          _btnOneMin = !_btnOneMin;
          break;
        case '_btnSixMin':
          _btnSixMin = !_btnSixMin;
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        customAppBar(context),
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(child: _clockCountDown(context)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _controller.pause();
                              writeStream?.write(utf8.encode('T0000'));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 15),
                              shadowColor: Colors.cyan[600]),
                          child: const Text("Detener")),
                    ),
                  ),
                ],
              ),
              StreamBuilder<List<int>>(
                stream: readStream,
                builder:
                    (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.active) {
                    var currentValue = _dataParser(snapshot.data!);
                    print("crudedata_1: $currentValue");
                    var splitAux = currentValue.split(",");
                    if (splitAux.length == 15) {
                      checksum += 1;
                      getSimpleData(splitAux);

                      print("checksum: $checksum");
                    }
                    
                    return Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          height: 200.0,
                          child: SfCartesianChart(
                            primaryXAxis: NumericAxis(
                              anchorRangeToVisiblePoints: true,
                              autoScrollingMode: AutoScrollingMode.end,
                              autoScrollingDelta: 0,
                            ),
                            series: [
                              LineSeries<ListDataModel, num>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  _chartSeriesController = controller;
                                },
                                dataSource: chartData!,
                                xValueMapper: (ListDataModel data, _) =>
                                    data.time,
                                yValueMapper: (ListDataModel data, _) =>
                                    data.value,
                                animationDuration: 0,
                                width: 3,
                                animationDelay: 0,
                                yAxisName: "Amplitud [ mV ]",
                                xAxisName: "Tiempo [ s ]",
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    return const Text('Check the stream');
                  }
                },
              ),
            ],
          ),
        ),
      ])),
    );
  }
}

refresh() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  s1<DeviceListCubit>().startSearching(["THealtBLE"]);
}

String formatDuration(double totalSeconds) {
  final duration = Duration(seconds: totalSeconds.toInt());
  final minutes = duration.inMinutes;
  final seconds = (totalSeconds % 60).toStringAsFixed(0);

  final minutesString = '$minutes'.padLeft(2, '0');
  final secondsString = seconds.padLeft(2, '0');
  return '$minutesString:$secondsString';
}
