# IDEA GENERAL
Una inmobiliaria le ha encomendado a su equipo, el desarrollo de una app móvil multiplataforma
(Android y iOS) para gestionar las propiedades que sus agentes administran, sus clientes (que ofrecen
y/o buscan propiedades), y una agenda de visitas que los clientes interesados pueden solicitarle al agente
para ver las propiedades personalmente.

# DESCRIPCIÓN DEL PROBLEMA
Observación: Los campos marcados en negrita son obligatorios, mientras que los demás son opcionales.
La aplicación debe permitir registrar los clientes con los que el agente trabaja. De éstos se debe registrar
un id autogenerado, su nombre completo, y un teléfono de contacto. Será posible agregarlos,
modificarlos y eliminarlos (sólo si no tienen propiedades vinculadas o visitas agendadas). Los clientes se
podrán listar, y buscar por su nombre.
También se podrán agregar, modificar y eliminar las propiedades manejadas por el agente (si la propiedad
tiene visitas agendadas, éstas también deberán eliminarse al eliminar la propiedad, mostrando previamente
una advertencia).
Cada propiedad tiene número de padrón que la identifica, tipo (casa, apartamento, terreno, etc.), zona,
dirección, superficie, tipo de oferta (alquiler / venta o ambas), precio en dólares, el cliente que la ofrece.
Las propiedades se podrán listar y buscar por zona y/o tipo de oferta.

#
Los tipos de propiedad (id autogenerado, y nombre) también deben poder agregarse, modificarse y
eliminarse (con baja lógica si tienen propiedades vinculadas).
Los clientes pueden pedirle al agente visitar alguna propiedad, por lo que la aplicación deberá disponer
de una agenda de visitas. Cada visita se identifica con un id autogenerado, y debe indicar el cliente
interesado, la propiedad que desea visitar, una fecha, y una hora. Las visitas podrán ser modificadas
(sólo su fecha y/u hora) o marcadas como canceladas sin perder su información.
La aplicación debe comenzar con una pantalla que muestre las visitas agendadas para la fecha actual (por
defecto) o las de cualquier otra fecha (seleccionándola mediante un calendario). Desde esta pantalla inicial
se podrá navegar hacia las demás funcionalidades de la aplicación de manera intuitiva a través de un menú
de opciones. Desde cualquier pantalla debe ser posible volver a la pantalla inicial con un solo toque.
