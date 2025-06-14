import 'package:chatapp/constatns/constats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String reciverId;
  final String message;
  final Timestamp timestamp;
  Message({
    required this.senderId,
    required this.senderEmail,
    required this.reciverId,
    required this.message,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      constatns.senderId: senderId,
      constatns.senderEmail: senderEmail,
      constatns.reciverId: reciverId,
      constatns.message: message,
      constatns.timestamp: timestamp
    };
  }
}
