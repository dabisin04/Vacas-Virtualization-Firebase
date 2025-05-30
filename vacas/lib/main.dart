import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:vacas/application/bloc/farm/farm_event.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_bloc.dart';
import 'package:vacas/domain/entities/animal.dart';
import 'package:vacas/domain/repositories/animal_repository.dart';
import 'package:vacas/domain/repositories/chequeo_salud_repository.dart';
import 'package:vacas/domain/repositories/evento_reproductivo_repository.dart';
import 'package:vacas/domain/repositories/farm_repository.dart';
import 'package:vacas/domain/repositories/madeItHybrid/animal_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/chequeo_salud_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/evento_reproductivo_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/farm_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/peso_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/produccion_leche_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/tratamiento_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/user_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/usuario_finca_repository_hibryd.dart';
import 'package:vacas/domain/repositories/madeItHybrid/vacuna_repository_hibryd.dart';
import 'package:vacas/domain/repositories/peso_repository.dart';
import 'package:vacas/domain/repositories/produccion_leche_repository.dart';
import 'package:vacas/domain/repositories/tratamiento_repository.dart';
import 'package:vacas/domain/repositories/user_repository.dart';
import 'package:vacas/domain/repositories/usuario_finca_repository.dart';
import 'package:vacas/domain/repositories/vacuna_repository.dart';
import 'package:vacas/firestore/user_repository_firestore.dart';
import 'package:vacas/firestore/animal_repository_firestore.dart';
import 'package:vacas/firestore/chequeo_salud_repository_firestore.dart';
import 'package:vacas/firestore/evento_reporductivo_repository_firestore.dart';
import 'package:vacas/firestore/farm_repository_firestore.dart';
import 'package:vacas/firestore/peso_repository_firestore.dart';
import 'package:vacas/firestore/production_repository_firestore.dart';
import 'package:vacas/firestore/tratamiento_repository_firestore.dart';
import 'package:vacas/firestore/usuario_finca_repository_firestore.dart';
import 'package:vacas/firestore/vacunas_repository_firestore.dart';
import 'package:vacas/infrastucture/adapters/animal_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/chequeo_salud_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/evento_reproductivo_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/farm_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/peso_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/production_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/tratamiento_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/user_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/usuario_finca_repository_impl.dart';
import 'package:vacas/infrastucture/adapters/vacunas_repository_impl.dart';
import 'package:vacas/presentation/screens/agregar_empleado.dart';
import 'package:vacas/presentation/screens/crear_finca_page.dart';
import 'package:vacas/presentation/screens/home_page.dart';
import 'package:vacas/presentation/screens/login_screen.dart';
import 'package:vacas/presentation/screens/produccion_screen_navigator.dart';
import 'package:vacas/presentation/screens/register_screen.dart';
import 'package:vacas/presentation/screens/screensnavigators/detalle_animal_page.dart';
import 'package:vacas/presentation/screens/screensnavigators/inicio_page.dart';
import 'package:vacas/presentation/screens/screensnavigators/produccion_page.dart';
import 'package:vacas/presentation/screens/screensnavigators/reproduccion_page.dart';
import 'package:vacas/presentation/screens/screensnavigators/salud_page.dart';
import 'package:vacas/presentation/screens/seleccionar_finca_page.dart';
import 'core/services/sqlite_service.dart';
import 'presentation/screens/splash_screen.dart';
import 'package:vacas/application/bloc/animal/animal_bloc.dart';
import 'package:vacas/application/bloc/chequeo_salud/chequeo_salud_bloc.dart';
import 'package:vacas/application/bloc/evento_reproductivo/evento_reproductivo_bloc.dart';
import 'package:vacas/application/bloc/farm/farm_bloc.dart';
import 'package:vacas/application/bloc/peso/peso_bloc.dart';
import 'package:vacas/application/bloc/produccion_leche/produccion_leche_bloc.dart';
import 'package:vacas/application/bloc/tratamiento/tratamiento_bloc.dart';
import 'package:vacas/application/bloc/user/user_bloc.dart';
import 'package:vacas/application/bloc/vacuna/vacuna_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteAllCollectionsFromFirebase() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final collectionsToDelete = [
      'users',
      'farms',
      'animales',
      'vacunas',
      'tratamientos',
      'pesos',
      'produccion_leche',
      'chequeos_salud',
      'eventos_reproductivos',
      'usuario_finca',
    ];

    for (final name in collectionsToDelete) {
      final snapshot = await firestore.collection(name).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('🗑️ Colección $name eliminada');
    }
    debugPrint('✅ Todos los datos de Firebase eliminados');
  } catch (e) {
    debugPrint('❌ Error al eliminar datos de Firebase: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  const bool deleteFirebaseData = true;
  if (deleteFirebaseData) {
    await deleteAllCollectionsFromFirebase();
  }

  Future<void> _initializeAppCheck() async {
    try {
      if (Platform.isAndroid) {
        await FirebaseAppCheck.instance.activate(
          androidProvider:
              AndroidProvider.debug, // Usa 'playIntegrity' en producción
        );
      } else if (Platform.isIOS) {
        await FirebaseAppCheck.instance.activate(
          appleProvider: AppleProvider.debug, // Usa 'appAttest' en producción
        );
      } else {
        debugPrint('⚠️ Firebase App Check no soportado en esta plataforma.');
      }

      debugPrint('✅ Firebase App Check activado correctamente.');
    } catch (e) {
      debugPrint('❌ Error activando Firebase App Check: $e');
    }
  }

  await _initializeAppCheck();

  await initializeDateFormatting('es', null);
  await SQLiteService.instance;

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  /*if (!kIsWeb) {
    // ⚠️ Solo para desarrollo: eliminar la base de datos si existe
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/ganado.db';
    if (await File(path).exists()) {
      await deleteDatabase(path);
      print('🗑️ Base de datos ganado.db eliminada');
    }

    // Inicializar la base de datos nuevamente (ya con los cambios como foto_url)
    await SQLiteService.instance;
  }*/

  runApp(const GanadoApp());
}

class GanadoApp extends StatelessWidget {
  const GanadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
            create: (_) => UserRepositoryHybrid(
                  localRepository: UserRepositoryImpl(),
                  firebaseRepository: UserRepositoryFirestore(),
                )),
        RepositoryProvider<AnimalRepository>(
            create: (_) => AnimalRepositoryHybrid(
                  localRepository: AnimalRepositoryImpl(),
                  firebaseRepository: AnimalRepositoryFirestore(),
                )),
        RepositoryProvider<VacunaRepository>(
            create: (_) => VacunaRepositoryHybrid(
                  localRepository: VacunaRepositoryImpl(),
                  firebaseRepository: VacunaRepositoryFirestore(),
                )),
        RepositoryProvider<TratamientoRepository>(
            create: (_) => TratamientoRepositoryHybrid(
                  localRepository: TratamientoRepositoryImpl(),
                  firebaseRepository: TratamientoRepositoryFirestore(),
                )),
        RepositoryProvider<PesoRepository>(
            create: (_) => PesoRepositoryHybrid(
                  localRepository: PesoRepositoryImpl(),
                  firebaseRepository: PesoRepositoryFirestore(),
                )),
        RepositoryProvider<ProduccionLecheRepository>(
            create: (_) => ProduccionLecheRepositoryHybrid(
                  localRepository: ProduccionLecheRepositoryImpl(),
                  firebaseRepository: ProduccionLecheRepositoryFirestore(),
                )),
        RepositoryProvider<ChequeoSaludRepository>(
            create: (_) => ChequeoSaludRepositoryHybrid(
                  localRepository: ChequeoSaludRepositoryImpl(),
                  firebaseRepository: ChequeoSaludRepositoryFirestore(),
                )),
        RepositoryProvider<EventoReproductivoRepository>(
            create: (_) => EventoReproductivoRepositoryHybrid(
                  localRepository: EventoReproductivoRepositoryImpl(),
                  firebaseRepository: EventoReproductivoRepositoryFirestore(),
                )),
        RepositoryProvider<FarmRepository>(
            create: (_) => FarmRepositoryHybrid(
                  localRepository: FarmRepositoryImpl(),
                  firebaseRepository: FarmRepositoryFirestore(),
                )),
        RepositoryProvider<UsuarioFincaRepository>(
            create: (_) => UsuarioFincaRepositoryHybrid(
                  localRepository: UsuarioFincaRepositoryImpl(),
                  firebaseRepository: UsuarioFincaRepositoryFirestore(),
                )),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => UsuarioBloc(c.read<UserRepository>())),
          BlocProvider(create: (c) => AnimalBloc(c.read<AnimalRepository>())),
          BlocProvider(create: (c) => VacunaBloc(c.read<VacunaRepository>())),
          BlocProvider(
              create: (c) => TratamientoBloc(c.read<TratamientoRepository>())),
          BlocProvider(create: (c) => PesoBloc(c.read<PesoRepository>())),
          BlocProvider(
              create: (c) =>
                  ProduccionLecheBloc(c.read<ProduccionLecheRepository>())),
          BlocProvider(
              create: (c) =>
                  ChequeoSaludBloc(c.read<ChequeoSaludRepository>())),
          BlocProvider(
              create: (c) => EventoReproductivoBloc(
                  c.read<EventoReproductivoRepository>())),
          BlocProvider(create: (c) => FarmBloc(c.read<FarmRepository>())),
          BlocProvider(
              create: (c) =>
                  UsuarioFincaBloc(c.read<UsuarioFincaRepository>())),
        ],
        child: MaterialApp(
          title: 'Gestión de Ganado',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Roboto',
          ),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const SplashScreen());
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(
                    builder: (_) => const RegisterScreen());
              case '/dashboard':
                return MaterialPageRoute(builder: (_) => const Homescreen());
              case '/produccion':
                return MaterialPageRoute(
                    builder: (_) => const ProduccionScreenNavigator());
              case '/seleccionar-finca':
                final args = settings.arguments as List<String>;
                return MaterialPageRoute(
                    builder: (_) => SeleccionarFincaPage(fincaIds: args));
              case '/crear-finca':
                return MaterialPageRoute(
                    builder: (_) => const CrearFincaPage());
              case '/reproduccion':
                final args = settings.arguments as Animal;
                return MaterialPageRoute(
                    builder: (_) => ReproduccionPage(animal: args));
              case '/salud':
                final args = settings.arguments as Animal;
                return MaterialPageRoute(
                    builder: (_) => HealthPage(animal: args));
              case '/agregar-empleado':
                return MaterialPageRoute(
                    builder: (_) => const AgregarEmpleadoPage());
              case '/produccion-leche':
                final args = settings.arguments as Animal;
                return MaterialPageRoute(
                    builder: (_) => ProduccionPage(animal: args));
              case '/resumen-produccion':
                return MaterialPageRoute(builder: (_) => const InicioPage());
              case '/detalle-animal':
                final animal = settings.arguments as Animal;
                return MaterialPageRoute(
                    builder: (_) => DetalleAnimalPage(animal: animal));
              default:
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('Ruta no encontrada')),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
