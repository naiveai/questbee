class ChannelModel {
  ChannelModel(this.subredditName, this.humanName, {this.iconImage});

  final String subredditName;
  final String humanName;
  final Uri iconImage;

  static ChannelModel fromJson(dynamic json) {
    return ChannelModel(
      json['subredditName'],
      json['humanName'],
      iconImage: Uri.tryParse(json['iconImage']),
    );
  }

  Map toJson() {
    return {
      'subredditName': subredditName,
      'humanName': humanName,
      'iconImage': iconImage.toString(),
    };
  }

  bool operator ==(o) {
    return o is ChannelModel && o.subredditName == subredditName;
  }

  int get hashCode => subredditName.hashCode;
}
