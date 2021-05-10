class MusicItem {
  String name;
  int id;
  String singer;
  String picUrl;

  MusicItem({this.name, this.id, this.singer, this.picUrl});

  MusicItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    singer = json['singer'];
    picUrl = json['picUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['singer'] = this.singer;
    data['picUrl'] = this.picUrl;
    return data;
  }
}