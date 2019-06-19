import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'channels.g.dart';

abstract class ChannelModel implements Built<ChannelModel, ChannelModelBuilder> {
  static Serializer<ChannelModel> get serializer => _$channelModelSerializer;

  String get subredditName;
  String get humanName;

  @BuiltValueField(compare: false)
  @nullable
  Uri get iconImage;

  ChannelModel._();
  factory ChannelModel([void Function(ChannelModelBuilder) updates]) = _$ChannelModel;
}
