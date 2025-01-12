// appwrite_config.dart
import 'package:appwrite/appwrite.dart';

// Initialize the Appwrite client

final Client client = Client()

    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('676506150033480a87c5')
    .setSelfSigned(); // Only for development


final Account account = Account(client);


// Initialize the Databases instance
final Databases databases = Databases(client);
