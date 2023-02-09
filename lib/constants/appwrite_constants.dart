class AppwriteConstants {
  static const String databaseId = '63dd12ce06c8d4c4eed7';
  static const String projectId = '63dcf490bfb780df00f2';
  static const String endPoint = 'http://192.168.0.56:80/v1';
  static const String usersCollection = '63df6dcd0dc663b584e0';
  static const String tweetsCollection = '63e10936795b4c7e360a';
  static const String imagesBucket = '63e4b5549f296a50bd9d';

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
