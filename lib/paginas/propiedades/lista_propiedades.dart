import 'package:flutter/material.dart';
import 'package:obligatorio_flutter/daos/base_datos.dart';
import 'package:obligatorio_flutter/daos/dao_clientes.dart';
import 'package:obligatorio_flutter/daos/dao_propiedades.dart';
import 'package:obligatorio_flutter/daos/dao_tipos.dart';
import 'package:obligatorio_flutter/daos/dao_visitas.dart';
import 'package:obligatorio_flutter/utilidades/rutas/index_entidades.dart';
import 'package:obligatorio_flutter/utilidades/widgets/app_bar_generica.dart';
import 'package:obligatorio_flutter/utilidades/widgets/mensajes.dart';
import 'package:obligatorio_flutter/utilidades/widgets/menu_inicio.dart';

class ListaPropiedades extends StatefulWidget {
  const ListaPropiedades({super.key});

  @override
  State<ListaPropiedades> createState() => _ListaPropiedadesState();
}

class _ListaPropiedadesState extends State<ListaPropiedades> {
  bool _mostrarFiltros = false;
  late Cliente? _cliente;
  List<Cliente> _clientes = [];
  List<Visita> _visitas=[];
  late Tipo? _tipo;
  List<Propiedad> _propiedades = [];
  List<Propiedad> _propiedadesOriginal = [];
  Set<String> zonas = <String>{};
  List<String> ofertas = ['Todas','Venta', 'Alquiler'];

  final TextEditingController zonaController = TextEditingController();
  late String? selectedZona;
  late String? selectedOferta;

  final TextEditingController ofertaController = TextEditingController();

  final FocusNode _focusNode = FocusNode();


