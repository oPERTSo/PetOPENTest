// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pettakecare/common_widget/notification.dart';
// import 'package:pettakecare/view/profile/PetSitter_page.dart';

// // คลาส PetSitterView ใช้สำหรับแสดงและจัดการข้อมูลโปรไฟล์ของผู้ใช้
// class PetSitterView extends StatefulWidget {
//   const PetSitterView({Key? key}) : super(key: key);

//   @override
//   State<PetSitterView> createState() => _PetSitterViewState();
// }

// class _PetSitterViewState extends State<PetSitterView> {
//   final FirebaseAuth _auth =
//       FirebaseAuth.instance; // การอ้างอิง Firebase Authentication
//   final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance; // การอ้างอิง Firestore
//   final ImagePicker _picker =
//       ImagePicker(); // การอ้างอิง ImagePicker สำหรับเลือกภาพ

//   late User _user; // ตัวแปรสำหรับเก็บข้อมูลผู้ใช้
//   XFile? _image; // ตัวแปรสำหรับเก็บภาพที่เลือก
//   TextEditingController _nameController =
//       TextEditingController(); // Controller สำหรับช่องกรอกชื่อ
//   TextEditingController _bioController =
//       TextEditingController(); // Controller สำหรับช่องกรอกชีวประวัติ
//   TextEditingController _mobileController =
//       TextEditingController(); // Controller สำหรับช่องกรอกหมายเลขโทรศัพท์
//   TextEditingController _addressController =
//       TextEditingController(); // Controller สำหรับช่องกรอกที่อยู่

//   @override
//   void initState() {
//     super.initState();
//     _user = _auth.currentUser!; // ดึงข้อมูลผู้ใช้ที่ลงชื่อเข้าใช้ปัจจุบัน
//     _loadUserData(); // เรียกใช้ฟังก์ชันโหลดข้อมูลผู้ใช้เมื่อเริ่มต้น
//   }

//   // ฟังก์ชันสำหรับโหลดข้อมูลของผู้ใช้จาก Firestore
//   void _loadUserData() async {
//     DocumentSnapshot<Map<String, dynamic>> userData =
//         await _firestore.collection('users').doc(_user.uid).get();
//     setState(() {
//       _nameController.text = userData.data()!['name'] ?? '';
//       _bioController.text = userData.data()!['bio'] ?? '';
//       _mobileController.text = userData.data()!['mobile'] ?? '';
//       _addressController.text = userData.data()!['address'] ?? '';
//     });
//   }

//   // ฟังก์ชันสำหรับอัพเดตข้อมูลผู้ใช้ใน Firestore
//   Future<void> _updateUserData() async {
//     await _firestore.collection('users').doc(_user.uid).update({
//       'name': _nameController.text, // อัพเดตชื่อ
//       'bio': _bioController.text, // อัพเดตชีวประวัติ
//       'mobile': _mobileController.text, // อัพเดตหมายเลขโทรศัพท์
//       'address': _addressController.text, // อัพเดตที่อยู่
//     });
//   }

//   // ฟังก์ชันสำหรับอัพเดตภาพโปรไฟล์
//   Future<void> _updateProfilePicture() async {
//     XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery); // เปิด Gallery เพื่อเลือกภาพ
//     if (image != null) {
//       setState(() {
//         _image = image; // เก็บภาพที่เลือก
//       });
//       // TODO: อัพโหลดภาพไปยัง Firebase Storage และอัพเดตข้อมูลผู้ใช้ด้วย URL ของภาพ
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'), // ชื่อแถบ AppBar
//         backgroundColor: Color(0xffFC6011), // สีพื้นหลังของ AppBar
//         elevation: 0, // ความสูงของเงา
//         centerTitle: true, // จัดตำแหน่งชื่อให้อยู่ตรงกลาง
//         actions: const [
//           NotificationBadge()
//         ], // การแสดง NotificationBadge (คาดว่ามีในโปรเจกต์)
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0), // การตั้งค่าขอบเขตของ Padding
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.stretch, // จัดแนวให้เต็มความกว้างของ Column
//           children: [
//             GestureDetector(
//               onTap:
//                   _updateProfilePicture, // เรียกใช้ฟังก์ชันเมื่อแตะที่ CircleAvatar
//               child: CircleAvatar(
//                 radius: 50, // ขนาดของ CircleAvatar
//                 backgroundImage: _image != null
//                     ? FileImage(File(_image!.path))
//                     : null, // ใช้ภาพที่เลือกหรือแสดงไอคอน
//                 child: _image == null
//                     ? Icon(Icons.person, size: 50)
//                     : null, // ไอคอนถ้าไม่มีภาพ
//               ),
//             ),
//             SizedBox(height: 16.0), // ขนาดของพื้นที่ว่างระหว่าง widgets
//             TextField(
//               controller: _nameController, // เชื่อมต่อกับ Controller สำหรับชื่อ
//               decoration: InputDecoration(labelText: 'Name'), // ข้อความ label
//             ),
//             TextField(
//               controller:
//                   _bioController, // เชื่อมต่อกับ Controller สำหรับชีวประวัติ
//               decoration: InputDecoration(labelText: 'Bio'), // ข้อความ label
//             ),
//             TextField(
//               controller: _user.email != null
//                   ? TextEditingController(
//                       text: _user.email) // ใช้ Controller ที่มีค่าอีเมล
//                   : TextEditingController(), // หรือสร้าง Controller ใหม่ถ้าไม่มีอีเมล
//               decoration: InputDecoration(labelText: 'Email'), // ข้อความ label
//               readOnly: true, // ทำให้ฟิลด์นี้ไม่สามารถแก้ไขได้
//             ),
//             TextField(
//               controller:
//                   _mobileController, // เชื่อมต่อกับ Controller สำหรับหมายเลขโทรศัพท์
//               decoration: InputDecoration(labelText: 'Mobile'), // ข้อความ label
//             ),
//             TextField(
//               controller:
//                   _addressController, // เชื่อมต่อกับ Controller สำหรับที่อยู่
//               decoration:
//                   InputDecoration(labelText: 'Address'), // ข้อความ label
//             ),
//             SizedBox(height: 16.0), // ขนาดของพื้นที่ว่างระหว่าง widgets
//             ElevatedButton(
//                 onPressed: () async {
//                   await _updateUserData(); // อัพเดตข้อมูลผู้ใช้เมื่อกดปุ่ม
//                   // แสดงข้อความสำเร็จหรือนำทางไปยังหน้าจออื่น
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (BuildContext context) =>
//                             PetSitterPage()), // นำทางไปยัง PetSitterPage
//                   );
//                 },
//                 child: Text('Save'), // ข้อความของปุ่ม
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Color(0xffFC6011), // สีของข้อความในปุ่ม
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
