class EndpointProvider {
  final String baseUrl;

  EndpointProvider({this.baseUrl = 'https://api.example.com/v1'});

  String mediaInitUrl() => '$baseUrl/media/upload/init';
  String mediaChunkUrl() => '$baseUrl/media/upload/chunk';
  String mediaCompleteUrl() => '$baseUrl/media/upload/complete';
}
