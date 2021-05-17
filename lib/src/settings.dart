import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static final Settings _instance = Settings._internal();

  factory Settings() {
    return _instance;
  }

  Settings._internal();

  //

  var _intStreams = Map<String, _SettingStream<int>>();

  _SettingStream? _getIntStreamOf(String settingKey) {
    if (_intStreams.containsKey(settingKey)) {
      return _intStreams[settingKey];
    }
    _SettingStream<int> stream = _SettingStream<int>();
    _intStreams[settingKey] = stream;
    return stream;
  }

  StreamBuilder<int> onIntChanged({
    required String settingKey,
    required int defaultValue,
    required Function childBuilder,
  }) {
    return StreamBuilder<int>(
      stream: _getIntStreamOf(settingKey)!.stream as Stream<int>?,
      initialData: defaultValue,
      builder: (context, snapshot) {
        return childBuilder(context, snapshot.data);
      },
    );
  }

  void _intChanged(String settingKey, int value) {
    if (_intStreams.containsKey(settingKey)) {
      _intStreams[settingKey]!.push(value);
    }
  }

  //

  var _boolStreams = Map<String, _SettingStream<bool>>();

  _SettingStream? _getBoolStreamOf(String settingKey) {
    if (_boolStreams.containsKey(settingKey)) {
      return _boolStreams[settingKey];
    }
    _SettingStream<bool> stream = _SettingStream<bool>();
    _boolStreams[settingKey] = stream;
    return stream;
  }

  StreamBuilder<bool> onBoolChanged({
    required String settingKey,
    required bool defaultValue,
    required Function childBuilder,
  }) {
    return StreamBuilder<bool>(
      stream: _getBoolStreamOf(settingKey)!.stream as Stream<bool>?,
      initialData: defaultValue,
      builder: (context, snapshot) {
        return childBuilder(context, snapshot.data);
      },
    );
  }

  void _boolChanged(String settingKey, bool value) {
    if (_boolStreams.containsKey(settingKey)) {
      _boolStreams[settingKey]!.push(value);
    }
  }

  //

  var _stringStreams = Map<String, _SettingStream<String?>>();

  _SettingStream? _getStringStreamOf(String settingKey) {
    if (_stringStreams.containsKey(settingKey)) {
      return _stringStreams[settingKey];
    }
    _SettingStream<String> stream = _SettingStream<String>();
    _stringStreams[settingKey] = stream;
    return stream;
  }

  StreamBuilder<String> onStringChanged({
    required String settingKey,
    required String? defaultValue,
    required Function childBuilder,
  }) {
    return StreamBuilder<String>(
      stream: _getStringStreamOf(settingKey)!.stream as Stream<String>?,
      initialData: defaultValue,
      builder: (context, snapshot) {
        return childBuilder(context, snapshot.data);
      },
    );
  }

  void _stringChanged(String settingKey, String? value) {
    _stringStreams[settingKey]?.push(value);
  }

  //

  var _doubleStreams = Map<String, _SettingStream<double>>();

  _SettingStream? _getDoubleStreamOf(String settingKey) {
    if (_doubleStreams.containsKey(settingKey)) {
      return _doubleStreams[settingKey];
    }
    _SettingStream<double> stream = _SettingStream<double>();
    _doubleStreams[settingKey] = stream;
    return stream;
  }

  StreamBuilder<double> onDoubleChanged({
    required String settingKey,
    required double? defaultValue,
    required Function childBuilder,
  }) {
    return StreamBuilder<double>(
      stream: _getDoubleStreamOf(settingKey)!.stream as Stream<double>?,
      initialData: defaultValue,
      builder: (context, snapshot) {
        return childBuilder(context, snapshot.data);
      },
    );
  }

  void _doubleChanged(String settingKey, double value) {
    if (_doubleStreams.containsKey(settingKey)) {
      _doubleStreams[settingKey]!.push(value);
    }
  }

  //

  Future<int> getInt(String key, int defaultValue) async {
    return (await SharedPreferences.getInstance()).getInt(key) ?? defaultValue;
  }

  Future<String?> getString(String key, String? defaultValue) async {
    return (await SharedPreferences.getInstance()).getString(key) ??
        defaultValue;
  }

  Future<double> getDouble(String key, double defaultValue) async {
    return (await SharedPreferences.getInstance()).getDouble(key) ??
        defaultValue;
  }

  Future<bool> getBool(String key, bool defaultValue) async {
    return (await SharedPreferences.getInstance()).getBool(key) ?? defaultValue;
  }

  Future<void> pingString(String key, String? defaultValue) async {
    _stringChanged(key, await getString(key, defaultValue));
  }

  Future<void> pingDouble(String key, double defaultValue) async {
    _doubleChanged(key, await getDouble(key, defaultValue));
  }

  Future<void> pingBool(String key, bool defaultValue) async {
    _boolChanged(key, await getBool(key, defaultValue));
  }

  Future<void> save(String key, dynamic value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value is int) {
      await sharedPreferences.setInt(key, value);
      _intChanged(key, value);
    } else if (value is String) {
      await sharedPreferences.setString(key, value);
      _stringChanged(key, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(key, value);
      _doubleChanged(key, value);
    } else if (value is bool) {
      await sharedPreferences.setBool(key, value);
      _boolChanged(key, value);
    }
  }
}

class _SettingStream<T> {
  final BehaviorSubject<T> _subject = BehaviorSubject<T>();

  Stream<T> get stream => _subject.stream;

  void push(T data) {
    _subject.add(data);
  }
}
