// appwrite_config.dart
import 'package:appwrite/appwrite.dart';

// Initialize the Appwrite client
final Client client = Client()
  ..setEndpoint('https://localhost/v1') // Your Appwrite Endpoint
  ..setProject('676506150033480a87c5') // Your project ID
  ..setSelfSigned(); // Use only on dev mode with a self-signed SSL cert

final Account account = Account(client);


// Initialize the Databases instance
final Databases databases = Databases(client);
