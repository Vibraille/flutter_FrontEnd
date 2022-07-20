import 'dart:async';
import 'dart:convert' show json;

import 'package:http/http.dart' as http;

class NotesClient {
  /*final _host = 'api.raywenderlich.com';
  final _contextRoot = 'api';

  Future<List<Note>?> fetchArticles(String? query) async {
    Map<String, Object> params = {
      'filter[content_types][]': 'article',
      'page[size]': '25',
    };

    if (query != null && query.isNotEmpty) {
      params['filter[q]'] = query;
    }

    final results = await request(path: 'contents', parameters: params);
    return results['data'].map<Note>(Note.fromJson).toList(
        growable: false);
  }

  Future<Note?> getDetailArticle(String id) async {
    final results = await request(path: 'contents/$id', parameters: {});
    final data = results['data'];
    return Note.fromJson(data);
  }

  Future<Map> request({
    required String path,
    required Map<String, Object> parameters,
  }) async {
    final uri = Uri.https(_host, '$_contextRoot/$path', parameters);
    final headers = _headers;
    final results = await http.get(uri, headers: headers);
    final jsonObject = json.decode(results.body);
    return jsonObject;
  }

  Map<String, String> get _headers =>
      {
        'content-type': 'application/vnd.api+json; charset=utf-8',
        'Accept': 'application/json',
      }; */
}
  class Note {
  /*late final String id;
  late final String? type;
  late final Attributes? attributes;
  late final Links? links;

  Article.fromJson(dynamic json)
      : id = json['id'],
  type = json['type'],
  attributes = Attributes.fromJson(json['attributes']),
  links = Links.fromJson(json['links']);
  }

  class Attributes {
  late final String? uri;
  late final String? name;
  late final String? description;
  late final String? released_at;
  late final bool? free;
  late final String? difficulty;
  late final String? content_type;
  late final int duration;
  late final double? popularity;
  late final String? technology_triple_string;
  late final String? contributor_string;
  late final String? ordinal;
  late final bool? professional;
  late final String? description_plain_text;
  late final int? video_identifier;
  late final int? parent_name;
  late final bool? accessible;
  late final String? card_artwork_url;

  Attributes.fromJson(Map json)
      : uri = json['uri'],
  name = json['name'],
  description = json['description'],
  released_at = json['released_at'],
  free = json['free'],
  difficulty = json['difficulty'],
  content_type = json['content_type'],
  duration = json['duration'],
  popularity = json['popularity'],
  technology_triple_string = json['technology_triple_string'],
  contributor_string = json['contributor_string'],
  ordinal = json['ordinal'],
  professional = json['professional'],
  description_plain_text = json['description_plain_text'],
  video_identifier = json['video_identifier'],
  parent_name = json['parent_name'],
  accessible = json['accessible'],
  card_artwork_url = json['card_artwork_url'];
  }

  class Links {
  late final String? self;

  Links.fromJson(Map json) : self = json['self'];
 */ }

