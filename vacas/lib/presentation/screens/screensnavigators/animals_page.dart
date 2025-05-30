// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/entities/animal.dart';
import 'package:vacas/presentation/screens/screensnavigators/detalle_animal_page.dart';
import 'package:vacas/styles/card_animal.dart';
import 'package:vacas/styles/custome.dart';
import '../../../application/bloc/animal/animal_bloc.dart';
import '../../../application/bloc/animal/animal_event.dart';
import '../../../application/bloc/animal/animal_state.dart';

class AnimalesPage extends StatefulWidget {
  const AnimalesPage({super.key});

  @override
  State<AnimalesPage> createState() => _AnimalesPageState();
}

class _AnimalesPageState extends State<AnimalesPage> {
  List<Animal> animales = [];
  List<Animal> machos = [];
  List<Animal> hembras = [];
  int totalMachos = 0;
  int totalHembras = 0;
  String? localFotoUrl;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    final usuario = await SessionService.getUsuario();
    final farmId = await SessionService.getFincaSeleccionada();

    if (usuario != null && farmId != null) {
      context.read<AnimalBloc>().add(CargarAnimales(farmId));
    }
  }

  void _actualizarContadores(List<Animal> lista) {
    animales = lista;
    machos = lista.where((a) => a.tipo == 'Macho').toList();
    hembras = lista.where((a) => a.tipo == 'Hembra').toList();
    totalMachos = machos.length;
    totalHembras = hembras.length;
  }

  DropdownMenuItem<String> buildAnimalDropdownItem(String id, String nombre) {
    final shortId = id.substring(0, 8);
    final label = nombre.isNotEmpty ? '$nombre - $shortId' : shortId;
    return DropdownMenuItem(value: id, child: Text(label));
  }

  Future<void> seleccionarImagen(
      Function(File imagen, String localPath) onSeleccionado) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      onSeleccionado(file, picked.path);
    }
  }

  Future<void> _mostrarFormularioCrear() async {
    final nombreController = TextEditingController();
    final ganaderiaController = TextEditingController();
    final corralController = TextEditingController();
    final numAnimalController = TextEditingController();
    final codigoController = TextEditingController();
    final razaController = TextEditingController();
    final propositoController = TextEditingController();
    final pesoNacimientoController = TextEditingController();
    final fechaController = TextEditingController();
    final padreManualController = TextEditingController();
    final madreManualController = TextEditingController();

    String? padreSeleccionado;
    String? madreSeleccionada;
    DateTime? fechaNacimiento;
    bool isMacho = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("Nuevo Animal",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await seleccionarImagen((file, path) {
                          setModalState(() {
                            this.localFotoUrl = path;
                          });
                        });
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Seleccionar imagen"),
                    ),
                    if (this.localFotoUrl != null)
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                FileImage(File(this.localFotoUrl!)),
                          ),
                          TextButton.icon(
                            onPressed: () => setModalState(() {
                              this.localFotoUrl = null;
                            }),
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.red),
                            label: const Text('Quitar imagen'),
                          ),
                        ],
                      ),
                    _buildRadioSexo(setModalState, isMacho, (v) => isMacho = v),
                    _input(nombreController, 'Nombre'),
                    _input(ganaderiaController, 'Ganadería'),
                    _input(corralController, 'Corral'),
                    _input(numAnimalController, 'Número Animal'),
                    _input(codigoController, 'Código Referencia'),
                    _input(razaController, 'Raza'),
                    _input(propositoController, 'Propósito'),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            fechaNacimiento = picked;
                            fechaController.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: _input(fechaController, 'Fecha de nacimiento'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    machos.isEmpty
                        ? _input(padreManualController, 'Nombre del padre')
                        : DropdownButtonFormField<String>(
                            decoration: customInputDecoration('ID Padre'),
                            value: padreSeleccionado,
                            items: machos
                                .map((a) =>
                                    buildAnimalDropdownItem(a.id, a.nombre))
                                .toList(),
                            hint: const Text('Selecciona un padre'),
                            onChanged: (v) =>
                                setModalState(() => padreSeleccionado = v),
                          ),
                    hembras.isEmpty
                        ? _input(madreManualController, 'Nombre de la madre')
                        : DropdownButtonFormField<String>(
                            decoration: customInputDecoration('ID Madre'),
                            value: madreSeleccionada,
                            items: hembras
                                .map((a) =>
                                    buildAnimalDropdownItem(a.id, a.nombre))
                                .toList(),
                            hint: const Text('Selecciona una madre'),
                            onChanged: (v) =>
                                setModalState(() => madreSeleccionada = v),
                          ),
                    _input(pesoNacimientoController, 'Peso nacimiento (kg)',
                        TextInputType.number),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final usuario = await SessionService.getUsuario();
                        final farmId =
                            await SessionService.getFincaSeleccionada();
                        if (usuario == null ||
                            farmId == null ||
                            fechaNacimiento == null) return;

                        final animalId = const Uuid().v4();
                        final nuevo = Animal(
                          id: animalId,
                          farmId: farmId,
                          nombre: nombreController.text,
                          tipo: isMacho ? 'Macho' : 'Hembra',
                          raza: razaController.text,
                          proposito: propositoController.text,
                          ganaderia: ganaderiaController.text,
                          corral: corralController.text,
                          numAnimal: numAnimalController.text,
                          codigoReferencia: codigoController.text,
                          fechaNacimiento: fechaNacimiento!,
                          pesoNacimiento:
                              double.tryParse(pesoNacimientoController.text) ??
                                  0,
                          padreId: padreSeleccionado,
                          madreId: madreSeleccionada,
                          createdBy: usuario.id,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        context.read<AnimalBloc>().add(AgregarAnimal(nuevo));

                        Future.delayed(const Duration(seconds: 1));

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Animal guardado correctamente.')),
                        );
                      },
                      child: const Text("Guardar"),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _input(TextEditingController controller, String label,
      [TextInputType tipo = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        decoration: customInputDecoration(label),
      ),
    );
  }

  Widget _buildCounter(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text('$count', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRadioSexo(
      StateSetter setModalState, bool isMacho, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio(
            value: true,
            groupValue: isMacho,
            onChanged: (value) => setModalState(() => onChanged(true))),
        const Text('Macho'),
        Radio(
            value: false,
            groupValue: isMacho,
            onChanged: (value) => setModalState(() => onChanged(false))),
        const Text('Hembra'),
      ],
    );
  }

  Widget buildFotoAnimal(Animal animal) {
    final local = animal.localFotoUrl;
    final remote = animal.fotoUrl;

    if (local != null && File(local).existsSync()) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(local)),
      );
    } else if (remote != null && remote.isNotEmpty) {
      final fullUrl = '${ApiConstants.baseUrl}$remote';
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(fullUrl),
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.image_not_supported),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimalBloc, AnimalState>(
      listener: (context, state) async {
        if (state is AnimalAgregadoConExito && localFotoUrl != null) {
          final File imagen = File(localFotoUrl!);
          context.read<AnimalBloc>().add(
                ActualizarFotoAnimal(state.animal.id, imagen),
              );
          localFotoUrl = null;
        }
      },
      child: Scaffold(
        body: BlocBuilder<AnimalBloc, AnimalState>(
          builder: (context, state) {
            if (state is AnimalCargando) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnimalesCargados) {
              _actualizarContadores(state.animales);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCounter('Machos', totalMachos, Colors.blue),
                        _buildCounter('Hembras', totalHembras, Colors.pink),
                        _buildCounter('Total', animales.length, Colors.green),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: animales.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleAnimalPage(animal: animales[i]),
                          ),
                        ),
                        child: AnimalCard(animal: animales[i]),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is AnimalError) {
              return Center(child: Text(state.mensaje));
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarFormularioCrear,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
