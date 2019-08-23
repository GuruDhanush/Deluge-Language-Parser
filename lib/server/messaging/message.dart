
import 'package:json_rpc_2/json_rpc_2.dart';


class Message {

  static Peer _peer;

  static registerMessage(Peer peer){
    _peer = peer;
  }


  ///Sent from server to client to show a certain message to user.
  ///No response will comeback. Look at [sendMessageRequest] for 
  ///getting an response from a client
  static sendMessageNotif(MessageType type, String message) {

    var params = ShowMessageParams(type: type, message: message);
    //no response is expected
    _peer.sendNotification('window/showMessage',  params.toJson());
  } 

  ///Sent from server to client, to show a certain message to user. Also 
  ///allows to send actions which the user can respond. If no response is 
  ///needed look at [sendMessageNotif]
  static Future<dynamic> sendMessageRequest(MessageType type, String message, List<MessageActionItem> actions ) {

    var params = ShowMessageRequestParams(type: type, message: message, actions: actions);
    return _peer.sendRequest('window/showMessageRequest', params.toJson());

  }

  /// a log message sent from server to client
  static sendLogMessage(MessageType type, String message) {
    var params = LogMessageParams(type: type, message: message);

    _peer.sendNotification('window/logMessage', params.toJson());
  }
}


class LogMessageParams {
  MessageType type;
  String message;

  LogMessageParams({this.type, this.message});

  Map toJson() => {
    // as the dart enum starts from 0, and lsp implementation starts from 1
    'type': type.index + 1,
    'message': message
  };
}

class MessageActionItem {
  String title;

  MessageActionItem({this.title});

  Map toJson() => { 'title': title };

}

class ShowMessageRequestParams {
  MessageType type;
  String message;
  List<MessageActionItem> actions;

  ShowMessageRequestParams({this.type, this.message, this.actions});

  Map toJson() => {
     // as the dart enum starts from 0, and lsp implementation starts from 1
    'type': type.index + 1,
    'message': message,
    'actions': List.generate(actions.length, (_) => actions[_].toJson())
  };

  
}

///Message type to be sent, to the client
enum MessageType {
  error,
  warning,
  info,
  log
}


class ShowMessageParams {

  MessageType type;
  String message;

  ShowMessageParams({this.type, this.message});

  Map toJson() => {
    // as the dart enum starts from 0, and lsp implementation starts from 1
    'type': type.index + 1,
    'message': message
  };

}