  @override
  void didChangeDependencies() async {
    selectedZona = null;
    selectedOferta = null;
    await DAOClientes().listarClientes().then((clientes) {
      setState(() {
        _clientes = clientes;
      });
    });
    await DAOPropiedades().listarPropiedades().then((propiedades) {
      setState(() {
        _propiedades = propiedades;
        _propiedadesOriginal = propiedades;
        for (Propiedad p in _propiedadesOriginal) {
          zonas.add(p.zona);
        }
      });
    });
    await DAOVisitas().listarVisitasTodas().then((value) {
      _visitas= value;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SafeArea(
        child: Drawer(child: MenuInicio()),
      ),
      appBar: const AppBarGenerica(titulo: 'Lista de Propiedades'),
      body: SafeArea(
        child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'imagenes/fondo_inmo.jpg',
                  ),
                  fit: BoxFit.cover),
            ),
            child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [     
              if(!_mostrarFiltros)...[
                    Expanded(                    
                child: Row(
                  children: [                  
                    TextButton(                                    
                      child:const Row(
                        children: [
                          Text('Filtrar', style: TextStyle(color: Color.fromARGB(255, 121, 104, 169), fontSize: 20),),
                          SizedBox(width: 10,),
                          Icon(Icons.filter_list, color: Color.fromARGB(255, 121, 104, 169),),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarFiltros = !_mostrarFiltros;
                        });
                        }, 
                      ),
                  ],
                ),
                ),
                  ],       
              if(_mostrarFiltros) ...[
                    Expanded(                    
                    flex: 1,
                      child: DropdownMenu(
                        width: 140,
                        controller: zonaController,          
                        label: const Text('Zona'),                                   
                        initialSelection: selectedZona,
                        onSelected: (String? selected) {
                          setState(() {
                            selectedZona = selected == 'Todas' ? null: selected;
                            actualizarLista(selectedZona, selectedOferta);
                            _focusNode.unfocus();
                          });
                        },
                        dropdownMenuEntries:['Todas', ...zonas]
                            .map<DropdownMenuEntry<String>>(
                              (String zona) => DropdownMenuEntry<String>(
                                value: zona,
                                label: zona,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    DropdownMenu(
                      width: 140,
                      controller: ofertaController,
                      label: const Text('Oferta'),
                      initialSelection: selectedOferta,
                      onSelected: (String? selected) {
                        setState(() {
                          selectedOferta = selected == 'Todas' ? null: selected;
                          actualizarLista(selectedZona, selectedOferta);
                          _focusNode.unfocus();
                        });
                      },
                      dropdownMenuEntries: ofertas
                          .map<DropdownMenuEntry<String>>(
                            (String zona) => DropdownMenuEntry<String>(
                              value: zona,
                              label: zona,
                            ),
                          )
                          .toList(),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarFiltros=false;
                            selectedOferta = null;
                            selectedZona = null;
                            zonaController.clear();
                            ofertaController.clear();
                            actualizarLista(selectedZona, selectedOferta);
                          });
                        },
                        icon: const Icon(Icons.close_outlined)),
                  ],
                  
            ],
                ),
        ),
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/agregar_propiedad'),
                  child: const Icon(Icons.add),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: DAOPropiedades().listarPropiedades(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasData) {
                            return snapshot.data!.isNotEmpty
                                ? ListView.separated(
                                    itemBuilder: (context, index) => Card(
                                      child: ListTile(
                                        onTap: () async {
                                          Cliente? c = await DAOClientes()
                                              .obtenerCliente(
                                                  _propiedades[index]
                                                      .clienteId);
                                          Tipo? t = await DAOTipos()
                                              .obtenerTipo(
                                                  _propiedades[index].tipoId);
                                          setState(() {
                                            _cliente = c;
                                            _tipo = t;
                                          });
                                          if (context.mounted) {
                                            mostrarPropiedadAlertDialog(
                                                context,
                                                _propiedades[index],
                                                _cliente!,
                                                _tipo!);
                                          }
                                        },
                                        title: Text(
                                            'Padron Nº: ${_propiedades[index].padron.toString()}'),
                                        subtitle: Text(
                                            'Direccion: ${_propiedades[index].direccion}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushNamed(
                                                        '/modificar_propiedad',
                                                        arguments:
                                                            _propiedades[index])
                                                    .then((value) {
                                                  setState(() {});
                                                });
                                              },
                                              icon: const Icon(Icons.edit),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {                                                  
                                                  mostrarEliminarPropiedad(
                                                      context, _propiedades[index]);
                                                });
                                              },
                                              icon: const Icon(Icons.delete),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 0),
                                    itemCount: _propiedades.length,
                                  )
                                : const Center(
                                    child: Text(
                                        'No existen propiedades en el sistema'),
                                  );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  '¡ERROR! No se pudo listar las propiedades'),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                      }
                    }),
              ),
            ])),
      ),
    );
  }

  void mostrarEliminarPropiedad(BuildContext context, Propiedad propiedad) {
        bool tieneVisitasProgramadas = _visitas.any((visita) => visita.propiedadId == propiedad.id);
        String mensaje = tieneVisitasProgramadas 
      ? '¿Desea eliminar la propiedad Numero de padron: ${propiedad.padron}?\nRecuerde que esta propiedad tiene visitas asignadas y las mismas serán eliminadas de su agenda.'
      : '¿Desea eliminar la propiedad Numero de padron: ${propiedad.padron}?';

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: const Text('Eliminar Propiedad'),
              content: Text(mensaje),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        DAOPropiedades().eliminarPropiedad(propiedad.id!);
                        _propiedades.remove(propiedad);
                        zonas.remove(propiedad.zona); 
                        eliminarPropiedadYActualizarLista(propiedad);                    
                      });
                      Navigator.of(context).pop();
                      Mensajes.mostrarSnackBar(
                        context, 'Propiedad Eliminada con Exito');
                    },
                    child: const Text('Si')),
              ],
            ));
  }

  void mostrarPropiedadAlertDialog(
      BuildContext context, Propiedad propiedad, Cliente cliente, Tipo tipo) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Padron Nº: ${propiedad.padron}'),
              content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tipo.nombre),
                      if (propiedad.alquila!)const Text('Alquila',),
                      if (propiedad.vende!) const Text('Vende'),
                      Text('Zona : ${propiedad.zona}'),
                      Text('Direccion: ${propiedad.direccion}'),
                      if (propiedad.precio != null && propiedad.vende!)
                        Text('Precio: u\$s ${propiedad.precio}'),
                      if (propiedad.precio != null && propiedad.alquila! && !propiedad.vende!)
                        Text('Precio: \$u ${propiedad.precio}'),
                      if (propiedad.superficie != null)
                        Text('Superficie: ${propiedad.superficie} m²'),
                      Text('Dueño:  ${cliente.nombre}'),
                    ]),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Aceptar'))
              ],
            ));
  }

  void mostrarClientes(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Center(
                child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView.separated(
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _cliente = _clientes[index];
                      Navigator.of(context).pop();
                    });
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(_clientes[index].id.toString()),
                      subtitle: Text(_clientes[index].nombre),
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => const Divider(height: 0),
                itemCount: _clientes.length,
              ),
            )));
  }

  @override
  void dispose() {
    BaseDatos().cerrarBaseDatos();
    super.dispose();
  }

  void eliminarPropiedadYActualizarLista(Propiedad propiedad) async {
    
    await DAOPropiedades().eliminarPropiedad(propiedad.id!);
    var propiedadesActualizadas = await DAOPropiedades().listarPropiedades();
    setState(() {
        _propiedades = propiedadesActualizadas;
        _propiedadesOriginal = propiedadesActualizadas;
        selectedOferta = null;
        selectedZona = null;
        _mostrarFiltros=false;
        zonaController.clear();
        ofertaController.clear();
        actualizarLista(selectedZona, selectedOferta); 
        actualizarZonas();
        actualizarLista(null, null);
        
    });
}
  void actualizarZonas() {
    Set<String> nuevasZonas = <String>{};
     for (Propiedad p in _propiedadesOriginal) {
        nuevasZonas.add(p.zona);
    }
    zonas = nuevasZonas;
}

  void actualizarLista(String? zona, String? tipoOferta) {
    List<Propiedad> listaAux = [];
    if (zona != null && tipoOferta != null) {
      //Si se filtra por ambos filtros
      if (tipoOferta == 'Venta') {
        //Cuando el tipo es venta
        for (Propiedad p in _propiedadesOriginal) {
          if (p.zona == zona && p.vende == true) {
            //Cargo todas las propiedades en venta en esa zona
            listaAux.add(p);
          }
        }
      }
      if (tipoOferta == 'Alquiler') {
        //Cuando el tipo es alquila
        for (Propiedad p in _propiedadesOriginal) {
          if (p.zona == zona && p.alquila == true) {
            //Cargo todas las propiedades en alquiler en esa zona
            listaAux.add(p);
          }
        }
      }
    } else if (zona != null && tipoOferta == null) {
      //Si solo filtra por zona
      for (Propiedad p in _propiedadesOriginal) {
        if (p.zona == zona) {
          listaAux.add(p);
        }
      }
    } else if (zona == null && tipoOferta != null) {
      //Si solo filtra por tipo de oferta
      if (tipoOferta == 'Venta') {
        //si se filtra por propiedades en venta
        for (Propiedad p in _propiedadesOriginal) {
          if (p.vende == true) {
            listaAux.add(p);
          }
        }
      }
      if (tipoOferta == 'Alquiler') {
        //si se filtra por propiedades en alquiler
        for (Propiedad p in _propiedadesOriginal) {
          if (p.alquila == true) {
            listaAux.add(p);
          }
        }
      }
    } else {
      //si no se aplica filtro
      listaAux = _propiedadesOriginal;
    }

    _propiedades = listaAux;
  }
}
