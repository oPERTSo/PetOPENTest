import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart';
import 'package:pettakecare/view/profile/PetSitter_page.dart';
import 'package:quickalert/quickalert.dart';

// คลาส ProfileView ใช้ในการแสดงและจัดการข้อมูลโปรไฟล์ของผู้ใช้
class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

// สถานะของ ProfileView
class _ProfileViewState extends State<ProfileView> {
  // ตัวแปรสำหรับการจัดการ Authentication, Firestore, และ Image Picker
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // ตัวแปรสำหรับเก็บข้อมูลโปรไฟล์ของผู้ใช้
  late User _user;
  int _point = 0;
  XFile? _image; // สำหรับเก็บข้อมูลภาพที่เลือก
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!; // รับข้อมูลผู้ใช้ปัจจุบัน
    _loadUserData(); // เรียกใช้ฟังก์ชันเพื่อโหลดข้อมูลผู้ใช้
  }

  // ฟังก์ชันเพื่อโหลดข้อมูลโปรไฟล์ของผู้ใช้จาก Firestore
  void _loadUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userData =
        await _firestore.collection('users').doc(_user.uid).get();
    setState(() {
      // ตั้งค่าข้อมูลใน TextEditingController
      _nameController.text = userData.data()!['name'];
      _mobileController.text = userData.data()!['mobile'];
      _addressController.text = userData.data()!['address'];
      _point =
          userData.data()!['point'] ?? 0; // กำหนดค่าเริ่มต้นให้เป็น 0 ถ้าไม่มี
    });
  }

  // ฟังก์ชันเพื่ออัปเดตข้อมูลโปรไฟล์ของผู้ใช้ใน Firestore
  Future<void> _updateUserData() async {
    await _firestore.collection('users').doc(_user.uid).update({
      'name': _nameController.text,
      'mobile': _mobileController.text,
      'address': _addressController.text,
    });
  }

  // ฟังก์ชันเพื่อเลือกภาพโปรไฟล์จากแกลเลอรีและอัปโหลดไปยัง Firebase Storage
  Future<void> _updateProfilePicture() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      // อัปโหลดภาพไปยัง Firebase Storage และอัปเดตข้อมูลผู้ใช้ด้วย URL ของภาพ
      // ขั้นตอนการอัปโหลดภาพและอัปเดตข้อมูลยังไม่ถูกจัดการในโค้ดนี้
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xffFC6011), // ตั้งค่าสีพื้นหลังของ AppBar
        actions: [
          // ปุ่ม Logout
          IconButton(
            onPressed: () async {
              await _auth.signOut(); // ออกจากระบบ
              // เปลี่ยนเส้นทางไปยังหน้าจอล็อกอินหรือหน้าจออื่น
            },
            icon: Icon(Icons.logout), // ไอคอนของปุ่ม Logout
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ตัวเลือกโปรไฟล์: คลิกเพื่ออัปเดตภาพ
            GestureDetector(
              onTap: _updateProfilePicture,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(File(_image!.path))
                    : null, // แสดงภาพที่เลือก
                child: _image == null
                    ? Icon(Icons.person, size: 50)
                    : null, // แสดงไอคอนถ้าไม่มีภาพ
              ),
            ),
            SizedBox(height: 16.0),
            Center(
                child: Text('แต้มสะสม: ' +
                    _point.toString())), // แสดงคะแนนสะสมของผู้ใช้
            TextField(
              controller: _nameController, // ใช้ตัวควบคุมชื่อ
              decoration:
                  InputDecoration(labelText: 'Name'), // ใส่ข้อความ label
            ),
            TextField(
              controller: _user.email != null
                  ? TextEditingController(text: _user.email)
                  : TextEditingController(),
              decoration: InputDecoration(labelText: 'Email'),
              readOnly: true, // ทำให้ฟิลด์อีเมลอ่านอย่างเดียว
            ),
            TextField(
              controller: _mobileController, // ใช้ตัวควบคุมมือถือ
              decoration: InputDecoration(labelText: 'Mobile'),
            ),
            TextField(
              controller: _addressController, // ใช้ตัวควบคุมที่อยู่
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 16.0),
            // ปุ่มสำหรับบันทึกการเปลี่ยนแปลง
            ElevatedButton(
                onPressed: () async {
                  await _updateUserData(); // อัปเดตข้อมูลผู้ใช้

                  // แสดงข้อความแจ้งเตือนสำเร็จ
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: 'แก้ไขสำเร็จ!',
                  );
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xffFC6011), // ตั้งค่าสีของข้อความปุ่ม
                )),
          ],
        ),
      ),
    );
  }
}
