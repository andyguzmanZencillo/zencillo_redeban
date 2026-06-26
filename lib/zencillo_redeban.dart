import 'package:oxidized/oxidized.dart';
import 'package:zencillo_helpers/zencillo_helpers.dart';
import 'package:zencillo_redeban/map/map.dart';

import 'models/redeban_response.dart';
import 'zencillo_redeban_platform_interface.dart';

class ZencilloRedeban {
  Future<String?> getPlatformVersion() {
    return ZencilloRedebanPlatform.instance.getPlatformVersion();
  }

  Future<Result<RedebanResponse, String>> redebanPay({
    required String amount,
    required String tax,
  }) {
    return ZencilloRedebanPlatform.instance.redeban(
      amount: amount,
      tax: tax,
    );
  }

  Future<Result<FormaPagoDetalleModel, String>> redebanPayFull({
    required int idTurno,
    required int numeroTurno,
    required int idDocument,
    required double total,
    required double taxTotal,
    required double subTotal,
    required int idFormaPago,
  }) async {
    final result = await ZencilloRedebanPlatform.instance.redeban(
      amount: total.toString(),
      tax: taxTotal.toString(),
    );
    if (result.isErr()) {
      return Err(result.unwrapErr());
    }
    final data = result.unwrap();
    return Ok(data.toFormaPagoDetalle(
      idTurno: idTurno,
      numeroTurno: numeroTurno,
      idDocument: idDocument,
      total: total,
      taxTotal: taxTotal,
      subTotal: subTotal,
      idFormaPago: idFormaPago,
    ));
  }

  Future<Result<FormaPagoDetalleModel, String>> redebanPayComplete({
    required double total,
    required double subTotal,
    required double taxTotal,
  }) async {
    final result = await ZencilloRedebanPlatform.instance.redeban(
      amount: total.toString(),
      tax: taxTotal.toString(),
    );
    if (result.isErr()) {
      return Err(result.unwrapErr());
    }
    final data = result.unwrap();
    return Ok(data.toFormaPagoDetalle(
      idTurno: 0,
      numeroTurno: 0,
      idDocument: 0,
      total: total,
      taxTotal: taxTotal,
      subTotal: subTotal,
      idFormaPago: 0,
    ));
  }

  Future<Result<RedebanResponse, String>> redebanAnulacion({
    required String numeroRecibo,
    required String claveSupervisor,
  }) {
    return ZencilloRedebanPlatform.instance.redebanAnulacion(
      numeroRecibo: numeroRecibo,
      claveSupervisor: claveSupervisor,
    );
  }
}
