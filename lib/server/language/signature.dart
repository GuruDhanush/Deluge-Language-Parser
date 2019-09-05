
import 'package:json_rpc_2/json_rpc_2.dart';

class SignatureProvider {

  static register(Peer peer) {
    throw Exception('not implemented!');
    peer.registerMethod('textDocument/signatureHelp', onSignatureHelp);
  }

  static onSignatureHelp(Parameters param) {

    //Message.sendMessageNotif(MessageType.info, param.toString());
  } 
}