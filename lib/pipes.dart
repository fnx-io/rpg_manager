import 'package:angular2/core.dart';

@Pipe(name: 'asBonus')
class AsBonusPipe extends PipeTransform {

  String transform(num value) => value < 0 ? "${value}" : "+${value}";

}

@Pipe(name: 'asPercent')
class AsPercentPipe extends PipeTransform {

  String transform(num value) {
    if (value == null) return "0 %";
    return (value * 100).toStringAsFixed(2);
  }

}