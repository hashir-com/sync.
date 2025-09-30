import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';

final authProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});
