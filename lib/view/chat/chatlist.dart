import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pettakecare/view/chat/chat_view.dart.bak';

// `UserListView` เป็น StatelessWidget ที่ใช้สำหรับแสดงรายชื่อผู้ใช้
class UserListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold ใช้เพื่อสร้างโครงสร้างพื้นฐานของหน้าจอ รวมถึง AppBar และ body
      appBar: AppBar(
        title: Text('Select User'), // ชื่อของแถบด้านบน
      ),
      body: StreamBuilder<QuerySnapshot>(
        // StreamBuilder ใช้เพื่อติดตามการเปลี่ยนแปลงในคอลเลกชัน 'users' ของ Firestore
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
          // ตรวจสอบสถานะของ snapshot
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            // ขณะรอข้อมูลจาก Firestore ให้แสดง CircularProgressIndicator
            return Center(child: CircularProgressIndicator());
          }

          // ตรวจสอบว่า snapshot มีข้อผิดพลาดหรือไม่
          if (userSnapshot.hasError) {
            // แสดงข้อความผิดพลาดหากเกิดข้อผิดพลาดในการดึงข้อมูล
            return Center(child: Text('Something went wrong'));
          }

          // ดึงเอกสารผู้ใช้จาก snapshot
          final userDocs = userSnapshot.data!.docs;

          // ใช้ ListView.builder เพื่อสร้างรายการผู้ใช้จากเอกสารที่ดึงมา
          return ListView.builder(
            itemCount: userDocs.length, // จำนวนรายการใน ListView
            itemBuilder: (ctx, index) {
              // ดึงเอกสารของผู้ใช้แต่ละราย
              final userDoc = userDocs[index];

              return ListTile(
                title: Text(userDoc['name']), // แสดงชื่อผู้ใช้
                onTap: () {
                  // เมื่อคลิกที่รายการผู้ใช้ จะนำผู้ใช้ไปยังหน้าจอแชทใหม่
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatUserId:
                            userDoc.id, // ส่ง ID ของผู้ใช้ไปยังหน้าจอแชท
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
