import 'package:oxidized/oxidized.dart';

import 'models/redeban_response.dart';
import 'zencillo_redeban_platform_interface.dart';

class ZencilloRedeban {
  Future<String?> getPlatformVersion() {
    return ZencilloRedebanPlatform.instance.getPlatformVersion();
  }

  Future<Result<RedebanResponse, String>> redeban({
    required String amount,
    required String tax,
  }) {
    return ZencilloRedebanPlatform.instance.redeban(
      amount: amount,
      tax: tax,
    );
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
