import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oxidized/oxidized.dart';

import 'models/redeban_response.dart';
import 'zencillo_redeban_platform_interface.dart';

/// An implementation of [ZencilloRedebanPlatform] that uses method channels.
class MethodChannelZencilloRedeban extends ZencilloRedebanPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('zencillo_redeban');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Result<RedebanResponse, String>> redeban({
    required String amount,
    required String tax,
    int? inc,
    int? montoBaseIva,
    int? montoBaseInc,
    int? baseDevolucion,
  }) async {
    try {
      final arguments = <String, dynamic>{
        'amount': amount,
        'tax': tax,
      };
      if (inc != null) {
        arguments['inc'] = inc;
      }
      if (montoBaseIva != null) {
        arguments['montoBaseIva'] = montoBaseIva;
      }
      if (montoBaseInc != null) {
        arguments['montoBaseInc'] = montoBaseInc;
      }
      if (baseDevolucion != null) {
        arguments['baseDevolucion'] = baseDevolucion;
      }

      final response = await methodChannel.invokeMethod<String>(
        'redeban',
        arguments,
      );

      if (response == null || response.trim().isEmpty) {
        return const Result.err('No se recibió respuesta del método redeban');
      }

      final jsonString = limpiarJson(response);
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return const Result.err('Respuesta con formato inválido.');
      }

      final operacion = RedebanResponse.fromJson(decoded);

      return _evaluarRespuestaRedeban(operacion);
    } on PlatformException catch (e) {
      return Result.err(e.message ?? 'Error de plataforma.');
    } catch (e, stacktrace) {
      log('REDEBAN PAYMENT FAILED ===> $e');
      log('REDEBAN PAYMENT FAILED ===> $stacktrace');
      return const Result.err('Algo falló!');
    }
  }

  @override
  Future<Result<RedebanResponse, String>> redebanAnulacion({
    required String numeroRecibo,
    required String claveSupervisor,
  }) async {
    try {
      final response = await methodChannel.invokeMethod<String>(
        'redebanAnulacion',
        {
          'numeroRecibo': numeroRecibo,
          'claveSupervisor': claveSupervisor,
        },
      );

      if (response == null || response.trim().isEmpty) {
        return const Result.err(
          'No se recibió respuesta del método redebanAnulacion',
        );
      }

      final jsonString = limpiarJson(response);
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return const Result.err('Respuesta con formato inválido.');
      }

      final operacion = RedebanResponse.fromJson(decoded);

      return _evaluarRespuestaRedeban(operacion);
    } on PlatformException catch (e) {
      return Result.err(e.message ?? 'Error de plataforma.');
    } catch (e, stacktrace) {
      log('REDEBAN ANULACION FAILED ===> $e');
      log('REDEBAN ANULACION FAILED ===> $stacktrace');
      return const Result.err('Algo falló!');
    }
  }

  /// Solo `Codigo_respuesta` == `00` se considera transacción aprobada.
  Result<RedebanResponse, String> _evaluarRespuestaRedeban(
    RedebanResponse operacion,
  ) {
    final codigo = operacion.codigoRespuesta.trim();

    if (codigo == '00') {
      return Result.ok(operacion);
    }

    final mensaje = operacion.mensajeError.trim();
    if (mensaje.isNotEmpty) {
      return Result.err(mensaje);
    }

    if (codigo.isNotEmpty) {
      return Result.err('Transacción rechazada (código $codigo).');
    }

    return const Result.err('Transacción rechazada.');
  }

  String limpiarJson(String entrada) {
    final claveValor = RegExp(r'(\w+):');

    var corregido = entrada
        .replaceAllMapped(
          claveValor,
          (m) => '"${m[1]}":',
        )
        .replaceAll("'", '"')
        .replaceAll(RegExp(r':\s*}'), ': ""}');

    if (!corregido.trim().startsWith('{')) {
      corregido = '{$corregido';
    }

    if (!corregido.trim().endsWith('}')) {
      corregido = '$corregido}';
    }

    return corregido;
  }
}
