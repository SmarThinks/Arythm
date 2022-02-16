import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_test/src/core/injection_container.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_list_cubic.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_list_state.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_selected_cubic.dart';
import 'package:tracker_test/src/features/devices/presentation/blue_stream_screen.dart';

class BlueListingScreen extends StatefulWidget {
  const BlueListingScreen({Key? key}) : super(key: key);

  @override
  State<BlueListingScreen> createState() => _BlueListingScreenState();
}

class _BlueListingScreenState extends State<BlueListingScreen>
    with WidgetsBindingObserver {
  DeviceEntity? deviceEntity;
  late var onInactive = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);
    if (!s1<DeviceSelectedCubit>().state.connected) {
      FlutterBlue.instance.stopScan();
      s1<DeviceListCubit>().startSearching(["THealt"]);
    }
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      if (s1<DeviceSelectedCubit>().state.connected) {
        s1<DeviceSelectedCubit>().disconnect(deviceEntity!);
      }
    }
  }

  Widget setHistoryScans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Sessions Scans",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Row(
              children: [
                const Text(
                  "ver todo",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                IconButton(
                    onPressed: () => {},
                    icon: const FaIcon(FontAwesomeIcons.longArrowAltRight))
              ],
            )
          ],
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.black26,
          child: Column(
            children: [
              const ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                title: Text('Session #n+1', style: TextStyle(fontSize: 20)),
                subtitle: Text('22. Julio 2021.',
                    style: TextStyle(fontStyle: FontStyle.italic)),
                trailing: Icon(Icons.panorama_fish_eye),
              ),
              SizedBox(
                height: 2,
                width: MediaQuery.of(context).size.width - 70,
                child: Container(
                  color: Colors.grey,
                ),
              ),
              const ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                title: Text('Session #n+1', style: TextStyle(fontSize: 20)),
                subtitle: Text('22. Julio 2021.',
                    style: TextStyle(fontStyle: FontStyle.italic)),
                trailing: Icon(Icons.panorama_fish_eye),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget setAutoFindDevice(BuildContext context) {
    return Positioned(
      top: 80,
      width: MediaQuery.of(context).size.width - 20,
      height: 50,
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: Colors.blue[900]),
          child: BlocBuilder<DeviceListCubit, DeviceListState>(
              bloc: s1<DeviceListCubit>(),
              builder: (context, state) {
                switch (state.status) {
                  case DeviceListStatus.initial:
                    return const Text(
                        "Presiona Buscar para iniciar la busqueda");
                  case DeviceListStatus.searching:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case DeviceListStatus.done:
                    final items = state.devices;
                    return items.isNotEmpty
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                const Text("Hemos encontrado un ArythmDev"),
                                IconButton(
                                    onPressed: () {
                                      for (var i = 0; i < items.length; i++) {
                                        var item = items[i];
                                        deviceEntity = item;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BlueStreamScreen(
                                                      device: item)),
                                        );
                                      }
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.externalLinkAlt,
                                      size: 18,
                                    ))
                              ])
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text("No encontramos ningun Arythm"),
                              IconButton(
                                  onPressed: () {
                                    FlutterBlue.instance.stopScan();
                                    s1<DeviceListCubit>()
                                        .startSearching(["THealt"]);
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.sync,
                                    size: 18,
                                  )),
                            ],
                          );
                  case DeviceListStatus.error:
                    return Text(state.message ?? '',
                        style: const TextStyle(color: Colors.red));
                }
              })),
    );
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
              onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.cog)),
          Expanded(
              child: Center(
            child: Text("ArythmApp".toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 25)),
          )),
          IconButton(
              onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.bell)),
          IconButton(
              onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.user)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.topCenter,
          children: [
            Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.topLeft,
                padding:
                    const EdgeInsets.only(top: 150.0, left: 20.0, right: 20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: setHistoryScans(context),
                )),
            customAppBar(context),
            setAutoFindDevice(context),
          ],
        ),
      ),
    );
  }
}
