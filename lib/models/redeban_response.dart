import 'package:zencillo_helpers/zencillo_helpers.dart';

class RedebanResponse {
  RedebanResponse({
    required this.bin,
    required this.codigoRespuesta,
    required this.comercio,
    required this.direccion,
    required this.fechaHora,
    required this.franquicia,
    required this.mensajeError,
    required this.numeroConfirmacion,
    required this.numeroCuotas,
    required this.numeroRecibo,
    required this.rrn,
    required this.tipoCuenta,
    required this.tipoMedioPago,
    required this.tipoOperacion,
    required this.ultimosDigitosTarjeta,
    required this.data,
  });

  RedebanResponse.empty()
      : this(
          bin: 0,
          codigoRespuesta: '',
          comercio: '',
          direccion: '',
          fechaHora: '',
          franquicia: '',
          mensajeError: '',
          numeroConfirmacion: '',
          numeroCuotas: '',
          numeroRecibo: '',
          rrn: '',
          tipoCuenta: '',
          tipoMedioPago: '',
          tipoOperacion: '',
          ultimosDigitosTarjeta: '',
          data: '',
        );

  RedebanResponse.fromJson(Map<String, dynamic> json)
      : bin = json.getPro('Bin', 0),
        codigoRespuesta = json.getPro('Codigo_respuesta', ''),
        comercio = json.getPro('Comercio', ''),
        direccion = json.getPro('Direccion', ''),
        fechaHora = json.getPro('Fecha_hora', ''),
        franquicia = json.getPro('Franquicia', ''),
        mensajeError = json.getPro('Mensaje_error', ''),
        numeroConfirmacion = json.getPro('Numero_confirmacion', ''),
        numeroCuotas = json.getPro('Numero_cuotas', ''),
        numeroRecibo = json.getPro('Numero_recibo', ''),
        rrn = json.getPro('RRN', ''),
        tipoCuenta = json.getPro('Tipo_cuenta', ''),
        tipoMedioPago = json.getPro('Tipo_medio_Pago', ''),
        tipoOperacion = json.getPro('Tipo_operacion', ''),
        ultimosDigitosTarjeta = json.getPro('Ultimos_digitos_tarjeta', ''),
        data = json.toString();

  final int bin;
  final String codigoRespuesta;
  final String comercio;
  final String direccion;
  final String fechaHora;
  final String franquicia;
  final String mensajeError;
  final String numeroConfirmacion;
  final String numeroCuotas;
  final String numeroRecibo;
  final String rrn;
  final String tipoCuenta;
  final String tipoMedioPago;
  final String tipoOperacion;
  final String ultimosDigitosTarjeta;

  final String data;
}
