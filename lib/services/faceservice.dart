import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FaceRecognitionService {
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  Database? _database;

  // Simple face feature extraction (simplified - for production, use proper ML model)
  List<double> extractFaceFeatures(img.Image faceImage) {
    // Resize face to standard size
    img.Image resized = img.copyResize(faceImage, width: 112, height: 112);

    // Convert to grayscale and extract simple features
    List<double> features = [];

    // Divide face into regions and calculate average brightness
    int regionSize = 16;
    for (int y = 0; y < 112; y += regionSize) {
      for (int x = 0; x < 112; x += regionSize) {
        double sum = 0;
        int count = 0;

        for (int dy = 0; dy < regionSize && y + dy < 112; dy++) {
          for (int dx = 0; dx < regionSize && x + dx < 112; dx++) {
            img.Pixel pixel = resized.getPixel(x + dx, y + dy);


            // Convert to grayscale
            double gray = 0.299  + 0.587  + 0.114  ;
            sum += gray;
            count++;
          }
        }

        features.add(sum / count / 255.0); // Normalize to 0-1
      }
    }

    return features;
  }

  // Calculate similarity between two feature vectors
  double calculateSimilarity(List<double> features1, List<double> features2) {
    if (features1.length != features2.length) return 0.0;

    // Cosine similarity
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < features1.length; i++) {
      dotProduct += features1[i] * features2[i];
      norm1 += features1[i] * features1[i];
      norm2 += features2[i] * features2[i];
    }

    if (norm1 == 0 || norm2 == 0) return 0.0;
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  // Initialize database
  Future<void> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'face_attendance.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE employees (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            face_features TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id TEXT NOT NULL,
            punch_time INTEGER NOT NULL,
            type TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            address TEXT,
            face_verified INTEGER DEFAULT 1,
            FOREIGN KEY (employee_id) REFERENCES employees (id)
          )
        ''');
      },
    );
  }

  // Register employee face
  Future<bool> registerEmployeeFace(String employeeId, String employeeName, File faceImage) async {
    try {
      // Read and process image
      img.Image? image = img.decodeImage(await faceImage.readAsBytes());
      if (image == null) return false;

      // Extract features
      List<double> features = extractFaceFeatures(image);

      // Convert features to string for storage
      String featuresString = features.join(',');

      // Save to database
      await _database?.insert(
        'employees',
        {
          'id': employeeId,
          'name': employeeName,
          'face_features': featuresString,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    } catch (e) {
      print('Error registering face: $e');
      return false;
    }
  }

  // Verify face for attendance
  Future<Map<String, dynamic>?> verifyFace(File faceImage, {double threshold = 0.65}) async {
    try {
      // Read and process input face
      img.Image? inputImage = img.decodeImage(await faceImage.readAsBytes());
      if (inputImage == null) return null;

      // Extract features from input face
      List<double> inputFeatures = extractFaceFeatures(inputImage);

      // Get all registered employees
      final List<Map<String, dynamic>> employees = await _database?.query('employees') ?? [];

      if (employees.isEmpty) return null;

      // Find best match
      String? bestMatchId;
      String? bestMatchName;
      double bestSimilarity = 0;

      for (var employee in employees) {
        // Parse stored features
        List<double> storedFeatures = (employee['face_features'] as String)
            .split(',')
            .map((s) => double.parse(s))
            .toList();

        // Calculate similarity
        double similarity = calculateSimilarity(inputFeatures, storedFeatures);

        if (similarity > bestSimilarity && similarity > threshold) {
          bestSimilarity = similarity;
          bestMatchId = employee['id'];
          bestMatchName = employee['name'];
        }
      }

      if (bestMatchId != null) {
        return {
          'id': bestMatchId,
          'name': bestMatchName,
          'similarity': bestSimilarity,
        };
      }

      return null;
    } catch (e) {
      print('Error verifying face: $e');
      return null;
    }
  }

  // Get all employees
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    return await _database?.query('employees') ?? [];
  }

  // Check if employee exists
  Future<bool> employeeExists(String employeeId) async {
    final result = await _database?.query(
      'employees',
      where: 'id = ?',
      whereArgs: [employeeId],
    );
    return result?.isNotEmpty ?? false;
  }
}