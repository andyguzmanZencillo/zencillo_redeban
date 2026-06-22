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
  }) async {
    try {
      final response = await methodChannel.invokeMethod<String>(
        'redeban',
        {
          'amount': amount,
          'tax': tax,
        },
      );

      if (response == null) {
        return const Result.err('No se recibió respuesta del método redeban');
      }

      final jsonString = limpiarJson(response);
      final jsonMap = jsonDecode(jsonString);

      final operacion = RedebanResponse.fromJson(
        jsonMap as Map<String, dynamic>,
      );

      if (operacion.codigoRespuesta == '86' ||
          int.parse(operacion.codigoRespuesta) < 0) {
        return Result.err(operacion.mensajeError);
      }

      return Result.ok(operacion);
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

      if (response == null) {
        return const Result.err(
          'No se recibió respuesta del método redebanAnulacion',
        );
      }

      final jsonString = limpiarJson(response);
      final jsonMap = jsonDecode(jsonString);

      final operacion = RedebanResponse.fromJson(
        jsonMap as Map<String, dynamic>,
      );

      if (operacion.codigoRespuesta == '86' ||
          int.parse(operacion.codigoRespuesta) < 0) {
        return Result.err(operacion.mensajeError);
      }

      return Result.ok(operacion);
    } on PlatformException catch (e) {
      return Result.err(e.message ?? 'Error de plataforma.');
    } catch (e, stacktrace) {
      log('REDEBAN ANULACION FAILED ===> $e');
      log('REDEBAN ANULACION FAILED ===> $stacktrace');
      return const Result.err('Algo falló!');
    }
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
