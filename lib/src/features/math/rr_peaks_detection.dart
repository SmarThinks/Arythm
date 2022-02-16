import 'package:tracker_test/src/features/devices/data/models/data_model.dart';
import 'dart:math' as math;

class RRPeaksDetection {
  final List<dynamic> lowPassFilterArr = [];
  final List<dynamic> highPassFilterArr = [];
  final List<dynamic> derivativePassFilterArr = [];
  final List<dynamic> powPassFilterArr = [];
  final List<dynamic> windowFilterArr = [];
  final List<dynamic> normalizeArr = [];
  final List<dynamic> findPeaksArr = [];
  final List<dynamic> rrDetectionArr = [];
  var xlp = [], xhp = [];

  void init(int listLenght) {
    for (var i = 0; i < listLenght; i++) {
      xlp.insert(i, 0);
      xhp.insert(i, 0);
      derivativePassFilterArr.insert(i, 0);
      windowFilterArr.insert(i, 0);
      normalizeArr.insert(i, 0);
      findPeaksArr.insert(i, 0);
rrDetectionArr.insert(i, 0);
    }
  }

  List setLowPassFilter(List<ListDataModel> rawData) {
    var a = 0;
    for (var i = 12; i < rawData.length; i++) {
      var lpSalmple = 2 * xlp[i - 1] -
          xlp[i - 2] +
          rawData[i].value -
          2 * rawData[i - 6].value +
          rawData[i - 12].value;

      lowPassFilterArr.insert(a++, lpSalmple);
    }
    return lowPassFilterArr;
  }

  List setHighPassFilter(List<dynamic> lowPassFilterArr) {
    var a = 0;
    for (var i = 33; i < lowPassFilterArr.length; i++) {
      var hpSalmple = xhp[i - 1] -
          (1 / 32) * xhp[i] +
          lowPassFilterArr[i - 16] -
          lowPassFilterArr[i - 17] +
          (1 / 32) * lowPassFilterArr[i - 32];
      highPassFilterArr.insert(a, hpSalmple);
      a++;
    }
    return highPassFilterArr;
  }

  List setDerivativeFilter(List<ListDataModel> rawData) {
    for (var i = 5; i < rawData.length; i++) {
      var derSample = (1 / 8) *
          (2 * rawData[i].value +
              rawData[i - 1].value -
              rawData[i - 3].value -
              (2 * rawData[i - 4].value));
      derivativePassFilterArr.insert(i, derSample);
    }
    return derivativePassFilterArr;
  }

  List setPowPassFilter(List<dynamic> derivativePassFilterArr) {
    for (var i = 0; i < derivativePassFilterArr.length; i++) {
      var powSample = math.pow(derivativePassFilterArr[i], 2);
      powPassFilterArr.insert(i,powSample);
    }
    return powPassFilterArr;
  }

  List setWindowFilter(List<dynamic> powPassFilterArr) {
    int window = 13; //ToDo: variable a jugar
    var windSample;
    for (int i = 6; i < (powPassFilterArr.length - window); i += 1) {
      windSample = 0;
      for (int j = -6; j < 6; j++) {
        int k = i + j;
        windSample = windSample + powPassFilterArr[k];
      }
      windSample = windSample / window;
      windowFilterArr.insert(i,windSample);
    }
    return windowFilterArr;
  }

  List setNormalizeSignal(List<dynamic> windowFilterArr) {
    List<dynamic> arrAux = windowFilterArr;
    var minArr = 0.0;
    var maxArr = 0.0;
    for (var i = 0; i < windowFilterArr.length; i++) {
      if (maxArr < windowFilterArr[i]) {
        maxArr = windowFilterArr[i];
      }
      if (minArr > windowFilterArr[i]) {
        minArr = windowFilterArr[i];
      }
    }

    var diffArr = maxArr - minArr;
    var lessArr = [];
    for (var i = 0; i < windowFilterArr.length - 1; i++) {
      var item = windowFilterArr[i];
      lessArr.insert(i, item - minArr);
    }
    for (var i = 0; i < lessArr.length - 1; i++) {
      var item = lessArr[i];
      normalizeArr.insert(i, item / diffArr);
    }
    return normalizeArr;
  }

  List setFindPeaks(List<dynamic> normalizeArr) {
    //ToDo: Mostrar cantidad de picos
    for (var i = 10; i < normalizeArr.length - 10; i++) {
      num peak = 0;
      int counter = 0;
      for (var j = 0; j < 10; j++) {
        if (normalizeArr[i] > 0.35) {
          if (normalizeArr[i] > normalizeArr[i - j] &&
              normalizeArr[i] >= normalizeArr[i + j]) {
            counter++;
          }
        }
      }

      if (counter == 3) {
        peak = normalizeArr[i];
      } else {
        peak = 0;
      }

      findPeaksArr.insert(i, peak);
    }
    return findPeaksArr;
  }

  List setRRDetection(List<dynamic> finPeaksArr, List<dynamic> timePeaksArr) {
    //ToDo: Calcular vector tiempo, pruebas de adquisición, modificar la ventana de media movil y volvernos millonarios.
    print("${timePeaksArr.length}, ${finPeaksArr.length}");
    var counter = -1,
        RR_1 = 0.0,
        RR_2 = 0.0,
        RR_3 = 0.0,
        RRV = [],
        HR = [],
        f = -1;
    var _RR = 0.0, count = 0;
    for (var j = 0; j < finPeaksArr.length; j++) {
      if (finPeaksArr[j] != 0) {
        RR_1 = timePeaksArr[j];
        print("peak: ${count++}");
        if (RR_1 != 0 && RR_2 != 0) {
          var _RR = (RR_1 - RR_2);
          print("_RR: $_RR");
          rrDetectionArr.add(_RR);
        }
      }
      RR_2 = RR_1;
    }
    print(rrDetectionArr);
    return rrDetectionArr;
  }
}
