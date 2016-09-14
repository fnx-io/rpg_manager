import 'package:angular2/core.dart';
import 'package:intl/intl.dart';

@Pipe(name: 'asBonus')
class AsBonusPipe extends PipeTransform {

  String transform(num value) => value < 0 ? "$value" : "+$value";

}

@Pipe(name: 'asPercent')
class AsPercentPipe extends PipeTransform {

  String transform(num value) {
    if (value == null) return "0 %";
    return (value * 100).toStringAsFixed(2);
  }

}

@Pipe(name: 'asDate')
class AsDatePipe extends PipeTransform {

  static DateFormat df = new DateFormat("MMM d, y G, HH:mm");

  String transform(DateTime value) {
    if (value == null) return "";
    return df.format(value);
  }

}

@Pipe(name: 'asDateLong')
class AsDateLongPipe extends PipeTransform {

  static DateFormat df = new DateFormat("EEEEE, MMMM d, y G, HH:mm");

  String transform(DateTime value) {
    if (value == null) return "";
    return df.format(value);
  }

}