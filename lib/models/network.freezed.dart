// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'network.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Network {
  String get ssid => throw _privateConstructorUsedError;
  List<NetworkManagerAccessPoint> get accessPoints =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NetworkCopyWith<Network> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkCopyWith<$Res> {
  factory $NetworkCopyWith(Network value, $Res Function(Network) then) =
      _$NetworkCopyWithImpl<$Res>;
  $Res call({String ssid, List<NetworkManagerAccessPoint> accessPoints});
}

/// @nodoc
class _$NetworkCopyWithImpl<$Res> implements $NetworkCopyWith<$Res> {
  _$NetworkCopyWithImpl(this._value, this._then);

  final Network _value;
  // ignore: unused_field
  final $Res Function(Network) _then;

  @override
  $Res call({
    Object? ssid = freezed,
    Object? accessPoints = freezed,
  }) {
    return _then(_value.copyWith(
      ssid: ssid == freezed
          ? _value.ssid
          : ssid // ignore: cast_nullable_to_non_nullable
              as String,
      accessPoints: accessPoints == freezed
          ? _value.accessPoints
          : accessPoints // ignore: cast_nullable_to_non_nullable
              as List<NetworkManagerAccessPoint>,
    ));
  }
}

/// @nodoc
abstract class _$$_NetworkCopyWith<$Res> implements $NetworkCopyWith<$Res> {
  factory _$$_NetworkCopyWith(
          _$_Network value, $Res Function(_$_Network) then) =
      __$$_NetworkCopyWithImpl<$Res>;
  @override
  $Res call({String ssid, List<NetworkManagerAccessPoint> accessPoints});
}

/// @nodoc
class __$$_NetworkCopyWithImpl<$Res> extends _$NetworkCopyWithImpl<$Res>
    implements _$$_NetworkCopyWith<$Res> {
  __$$_NetworkCopyWithImpl(_$_Network _value, $Res Function(_$_Network) _then)
      : super(_value, (v) => _then(v as _$_Network));

  @override
  _$_Network get _value => super._value as _$_Network;

  @override
  $Res call({
    Object? ssid = freezed,
    Object? accessPoints = freezed,
  }) {
    return _then(_$_Network(
      ssid: ssid == freezed
          ? _value.ssid
          : ssid // ignore: cast_nullable_to_non_nullable
              as String,
      accessPoints: accessPoints == freezed
          ? _value._accessPoints
          : accessPoints // ignore: cast_nullable_to_non_nullable
              as List<NetworkManagerAccessPoint>,
    ));
  }
}

/// @nodoc

class _$_Network extends _Network {
  const _$_Network(
      {required this.ssid,
      required final List<NetworkManagerAccessPoint> accessPoints})
      : _accessPoints = accessPoints,
        super._();

  @override
  final String ssid;
  final List<NetworkManagerAccessPoint> _accessPoints;
  @override
  List<NetworkManagerAccessPoint> get accessPoints {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accessPoints);
  }

  @override
  String toString() {
    return 'Network(ssid: $ssid, accessPoints: $accessPoints)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Network &&
            const DeepCollectionEquality().equals(other.ssid, ssid) &&
            const DeepCollectionEquality()
                .equals(other._accessPoints, _accessPoints));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(ssid),
      const DeepCollectionEquality().hash(_accessPoints));

  @JsonKey(ignore: true)
  @override
  _$$_NetworkCopyWith<_$_Network> get copyWith =>
      __$$_NetworkCopyWithImpl<_$_Network>(this, _$identity);
}

abstract class _Network extends Network {
  const factory _Network(
          {required final String ssid,
          required final List<NetworkManagerAccessPoint> accessPoints}) =
      _$_Network;
  const _Network._() : super._();

  @override
  String get ssid;
  @override
  List<NetworkManagerAccessPoint> get accessPoints;
  @override
  @JsonKey(ignore: true)
  _$$_NetworkCopyWith<_$_Network> get copyWith =>
      throw _privateConstructorUsedError;
}
