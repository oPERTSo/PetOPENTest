import 'dart:developer'; // ใช้สำหรับบันทึก log

import 'package:cloud_firestore/cloud_firestore.dart'; // ใช้สำหรับเชื่อมต่อกับ Firestore
import 'package:firebase_auth/firebase_auth.dart'; // ใช้สำหรับเชื่อมต่อกับ Firebase Authentication
import 'package:flutter/material.dart'; // ใช้สำหรับสร้าง UI ของแอปพลิเคชัน
import 'package:pettakecare/view/more/notifications.dart'; // ใช้สำหรับการนำทางไปยังหน้าจอการแจ้งเตือน

// คลาส NotificationBadge สร้างปุ่มที่มีแถบแจ้งเตือน
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // ประกาศคอลเลกชัน notifications ของ Firestore
    final notifications =
        FirebaseFirestore.instance.collection('notifications');
    // ดึง userId ของผู้ใช้ที่ล็อกอินปัจจุบัน
    final currentUser = FirebaseAuth.instance.currentUser?.uid;

    return IconButton(
        onPressed: () {
          // เมื่อกดปุ่มจะนำทางไปยังหน้าจอการแจ้งเตือน
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsView(),
            ),
          );
        },
        icon: StreamBuilder(
            stream: notifications
                .where('user_id',
                    isEqualTo:
                        currentUser) // กรองเอกสารที่ user_id ตรงกับ userId ของผู้ใช้ปัจจุบัน
                .where('read', isEqualTo: false) // กรองเอกสารที่ยังไม่ถูกอ่าน
                .where('expiry',
                    isLessThan: Timestamp
                        .now()) // กรองเอกสารที่มีวันหมดอายุ (expiry) น้อยกว่าปัจจุบัน
                .snapshots(), // ฟังการเปลี่ยนแปลงของเอกสารในคอลเลกชัน
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // ตรวจสอบข้อผิดพลาดของ Stream
              if (snapshot.hasError) {
                // ทำการจัดการข้อผิดพลาดที่เกิดขึ้น (ยังไม่มีการจัดการในที่นี้)
                log('Error: ${snapshot.error}');
              }

              // ตรวจสอบว่ามีข้อมูลและเอกสารที่ตรงตามเงื่อนไข
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Badge(
                  label: Text((snapshot.data!.docs.length)
                      .toString()), // แสดงจำนวนการแจ้งเตือนที่ยังไม่ได้อ่าน
                  offset: const Offset(
                      5, -5), // ปรับตำแหน่งของป้ายแสดงจำนวนการแจ้งเตือน
                  child: Image.asset(
                    "assets/img/more_notification.png",
                    width: 25,
                    height: 25,
                  ),
                );
              }

              // หากไม่มีการแจ้งเตือนที่ยังไม่ได้อ่าน หรือไม่มีข้อมูล
              return Image.asset(
                "assets/img/more_notification.png",
                width: 25,
                height: 25,
              );
            }));
  }
}
