import 'dart:developer'; // ใช้สำหรับการบันทึกข้อมูลในคอนโซล
import 'package:cloud_firestore/cloud_firestore.dart'; // ใช้สำหรับการเข้าถึง Firebase Firestore
import 'package:collection/collection.dart'; // ใช้สำหรับการจัดกลุ่มข้อมูล
import 'package:firebase_auth/firebase_auth.dart'; // ใช้สำหรับการจัดการการตรวจสอบสิทธิ์ของผู้ใช้
import 'package:flutter/material.dart'; // ใช้สำหรับการสร้าง UI
import 'package:chat_bubbles/chat_bubbles.dart'; // ใช้สำหรับสร้าง UI ของ bubble แชท

// `ChatView` เป็น StatefulWidget ที่แสดงหน้าจอสำหรับการแชท
class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.chatId});

  // `chatId` คือรหัสของห้องแชทที่กำลังดูอยู่
  final String chatId;

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // การเข้าถึงคอลเลกชัน 'chats' ใน Firestore
  final chats = FirebaseFirestore.instance.collection('chats');

  // ฟังก์ชันสำหรับการส่งข้อความใหม่
  Future<void> _sendMessage(String message) async {
    final chatDoc = chats.doc(widget.chatId); // การเข้าถึงเอกสารแชทตาม `chatId`
    final user =
        FirebaseAuth.instance.currentUser; // รับข้อมูลผู้ใช้ที่ลงชื่อเข้าใช้

    try {
      // อัปเดตเอกสารแชทโดยเพิ่มข้อความใหม่ลงในฟิลด์ 'chats'
      await chatDoc.update({
        'chats': FieldValue.arrayUnion([
          {
            'message': message, // ข้อความที่ส่ง
            'timestamp': DateTime.now(), // เวลาและวันที่ปัจจุบัน
            'sender': user?.uid // UID ของผู้ส่งข้อความ
          }
        ])
      });
    } catch (e) {
      // หากเกิดข้อผิดพลาดในการส่งข้อความ
      log('Error sending message: $e'); // แสดงข้อผิดพลาดในคอนโซล
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('ไม่สามารถส่งข้อความได้ขณะนี้'))); // แสดงแถบข้อความแจ้งเตือน
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"), // ชื่อแถบด้านบน
        leading: const BackButton(), // ปุ่มย้อนกลับ
        backgroundColor: const Color(0xffFC6011), // สีพื้นหลังของแถบด้านบน
        foregroundColor: Colors.white, // สีข้อความในแถบด้านบน
        elevation: 0, // การยกของแถบด้านบน
        centerTitle: true, // จัดตำแหน่งข้อความกลาง
      ),
      body: Stack(
        children: [
          // ใช้ SingleChildScrollView เพื่อให้สามารถเลื่อนดูข้อความได้
          SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: StreamBuilder<DocumentSnapshot>(
                // ใช้ StreamBuilder เพื่อฟังการเปลี่ยนแปลงของเอกสารแชท
                stream: chats.doc(widget.chatId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                        'Something went wrong'); // แสดงข้อความเมื่อเกิดข้อผิดพลาด
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading"); // แสดงข้อความขณะรอข้อมูล
                  }

                  final data = snapshot.data?.data() as Map<String, dynamic>?;

                  // ตรวจสอบว่ามีข้อมูลใน 'chats' หรือไม่
                  List chatList = [];
                  if (data != null && data.containsKey('chats')) {
                    chatList = data['chats'];
                  }

                  List<Widget> chatListGroup = [];
                  // ใช้ groupBy เพื่อจัดกลุ่มข้อความตามวันที่
                  var groupByDate = groupBy(chatList, (obj) {
                    return obj['timestamp']
                        .toDate()
                        .toIso8601String()
                        .split('T')[0];
                  });

                  final uid = FirebaseAuth.instance.currentUser?.uid;

                  groupByDate.forEach((date, list) {
                    DateTime dateParsed = DateTime.parse(date);
                    chatListGroup.add(
                        DateChip(date: dateParsed)); // เพิ่มชิปวันที่ลงในรายการ

                    list.forEach((e) {
                      chatListGroup.add(BubbleNormal(
                        text: e['message'], // ข้อความที่แสดง
                        isSender: e['sender'] ==
                            uid, // ตรวจสอบว่าผู้ส่งข้อความเป็นผู้ใช้ปัจจุบันหรือไม่
                        color: e['sender'] != uid
                            ? const Color(
                                0xFF1B97F3) // สีของข้อความสำหรับผู้ส่งข้อความอื่น
                            : Colors.grey, // สีของข้อความสำหรับผู้ใช้ปัจจุบัน
                        tail: true, // เพิ่มหางที่ปลายของข้อความ
                        textStyle: TextStyle(
                            color: e['sender'] != uid
                                ? Colors.white
                                : const Color.fromARGB(255, 16, 12, 12),
                            fontSize: 18),
                      ));
                    });
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        chatListGroup, // แสดงรายการข้อความที่จัดกลุ่มตามวันที่
                  );
                },
              )),
          // แถบข้อความที่ใช้ในการส่งข้อความ
          MessageBar(
            onSend: (message) =>
                _sendMessage(message), // ส่งข้อความเมื่อปุ่มส่งถูกกด
          ),
        ],
      ),
    );
  }
}
