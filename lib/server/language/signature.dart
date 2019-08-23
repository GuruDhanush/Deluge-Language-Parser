
import 'package:DelugeDartParser/server/messaging/message.dart';
import 'package:json_rpc_2/json_rpc_2.dart';

class SignatureProvider {

  static register(Peer peer) {

    peer.registerMethod('textDocument/signatureHelp', onSignatureHelp);
  }

  static onSignatureHelp(Parameters param) {

    Message.sendMessageNotif(MessageType.info, param.toString());
  } 
}