import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwriteConfig.dart'; // Import the Appwrite client and Databases instance

class DatabaseService {
  final Databases _databases;

  // Constructor for the DatabaseService class
  DatabaseService(this._databases);

  // The databaseId is read from environment variables
  final String databaseId = const String.fromEnvironment(
    'DATABASE_ID',
    defaultValue: '67650e170015d7a01bc8',
  );

  // Define collections with their respective collection IDs
  final Map<String, String> collections = {
    'Users': const String.fromEnvironment(
      'Users',
      defaultValue: '67650e290037f19f628f',
    ),

    // Room information:
    'AddRoomContainer': const String.fromEnvironment(
      'AddRoomContainer',
      defaultValue: '6784c4dd00332fc62aeb',
    ),
    // Add other collections as needed, e.g.:
    // 'Orders': const String.fromEnvironment('Orders', defaultValue: 'order_collection_id'),
  };

  // Get collection handlers (create, update, delete, list, get)
  Map<String, dynamic> getCollection(String name) {
    final collectionId = collections[name];
    if (collectionId == null) {
      throw Exception('Collection $name does not exist.');
    }

    return {
      // Create a new document in the collection
      'create': (({
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
      )),

      // Update an existing document in the collection
      'update': (({
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
      )),

      // Delete a document from the collection
      'delete': (({
        required String documentId,
      }) async =>
      await _databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      )),

      // List documents from the collection
      'list': (({
        List<Query>? queries, // Ensure queries is always a List<Query>?
      }) async {
        // Safely default to an empty list if queries is null
        List<Query> finalQueries = queries ?? <Query>[];

        return await _databases.listDocuments(
          databaseId: databaseId,
          collectionId: collectionId,
          // Pass the correctly typed queries
        );
      }),

      // Get a single document by its ID
      'get': (({
        required String documentId,
      }) async =>
      await _databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      )),
    };
  }

  // Method to fetch user data by email
  Future<Map<String, dynamic>> getUserDataByEmail(String email) async {
    try {
      final userCollection = getCollection('Users');
      final response = await userCollection['list'](
        queries: [
          Query.equal('email', email), // Query to match the email field
        ],
      );

      if (response.documents.isNotEmpty) {
        return response.documents.first.data; // Return the first matching document
      }
      return {};
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  // Method to fetch all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final userCollection = getCollection('Users');
      final response = await userCollection['list']();
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }
}

// Initialize the DatabaseService
final DatabaseService databaseService = DatabaseService(databases);