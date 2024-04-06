import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // Open the database
    return openDatabase(
      join(await getDatabasesPath(), 'your_database.db'),
      onCreate: (db, version) async {
        // Create tables here
        await db.execute('''
          CREATE TABLE conversation (
            id INTEGER PRIMARY KEY,
            code TEXT,
            title TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE contenu_conversation (
            id INTEGER PRIMARY KEY,
            id_conversation INTEGER,
            message TEXT,
            qui_parle INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> createConversation(String title) async {
    Database db = await database;

    // Générer un code de conversation à 6 caractères
    String code = generateCode();

    // Insérer la conversation
    await db.insert(
      'conversation',
      {'code': code, 'title': title},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Récupérer l'ID de la conversation insérée
    int conversationId = await db.query(
      'conversation',
      where: 'code = ?',
      whereArgs: [code],
    ).then((value) => value.first['id'] as int);

    // Insérer le message avec qui_parle = 0
    await db.insert(
      'contenu_conversation',
      {'id_conversation': conversationId, 'message': title, 'qui_parle': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final String apiKey = 'AIzaSyBqvT2nw52PV31amz-NA_LJSeKwxC3NJdc';
    final String cseId = '3312c6fdc09e647cd';

    if (title.contains('image')) {
      final String query = Uri.encodeQueryComponent(title);

      final Uri uri = Uri.https(
        'www.googleapis.com',
        '/customsearch/v1',
        {'key': apiKey, 'cx': cseId, 'q': query, 'num': '1', 'searchType': 'image', 'hl': 'fr'},
      );

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          String imageUrl;

          if (data.containsKey('items') && (data['items'] as List).isNotEmpty) {
            imageUrl = data['items'][0]['link'];
          } else {
            imageUrl = "Aucune image trouvée sur Google.";
          }

          // Insérer l'URL de l'image dans la table contenu_conversation avec qui_parle = 1
          await db.insert(
            'contenu_conversation',
            {'id_conversation': conversationId, 'message': imageUrl, 'qui_parle': 1},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          print("Erreur lors de la recherche sur Google.");
        }
      } catch (e) {
        print("Erreur lors de la recherche sur Google : $e");
      }
    }  else {
      final Uri uri = Uri.https(
        'www.googleapis.com',
        '/customsearch/v1',
        {'key': apiKey, 'cx': cseId, 'q': title, 'num': '1', 'hl': 'fr'},
      );

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data.containsKey('items')) {
            String googleResponse = data['items'][0]['snippet'];

            // Insérer la réponse de Google dans la table contenu_conversation avec qui_parle = 1
            await db.insert(
              'contenu_conversation',
              {'id_conversation': conversationId, 'message': googleResponse, 'qui_parle': 1},
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            String googleResponse = "Aucun résultat trouvé sur Google.";
            // Insérer la réponse de Google dans la table contenu_conversation avec qui_parle = 1
            await db.insert(
              'contenu_conversation',
              {'id_conversation': conversationId, 'message': googleResponse, 'qui_parle': 1},
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        } else {
          print("Erreur lors de la recherche sur Google.");
        }
      } catch (e) {
        print("Erreur lors de la recherche sur Google : $e");
      }
    }
    return conversationId;
  }
  String generateCode() {
    // Implement your code generation logic here
    // This is a simple example, you may want to create a more robust solution
    return DateTime.now().microsecondsSinceEpoch.remainder(1000000).toString();
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    Database db = await database;
    return db.query('conversation', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getMessagesForConversation(int conversationId) async {
    Database db = await database;
    return db.query('contenu_conversation', where: 'id_conversation = ?', whereArgs: [conversationId]);
  }

  Future<void> addContentToConversation(int conversationId, String message) async {
    Database db = await database;

    await db.insert(
      'contenu_conversation',
      {'id_conversation': conversationId, 'message': message, 'qui_parle': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final String apiKey = 'AIzaSyBqvT2nw52PV31amz-NA_LJSeKwxC3NJdc';
    final String cseId = '3312c6fdc09e647cd';

    if (message.contains('image')) {
      final String query = Uri.encodeQueryComponent(message);

      final Uri uri = Uri.https(
        'www.googleapis.com',
        '/customsearch/v1',
        {'key': apiKey, 'cx': cseId, 'q': query, 'num': '1', 'searchType': 'image', 'hl': 'fr'},
      );

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          String imageUrl;

          if (data.containsKey('items') && (data['items'] as List).isNotEmpty) {
            imageUrl = data['items'][0]['link'];
          } else {
            imageUrl = "Aucune image trouvée sur Google.";
          }

          // Insérer l'URL de l'image dans la table contenu_conversation avec qui_parle = 1
          await db.insert(
            'contenu_conversation',
            {'id_conversation': conversationId, 'message': imageUrl, 'qui_parle': 1},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          print("Erreur lors de la recherche sur Google.");
        }
      } catch (e) {
        print("Erreur lors de la recherche sur Google : $e");
      }
    }  else {
      final Uri uri = Uri.https(
        'www.googleapis.com',
        '/customsearch/v1',
        {'key': apiKey, 'cx': cseId, 'q': message, 'num': '1', 'hl': 'fr'},
      );

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data.containsKey('items')) {
            String googleResponse = data['items'][0]['snippet'];

            // Insérer la réponse de Google dans la table contenu_conversation avec qui_parle = 1
            await db.insert(
              'contenu_conversation',
              {'id_conversation': conversationId, 'message': googleResponse, 'qui_parle': 1},
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            String googleResponse = "Aucun résultat trouvé sur Google.";
            // Insérer la réponse de Google dans la table contenu_conversation avec qui_parle = 1
            await db.insert(
              'contenu_conversation',
              {'id_conversation': conversationId, 'message': googleResponse, 'qui_parle': 1},
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        } else {
          print("Erreur lors de la recherche sur Google.");
        }
      } catch (e) {
        print("Erreur lors de la recherche sur Google : $e");
      }
    }
  }

  // Dans votre méthode deleteConversation de DatabaseHelper
  Future<void> deleteConversation(int conversationId) async {
    Database db = await database;
    // Supprimez la conversation et tous ses messages associés
    await db.delete('conversation', where: 'id = ?', whereArgs: [conversationId]);
    await db.delete('contenu_conversation', where: 'id_conversation = ?', whereArgs: [conversationId]);
  }

  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Impossible d\'ouvrir l\'URL : $url');
    }
  }


}
