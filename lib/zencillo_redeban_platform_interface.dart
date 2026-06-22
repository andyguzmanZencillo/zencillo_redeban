import 'package:oxidized/oxidized.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/redeban_response.dart';
import 'zencillo_redeban_method_channel.dart';

abstract class ZencilloRedebanPlatform extends PlatformInterface {
  ZencilloRedebanPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZencilloRedebanPlatform _instance = MethodChannelZencilloRedeban();

  static ZencilloRedebanPlatform get instance => _instance;

  static set instance(ZencilloRedebanPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Result<RedebanResponse, String>> redeban({
    required String amount,
    required String tax,
  }) {
    throw UnimplementedError('redeban() has not been implemented.');
  }

  Future<Result<RedebanResponse, String>> redebanAnulacion({
    required String numeroRecibo,
    required String claveSupervisor,
  }) {
    throw UnimplementedError('redebanAnulacion() has not been implemented.');
  }
}
