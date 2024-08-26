import 'dart:async'; // ใช้สำหรับจัดการ Timer
import 'dart:developer'; // ใช้สำหรับบันทึก log

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // ใช้สำหรับสร้าง UI ของแอปพลิเคชัน
import 'package:flutter_spinkit/flutter_spinkit.dart'; // ใช้สำหรับแสดง spinner
import 'package:cloud_firestore/cloud_firestore.dart'; // ใช้สำหรับการเชื่อมต่อกับ Firebase Firestore
import 'package:pettakecare/common/consts.dart'; // ใช้สำหรับค่าคงที่ (constants)
import 'package:pettakecare/view/chat/channel_view.dart';
import 'package:pettakecare/view/chat/chat_view.dart';
import 'package:pettakecare/view/pay_view/payment_view.dart'; // ใช้สำหรับการแสดงหน้าจอการชำระเงิน

// สร้างคลาส MatchingView ที่เป็น StatefulWidget
class MatchingView extends StatefulWidget {
  // const MatchingView({super.key, required this.selectedTags});
  const MatchingView({super.key, required this.bookId});
  final String bookId; // รับ bookId เป็นพารามิเตอร์

  @override
  State<MatchingView> createState() =>
      _MenuViewState(); // สร้าง state สำหรับ MatchingView
}

// คลาส State สำหรับ MatchingView
class _MenuViewState extends State<MatchingView> {
  // ประกาศอ้างอิงไปยังคอลเลกชันต่างๆใน Firestore
  final books =
      FirebaseFirestore.instance.collection('books'); // คอลเลกชันสำหรับการจอง
  final sitters = FirebaseFirestore.instance
      .collection('sitters'); // คอลเลกชันสำหรับ sitters
  final notifications = FirebaseFirestore.instance
      .collection('notifications'); // คอลเลกชันสำหรับการแจ้งเตือน

  // ตั้งค่าตัวแปรการจับคู่
  final maxRetry = MAX_RETRY_MATCH; // จำนวนครั้งสูงสุดที่ลองจับคู่
  int ticker = RETRY_TICKER; // ช่วงเวลาที่จะลองจับคู่ใหม่
  int retry = 0; // ตัวแปรนับจำนวนครั้งที่ลองจับคู่
  Timer? timer; // ตัวแปรสำหรับตั้งเวลา
  List<String> tryIds = []; // รายการของ sitter ที่ลองจับคู่แล้ว

