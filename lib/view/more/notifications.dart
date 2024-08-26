import 'dart:developer'; // ใช้สำหรับบันทึก log

import 'package:cloud_firestore/cloud_firestore.dart'; // ใช้สำหรับเชื่อมต่อกับ Firestore
import 'package:firebase_auth/firebase_auth.dart'; // ใช้สำหรับเชื่อมต่อกับ Firebase Authentication
import 'package:flutter/material.dart'; // ใช้สำหรับสร้าง UI ของแอปพลิเคชัน
import 'package:pettakecare/view/card/booked.dart'; // ใช้สำหรับการแสดงบัตรการจอง
import 'package:pettakecare/view/card/card.dart'; // ใช้สำหรับการแสดงบัตรการแจ้งเตือนการจอง
import 'package:pettakecare/view/card/match.dart'; // ใช้สำหรับการแสดงบัตรการจับคู่
import 'package:pettakecare/view/chat/channel_view.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart'; // ใช้สำหรับการนำทางไปยัง MainTabView
import 'package:pettakecare/view/menu/menu_view.dart'; // ใช้สำหรับการแสดงเมนู
import 'package:pettakecare/view/pay_view/payment_view.dart';
import 'package:quickalert/quickalert.dart'; // ใช้สำหรับการแสดงการแจ้งเตือน

// คลาส NotificationsView ใช้สำหรับแสดงหน้าจอการแจ้งเตือน
class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ
    final notifications = FirebaseFirestore.instance
        .collection('notifications'); // คอลเลกชัน notifications ของ Firestore
    final books = FirebaseFirestore.instance
        .collection('books'); // คอลเลกชัน books ของ Firestore
    final currentUser = FirebaseAuth
        .instance.currentUser?.uid; // userId ของผู้ใช้ที่ล็อกอินปัจจุบัน

    // ฟังก์ชันเพื่ออัพเดตสถานะของการจองเป็น 'matched'
    Future<void> _acceptBook(bookId) async {
      await books.doc(bookId).update({
        'status': 'matched', // อัพเดตสถานะของการจอง
        'timestamp': FieldValue.serverTimestamp(), // อัพเดตเวลา
      });
    }

    // ฟังก์ชันเพื่ออัพเดตสถานะของการจองเป็น 'matched'
    Future<void> _doneBook(bookId) async {
      await books.doc(bookId).update({
        'status': 'done', // อัพเดตสถานะของการจอง
        'timestamp': FieldValue.serverTimestamp(), // อัพเดตเวลา
      });
      final relatedNoti =
          await notifications.where('extras.book_id', isEqualTo: bookId).get();
      relatedNoti.docs.forEach((element) async {
        await notifications.doc(element.id).update({'read': true});
      });
    }

    // ฟังก์ชันเพื่ออัพเดตสถานะของการจองเป็น 'matched'
    Future<void> _cancleBook(bookId) async {
      await books.doc(bookId).update({
        'status': 'canceld', // อัพเดตสถานะของการจอง
        'timestamp': FieldValue.serverTimestamp(), // อัพเดตเวลา
      });
      final relatedNoti =
          await notifications.where('extras.book_id', isEqualTo: bookId).get();
      relatedNoti.docs.forEach((element) async {
        await notifications.doc(element.id).update({'read': true});
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange, // สีพื้นหลัง
                  borderRadius:
                      BorderRadius.circular(media.width * 0.2), // ขอบโค้ง
                ),
                child: const Center(
                  child: Text(
                    "แจ้งเตือน", // ข้อความหัวเรื่อง
                    style: TextStyle(
                      color: Colors.white, // สีข้อความ
                      fontSize: 18, // ขนาดข้อความ
                      fontWeight: FontWeight.bold, // น้ำหนักข้อความ
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: notifications
                    .where('user_id',
                        isEqualTo:
                            currentUser) // กรองเอกสารที่ user_id ตรงกับ userId ของผู้ใช้ปัจจุบัน
                    .where('read',
                        isEqualTo: false) // กรองเอกสารที่ยังไม่ถูกอ่าน
                    .snapshots(), // ฟังการเปลี่ยนแปลงของเอกสารในคอลเลกชัน
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    // ตรวจสอบข้อผิดพลาดของ Stream
                    log('Error: ${snapshot.error}'); // บันทึกข้อผิดพลาด
                  }

                  List<Widget> items =
                      []; // รายการของวิดเจ็ตสำหรับแสดงการแจ้งเตือน

                  // ทำการประมวลผลเอกสารที่ได้รับ
                  for (var item in snapshot.data!.docs.toList()) {
                    final noti = item.data() as Map;
                    if (noti.containsKey('expiry') &&
                        noti['expiry'].toDate().isBefore(DateTime.now())) {
                      continue; // ข้ามเอกสารที่หมดอายุ
                    }

                    final bookId = item.get('extras')['book_id'].toString();

                    // ตรวจสอบประเภทของการแจ้งเตือนและเพิ่มการ์ดที่เหมาะสม
                    if (item.get('type') == 'booking') {
                      items.add(BookingCard(
                          bookId: bookId, // ดึง bookId จากข้อมูล
                          onAcceptChanged: (accepted) async {
                            if (accepted) {
                              // หากยอมรับการจอง
                              await _acceptBook(bookId);
                            }
                            // ทำเครื่องหมายว่าอ่านแล้ว
                            notifications.doc(item.id).update({'read': true});
                          }));
                    } else if (item.get('type') == 'job') {
                      // items.add(Text('booked')); // ข้อความ 'booked'
                      items.add(
                        BookedCard(
                          bookId: bookId, // ดึง bookId จากข้อมูล
                          onAcceptChanged: (accepted) async {
                            if (accepted) {
                              _doneBook(
                                  item.get('extras')['book_id'].toString());
                              // ทำเครื่องหมายว่าอ่านแล้ว
                              notifications.doc(item.id).update({'read': true});
                            }

                            // แสดงการแจ้งเตือนสำเร็จ
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              text: 'สำเร็จ!',
                              onConfirmBtnTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ChannelView()), // นำทางไปยัง MainTabView
                                    (route) => route.isFirst);
                              },
                            );
                          },
                        ),
                      );
                    } else if (item.get('type') == 'booked') {
                      // items.add(Text('booked')); // ข้อความ 'booked'
                      items.add(
                        BookedCard(
                          bookId: bookId, // ดึง bookId จากข้อมูล
                          onAcceptChanged: (accepted) async {
                            if (accepted) {
                              // payment
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PaymentView(bookId: bookId),
                                ),
                              );
                            } else {
                              // หากงานเสร็จสิ้น
                              await _cancleBook(
                                  item.get('extras')['book_id'].toString());

                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                text: 'สำเร็จ!',
                                // onConfirmBtnTap: () {
                                //   Navigator.pushAndRemoveUntil(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (BuildContext context) =>
                                //               MainTabView()), // นำทางไปยัง MainTabView
                                //       (route) => route.isFirst);
                                // },
                              );
                              // ทำเครื่องหมายว่าอ่านแล้ว
                              notifications.doc(item.id).update({'read': true});
                            }

                            // แสดงการแจ้งเตือนสำเร็จ
                          },
                        ),
                      );
                    } else {
                      items.add(Text('Test')); // ข้อความทดสอบ
                    }
                  }

                  // หากไม่มีการแจ้งเตือน
                  if (items.length == 0) {
                    items.add(Container()); // เพิ่ม Container ว่าง
                  }

                  return Column(
                    children: items, // แสดงรายการของการแจ้งเตือน
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
