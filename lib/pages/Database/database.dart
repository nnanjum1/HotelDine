import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwriteConfig.dart'; // Import the Appwrite client and Databases instance

class DatabaseService {
  final Databases _databases;


  DatabaseService(this._databases);

  final String databaseId = const String.fromEnvironment('DATABASE_ID', defaultValue: '67650e170015d7a01bc8');

  // Define collections
  final Map<String, String> collections = {
    'Users': const String.fromEnvironment('Users', defaultValue: '67650e290037f19f628f'),

  };

  // Get collection handlers
  Map<String, dynamic> getCollection(String name) {
    final collectionId = collections[name];
    if (collectionId == null) {
      throw Exception('Collection $name does not exist.');
    }

    return {
      'create': ({
        required Map<String, dynamic> payload,
        List<String>? permissions,
        String? documentId,
      }) async =>
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId ?? ID.unique(),
        data: payload,
        permissions: permissions,
      ),

      'update': ({
        required String documentId,
        required Map<String, dynamic> payload,
        List<String>? permissions,
      }) async =>
      await _databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: payload,
        permissions: permissions,
      ),

      'delete': ({
        required String documentId,
      }) async =>
      await _databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      ),

      'list': ({
        List<String>? queries,
      }) async =>
      await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries,
      ),

      'get': ({
        required String documentId,
      }) async =>
      await _databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      ),
    };
  }
}

// Initialize the DatabaseService
final DatabaseService databaseService = DatabaseService(databases);
