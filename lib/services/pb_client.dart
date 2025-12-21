import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

final pocketBase = PocketBase(
  dotenv.env['POCKETBASE_URL'] ?? 'http://10.0.2.2:8090',
);
