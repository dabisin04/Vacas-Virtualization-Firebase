// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/domain/repositories/animal_repository.dart';
import 'package:vacas/domain/repositories/chequeo_salud_repository.dart';
import 'package:vacas/domain/repositories/evento_reproductivo_repository.dart';
import 'package:vacas/domain/repositories/farm_repository.dart';
import 'package:vacas/domain/repositories/peso_repository.dart';
import 'package:vacas/domain/repositories/produccion_leche_repository.dart';
import 'package:vacas/domain/repositories/tratamiento_repository.dart';
import 'package:vacas/domain/repositories/user_repository.dart';
import 'package:vacas/domain/repositories/usuario_finca_repository.dart';
import 'package:vacas/domain/repositories/vacuna_repository.dart';
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
import 'package:vacas/infrastucture/remote/animal_repository_api.dart';
import 'package:vacas/infrastucture/remote/chequeo_salud_repository_api.dart';
import 'package:vacas/infrastucture/remote/evento_reproductivo_repository_api.dart';
import 'package:vacas/infrastucture/remote/farm_repository_api.dart';
import 'package:vacas/infrastucture/remote/peso_repository_api.dart';
import 'package:vacas/infrastucture/remote/production_repository_api.dart';
import 'package:vacas/infrastucture/remote/tratamiento_repository_api.dart';
import 'package:vacas/infrastucture/remote/user_repository_api.dart';
import 'package:vacas/infrastucture/remote/usuario_finca_repository_api.dart';
import 'package:vacas/infrastucture/remote/vacunas_repository_api.dart';
import 'package:vacas/application/bloc/user/user_bloc.dart';
import 'package:vacas/application/bloc/animal/animal_bloc.dart';
import 'package:vacas/application/bloc/vacuna/vacuna_bloc.dart';
import 'package:vacas/application/bloc/tratamiento/tratamiento_bloc.dart';
import 'package:vacas/application/bloc/peso/peso_bloc.dart';
import 'package:vacas/application/bloc/produccion_leche/produccion_leche_bloc.dart';
import 'package:vacas/application/bloc/chequeo_salud/chequeo_salud_bloc.dart';
import 'package:vacas/application/bloc/evento_reproductivo/evento_reproductivo_bloc.dart';
import 'package:vacas/application/bloc/farm/farm_bloc.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_bloc.dart';

class RepositoryInitializer {
  static Future<bool> _isOnline() async {
    if (kIsWeb) return true;
    final status = await Connectivity().checkConnectivity();
    return status != ConnectivityResult.none;
  }

  // Métodos privados para cada repo
  static Future<AnimalRepository> get _animal async =>
      await _isOnline() ? AnimalRepositoryApi() : AnimalRepositoryImpl();
  static Future<ChequeoSaludRepository> get _chequeo async => await _isOnline()
      ? ChequeoSaludRepositoryApi()
      : ChequeoSaludRepositoryImpl();
  static Future<EventoReproductivoRepository> get _evento async =>
      await _isOnline()
          ? EventoReproductivoRepositoryApi()
          : EventoReproductivoRepositoryImpl();
  static Future<FarmRepository> get _farm async =>
      await _isOnline() ? FarmRepositoryApi() : FarmRepositoryImpl();
  static Future<PesoRepository> get _peso async =>
      await _isOnline() ? PesoRepositoryApi() : PesoRepositoryImpl();
  static Future<ProduccionLecheRepository> get _produccion async =>
      await _isOnline()
          ? ProduccionLecheRepositoryApi()
          : ProduccionLecheRepositoryImpl();
  static Future<TratamientoRepository> get _tratamiento async =>
      await _isOnline()
          ? TratamientoRepositoryApi()
          : TratamientoRepositoryImpl();
  static Future<UserRepository> get _usuario async =>
      await _isOnline() ? UserRepositoryApi() : UserRepositoryImpl();
  static Future<UsuarioFincaRepository> get _usuarioFinca async =>
      await _isOnline()
          ? UsuarioFincaRepositoryApi()
          : UsuarioFincaRepositoryImpl();
  static Future<VacunaRepository> get _vacuna async =>
      await _isOnline() ? VacunaRepositoryApi() : VacunaRepositoryImpl();

  /// Lista de RepositoryProvider para MultiRepositoryProvider
  static Future<List<RepositoryProvider>> get providers async {
    final userRepo = await _usuario;
    final animalRepo = await _animal;
    final vacunaRepo = await _vacuna;
    final tratoRepo = await _tratamiento;
    final pesoRepo = await _peso;
    final prodRepo = await _produccion;
    final chequeoRepo = await _chequeo;
    final eventoRepo = await _evento;
    final farmRepo = await _farm;
    final usuarioFincaRepo = await _usuarioFinca;

    return [
      RepositoryProvider<UserRepository>.value(value: userRepo),
      RepositoryProvider<AnimalRepository>.value(value: animalRepo),
      RepositoryProvider<VacunaRepository>.value(value: vacunaRepo),
      RepositoryProvider<TratamientoRepository>.value(value: tratoRepo),
      RepositoryProvider<PesoRepository>.value(value: pesoRepo),
      RepositoryProvider<ProduccionLecheRepository>.value(value: prodRepo),
      RepositoryProvider<ChequeoSaludRepository>.value(value: chequeoRepo),
      RepositoryProvider<EventoReproductivoRepository>.value(value: eventoRepo),
      RepositoryProvider<FarmRepository>.value(value: farmRepo),
      RepositoryProvider<UsuarioFincaRepository>.value(value: usuarioFincaRepo),
    ];
  }

  /// Lista de BlocProvider para MultiBlocProvider
  static List<BlocProvider> get blocProviders => [
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
            create: (c) => ChequeoSaludBloc(c.read<ChequeoSaludRepository>())),
        BlocProvider(
            create: (c) =>
                EventoReproductivoBloc(c.read<EventoReproductivoRepository>())),
        BlocProvider(create: (c) => FarmBloc(c.read<FarmRepository>())),
        BlocProvider(
            create: (c) => UsuarioFincaBloc(c.read<UsuarioFincaRepository>())),
      ];
}
