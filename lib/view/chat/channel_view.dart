import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pettakecare/view/chat/chat_view.dart';

class ChannelView extends StatefulWidget {
  const ChannelView({Key? key}) : super(key: key);

  @override
  _ChannelViewState createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  // อ้างอิงไปยังคอลเล็กชันต่าง ๆ ใน Firestore
  final chats = FirebaseFirestore.instance.collection('chats');
  final books = FirebaseFirestore.instance.collection('books');
  final users = FirebaseFirestore.instance.collection('users');
  final sitters = FirebaseFirestore.instance.collection('sitters');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'), // ชื่อแอปบาร์
        backgroundColor: Color(0xffFC6011), // สีพื้นหลังของแอปบาร์
        foregroundColor: Colors.white, // สีข้อความบนแอปบาร์
        elevation: 0, // ความสูงของเงา
        centerTitle: true, // จัดข้อความกลาง
      ),
      body: Container(
        padding: const EdgeInsets.only(
            top: 10, bottom: 10), // การเว้นระยะภายใน Container
        child: StreamBuilder<QuerySnapshot>(
          stream: books
              .where('status', whereIn: [
                'paid',
                'matched'
              ]) // เลือกเอกสารที่สถานะเป็น 'paid'
              .where(Filter.or(
                  Filter('user_id',
                      isEqualTo:
                          FirebaseAuth.instance.currentUser?.uid), // หรือ
                  Filter('sitter_id',
                      isEqualTo: FirebaseAuth.instance.currentUser
                          ?.uid))) // ตรวจสอบว่าผู้ใช้หรือผู้ดูแลเป็นเจ้าของการจอง
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                  'Something went wrong'); // แสดงข้อความเมื่อเกิดข้อผิดพลาด
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // แสดงตัวโหลดข้อมูลขณะรอ
            }

            return ListView.builder(
              itemCount: snapshot.data?.docs.length, // จำนวนเอกสารในผลลัพธ์
              itemBuilder: (context, index) {
                final bookDoc = snapshot.data?.docs[index]; // เอกสารการจอง
                final book = bookDoc!.data() as Map; // ข้อมูลของการจอง

                return Expanded(
                  child: StreamBuilder(
                    stream: chats
                        .where('book_id',
                            isEqualTo:
                                bookDoc.id) // ดึงข้อมูลแชทที่ตรงกับ book_id
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                            'Something went wrong'); // ข้อความข้อผิดพลาด
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('...'); // ข้อความระหว่างรอข้อมูล
                      }

                      final chat = snapshot.data?.docs; // ข้อมูลแชท

                      if (chat!.isEmpty) {
                        return Container(); // หากไม่มีข้อมูลแชท ให้แสดง Container ว่าง
                      }

                      return Card(
                        child: InkWell(
                          splashColor: Colors.amber, // สีพื้นหลังเมื่อสัมผัส
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatView(
                                    chatId: snapshot.data!.docs.first
                                        .id), // ไปยังหน้าต่าง ChatView
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(
                                10), // การเว้นระยะภายใน Container
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // จัดแนวเนื้อหากลาง
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // จัดเนื้อหาแนวกลาง
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // จัดแนวแนวตั้งกลาง
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          30), // มุมโค้งมนของภาพ
                                      child: Container(
                                          width: 60, // ความกว้างของภาพ
                                          height: 60, // ความสูงของภาพ
                                          color: Colors
                                              .blueGrey, // สีพื้นหลังของภาพ
                                          child: Image.asset(
                                            'assets/img/app_logo.png', // ภาพที่ใช้
                                            fit: BoxFit
                                                .cover, // การครอบภาพให้เต็มพื้นที่
                                          )),
                                    ),
                                    const SizedBox(
                                        width:
                                            20), // การเว้นระยะระหว่างภาพและเนื้อหา
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // จัดเนื้อหาทางซ้าย
                                      children: [
                                        Row(
                                          children: [
                                            FutureBuilder(
                                              future: users
                                                  .doc(book['user_id'])
                                                  .get(), // ดึงข้อมูลผู้ใช้จาก Firestore
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Text(
                                                      ''); // ข้อความว่างขณะรอข้อมูล
                                                }

                                                if (!snapshot.data!.exists) {
                                                  return const Text(
                                                      ''); // ข้อความว่างหากเอกสารไม่พบ
                                                }

                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  final user = snapshot.data
                                                      ?.data() as Map;
                                                  final name =
                                                      user.containsKey('name')
                                                          ? user['name']
                                                          : ''; // ดึงชื่อผู้ใช้
                                                  return Text('ชื่อลูกค้า: ' +
                                                      name); // แสดงชื่อผู้ใช้
                                                }

                                                return Text(
                                                    ''); // ข้อความว่างขณะรอข้อมูล
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            FutureBuilder(
                                              future: sitters
                                                  .doc(bookDoc.get('sitter_id'))
                                                  .get(), // ดึงข้อมูลผู้ดูแลจาก Firestore
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return const Text(
                                                      ''); // ข้อความว่างหากเกิดข้อผิดพลาด
                                                }

                                                if (snapshot.hasData &&
                                                    !snapshot.data!.exists) {
                                                  return const Text(
                                                      ''); // ข้อความว่างหากเอกสารไม่พบ
                                                }

                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  final sitter = snapshot.data
                                                      ?.data() as Map;
                                                  final name = sitter
                                                          .containsKey('name')
                                                      ? sitter['name']
                                                      : ''; // ดึงชื่อผู้ดูแล
                                                  return Text(
                                                      'ชื่อผู้รับเลี้ยง: ' +
                                                          name); // แสดงชื่อผู้ดูแล
                                                }

                                                return const Text(
                                                    ''); // ข้อความว่างขณะรอข้อมูล
                                              },
                                            ),
                                          ],
                                        ),
                                        Text('ฝากเลี้ยงน้อง: ' +
                                                (book['pet_name'] ?? '')
                                                    .toString() ??
                                            'ไม่ระบุ'), // แสดงชื่อสัตว์เลี้ยง
                                        Text('โรคประจำตัวสัตว์เลี้ยง: ' +
                                            (book['pet_disease'] ?? '')
                                                .toString()), // แสดงโรคประจำตัว
                                        Text('จำนวนวัน: ' +
                                            (book['day'] ?? '')
                                                .toString()), // แสดงจำนวนวัน
                                        Text('จำนวนสัตว์เลี้ยง: ' +
                                            (book['pets'] ?? '')
                                                .toString()), // แสดงจำนวนสัตว์เลี้ยง
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// class ChatBubble extends StatelessWidget {
//   final String message;

//   const ChatBubble({Key? key, required this.message}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(message),
//     );
//   }
// }