  @override
  void initState() {
    super.initState();
    tryIds = []; // รีเซ็ตรายการ tryIds
    _matchSitter(widget.bookId); // เริ่มการจับคู่ครั้งแรก
    // ตั้งค่า Timer ให้ลองจับคู่ใหม่ทุกๆ ticker วินาที
    timer = Timer.periodic(Duration(seconds: ticker), (Timer t) {
      log('retry: $retry'); // บันทึก log จำนวนครั้งที่ลองจับคู่
      if (retry >= maxRetry) {
        // หากเกินจำนวนครั้งสูงสุดที่ตั้งไว้
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'ขออภัยขณะนี้ไม่มีที่รับฝากตรงกับความต้องการของท่าน กรุณาทำรายการใหม่อีกครั้ง'),
        ));
        _cacelBook(widget.bookId); // ยกเลิกการจอง
        return;
      }
      _matchSitter(widget.bookId); // ลองจับคู่ใหม่
      retry += 1; // เพิ่มจำนวนครั้งที่ลองจับคู่
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // ยกเลิก Timer
    super.dispose();
    Navigator.pop(context); // กลับไปหน้าจอก่อนหน้า
  }

  _matched() async {
    final bookId = widget.bookId;
    var snapshot =
        await books.doc(bookId).get(); // ดึงข้อมูลการจองจาก Firestore
    if (!snapshot.exists) {
      return; // หากเอกสารการจองไม่พบ ให้หยุดการทำงาน
    }
    var book = snapshot.data(); // ดึงข้อมูลการจอง
    // สร้างการสนทนา
    final chats = FirebaseFirestore.instance.collection('chats');
    // late dynamic chat;
    try {
      await chats.add({
        'active': true,
        'book_id': bookId,
        'chats': [],
        'members': [book!['user_id'], book['sitter_id']]
      });

      // log(chat.toString());
      // ส่งการแจ้งเตือน

      await notifications.add({
        'image': book['pet_image'],
        'extras': {'book_id': bookId},
        'title': 'รายการจอง',
        'message': 'จองสำเร็จ!',
        'type': 'booked',
        'read': false,
        'user_id': FirebaseAuth.instance.currentUser!.uid
      });
    } catch (e) {
      log(e.toString()); // แสดงข้อผิดพลาดในกรณีที่ไม่สามารถส่งการแจ้งเตือนได้
    }
  }

  // ฟังก์ชันจับคู่ Sitter
  Future<void> _matchSitter(String bookId) async {
    var snapshot =
        await books.doc(bookId).get(); // ดึงข้อมูลการจองจาก Firestore
    if (!snapshot.exists) {
      return; // หากเอกสารการจองไม่พบ ให้หยุดการทำงาน
    }
    var book = snapshot.data(); // ดึงข้อมูลการจอง

    if (book?['status'] == 'matched') {
      // หากการจองสถานะเป็น matched แล้ว
      timer?.cancel(); // ยกเลิก Timer
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) =>
      //         ChatView(chatId: chat.id), // ไปยังหน้าต่าง ChatView
      //   ),
      // ); // เปลี่ยนเส้นทางไปที่หน้าการชำระเงิน
    }

    // เงื่อนไขการจับคู่
    var options = book!['options']; // ดึงตัวเลือกการจับคู่
    Query query = sitters; // เริ่มต้น Query สำหรับ sitters
    options.forEach((key, value) {
      if (value == true) {
        query = query.where(key, isEqualTo: true); // กรองตามเงื่อนไข
      }
    });

    // if onsite seleted that filter sitters who setting onsite enabled
    if (book['onsite'] == true) {
      query = query.where('onsite', isEqualTo: true);
    }

    if (true) {
      query = query.where('active', isEqualTo: true);
    }

    log('tryIds: $tryIds');

    for (var element in tryIds) {
      query = query.where(FieldPath.documentId, isNotEqualTo: element);
    }

    QuerySnapshot snapshot2 = await query.get();
    if (!snapshot.exists) {
      return;
    }

    log('Got: snapshot2');

    if (snapshot2.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'ขออภัยขณะนี้ไม่มีที่รับฝากตรงกับความต้องการของท่าน กรุณาทำรายการใหม่อีกครั้ง'),
      ));
      _cacelBook(bookId);
      return;
    }

    log('Found: ${snapshot2.docs.length}');
    for (var element in snapshot2.docs) {
      log('element: ${element.id}');
      if (tryIds.contains(element['user_id'])) {
        continue; // ข้ามการจับคู่หาก sitter นี้ลองจับคู่แล้ว
      }
      // TODO: ปรับปรุงกระบวนการนี้
      final sitter =
          await sitters.where('user_id', isEqualTo: element['user_id']).get();

      await books.doc(bookId).update({
        'sitter': sitter.docs
            .take(1)
            .first
            .reference, // อัพเดตข้อมูล sitter ที่จับคู่ได้
        'sitter_id': element.id
      });

      // ส่งการแจ้งเตือนไปยัง sitters
      await notifications.add({
        'image': book['pet_image'],
        'extras': {'book_id': bookId},
        'title': 'งานใหม่',
        'message': 'กรุณายืนยันรายการภายใน 3 นาที',
        'type': 'booking',
        'read': false,
        'user_id': element['user_id'],
        'expiry': book['expiry'],
      });

      log('sent notification');
      if (!tryIds.contains(element['user_id'])) {
        tryIds.add(
            element['user_id']); // เพิ่ม sitter ที่ถูกจับคู่แล้วเข้าไปใน tryIds
      }
      break;
    }
  }

  // ฟังก์ชันยกเลิกการจอง
  Future<void> _cacelBook(String bookId) async {
    log('call _cacelBook');
    final docRef = books.doc(bookId);
    try {
      await docRef.update({
        'status': 'canceled',
        'timestamp': FieldValue.serverTimestamp()
      }); // อัพเดตสถานะการจองเป็น canceled
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error adding data to Firestore')), // แสดงข้อผิดพลาดถ้ามี
      );
      // log(e.toString());
    } finally {
      timer?.cancel(); // ยกเลิก Timer
      Navigator.pop(context); // กลับไปหน้าจอก่อนหน้า
      Navigator.pop(context); // กลับไปหน้าจอก่อนหน้า
    }
  }

  // ฟังก์ชันแสดงหน้าต่างยืนยันการยกเลิก
  void _showBackDialog(String bookId) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('ต้องการยกเลิก?'),
              content: const Text(
                'คุณต้องการยกเลิกการค้นหาใช่หรือไม่ ?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิดหน้าต่างยืนยัน
                  },
                  child: Text('ไม่'),
                ),
                TextButton(
                  onPressed: () async {
                    await _cacelBook(bookId); // ยกเลิกการจอง
                  },
                  child: const Text('ใช่ ยกเลิก'),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size; // ขนาดของหน้าจอ
    final bookId = widget.bookId; // ดึง bookId

    // สร้าง spinner
    const spinkit = SpinKitPouringHourGlass(
      color: Colors.orange,
      size: 150.0,
    );

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // แสดงโลโก้แอปพลิเคชัน
            Image.asset(
              "assets/img/app_logo.png",
              width: media.width * 0.55,
              height: media.width * 0.55,
              fit: BoxFit.contain,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              StreamBuilder<DocumentSnapshot>(
                  stream: books
                      .doc(bookId)
                      .snapshots(), // ฟังการเปลี่ยนแปลงในเอกสาร
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!.get('status'); // ดึงสถานะการจอง
                      // log('Status: ${data}');
                      if (data != null && data == 'matched') {
                        timer?.cancel(); // ยกเลิก Timer

                        return Column(
                          children: [
                            const Text(
                              'พบผู้รับเลี้ยงแล้ว...',
                              style: TextStyle(fontSize: 36),
                            ),
                            PopScope(
                                canPop: false,
                                onPopInvoked: (bool didPop) {
                                  if (didPop) {
                                    return;
                                  }
                                  _showBackDialog(
                                      bookId); // แสดงหน้าต่างยืนยันการยกเลิก
                                },
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _matched();

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChannelView(),
                                      ),
                                      (route) => route.isFirst,
                                    );
                                  },
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.red)),
                                  child: const Text('ไปหน้าแชท'),
                                )),
                          ],
                        );
                      }
                    }

                    // หากสถานะการจองยังไม่เป็น matched
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          spinkit, // แสดง spinner
                          const Text(
                            'กำลังค้นหาผู้รับเลี้ยง...',
                            style: TextStyle(fontSize: 36),
                          ),
                          PopScope(
                              canPop: false,
                              onPopInvoked: (bool didPop) {
                                if (didPop) {
                                  return;
                                }
                                _showBackDialog(
                                    bookId); // แสดงหน้าต่างยืนยันการยกเลิก
                              },
                              child: ElevatedButton(
                                onPressed: () => _showBackDialog(
                                    bookId), // ปุ่มยกเลิกการค้นหา
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.red)),
                                child: const Text('ยกเลิก'),
                              )),
                        ],
                      ),
                    );
                  }),
            ])
          ],
        )));
  }
}
