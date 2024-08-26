import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pettakecare/view/menu/PetSitter_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:pettakecare/common_widget/notification.dart';

// Widget สำหรับหน้า PetSitter
class PetSitterPage extends StatefulWidget {
  @override
  PetSitterPageState createState() {
    return PetSitterPageState();
  }
}

// คลาส Option สำหรับจัดเก็บข้อมูลของตัวเลือก (options) เช่น ประเภทสัตว์เลี้ยง
class Option {
  final String key;
  final String label;
  bool value;

  Option(this.key, this.label, this.value);
}

// State ของ PetSitterPage
class PetSitterPageState extends State<PetSitterPage> {
  final _formKey = GlobalKey<FormState>(); // คีย์สำหรับฟอร์มเพื่อจัดการสถานะการตรวจสอบความถูกต้อง
  String? sitterId; // ตัวระบุของ pet sitter
  String? sitterStatus; // สถานะของ pet sitter
  CollectionReference sitters = FirebaseFirestore.instance.collection('sitters'); // การอ้างอิงคอลเล็กชันใน Firestore

  // ตัวควบคุมข้อความสำหรับฟอร์ม
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();

  // แผนที่ของตัวเลือก (options) สำหรับเลือกประเภทสัตว์เลี้ยงและสิ่งของที่เกี่ยวข้อง
  Map<String, Option> options = <String, Option>{
    'cat': Option('cat', 'แมว', false),
    'condo': Option('condo', 'คอนโดแมว', false),
    'fountain': Option('fountain', 'น้ำพุแมว', false),
    'dog': Option('dog', 'หมา', false),
    'smalldog': Option('smalldog', 'หมาเล็ก', false),
    'bigdog': Option('bigdog', 'หมาใหญ่', false),
    'large': Option('large', 'พื้นที่สำหรับหมา', false),
    'boxdog': Option('boxdog', 'กรงหมา', false),
  };

  // ตัวแปรสำหรับคะแนนเฉลี่ยและจำนวนคะแนน
  double averageRating = 0.0;
  int totalRatings = 0;

  // ฟังก์ชันสำหรับตั้งค่า value ของ option
  void setOption(Option option, bool value) {
    options[option.key]?.value = value; // อัปเดตค่าในแผนที่ options ตามตัวเลือกที่เลือก
  }

  // ฟังก์ชันสำหรับสร้างหรืออัปเดตข้อมูล pet sitter ใน Firestore
  Future<String?> _createSistter(String? sitter) async {
    // รับ ID ของผู้ใช้ปัจจุบัน
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;

    // ถ้าผู้ใช้ไม่ได้เข้าสู่ระบบให้หยุดการทำงาน
    if (currentUser == null) {
      return null;
    }

    try {
      // สร้างแผนที่ข้อมูลที่ต้องการเพิ่มหรืออัปเดต
      Map<String, dynamic>? data = {
        'user_id': currentUser,
        'name': txtName.value.text.toString(),
        'address': txtAddress.value.text.toString(),
        'mobile': txtMobile.value.text.toString(),
        'email': txtEmail.value.text.toString(),
        'active': false, // สถานะเริ่มต้นเป็น inactive
        ...options.map<String, bool>(
            (key, value) => MapEntry(key, value.value)), // เพิ่มตัวเลือกและค่า
        'timestamp': FieldValue.serverTimestamp(), // เพิ่มเวลาปัจจุบัน
      };

      // ถ้ามี sitterId ให้ทำการอัปเดตข้อมูล
      if (sitter != null) {
        log('updated!');
        await sitters.doc(currentUser).update(data); // อัปเดตข้อมูลใน Firestore
        return 'success';
      }

      // ถ้าไม่มี sitterId ให้สร้างเอกสารใหม่ใน Firestore
      DocumentReference docRef = sitters.doc(currentUser);
      await docRef.set(data); // สร้างเอกสารใหม่ใน Firestore
      return docRef.id;
    } catch (e) {
      // แสดงข้อความผิดพลาดถ้ามี
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding data to Firestore')),
      );
    }

    return null;
  }

  // ฟังก์ชันสำหรับดึงข้อมูล pet sitter จาก Firestore
  Future<void> _fetchSitter() async {
    // รับ ID ของผู้ใช้ปัจจุบัน
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;

    // ถ้าผู้ใช้ไม่ได้เข้าสู่ระบบให้หยุดการทำงาน
    if (currentUser == null) {
      return;
    }

    // ดึงข้อมูลจาก Firestore
    QuerySnapshot<Object?> snapshot = await sitters.where('user_id', isEqualTo: currentUser).get();

    final sitter = snapshot.docs.firstOrNull; // เลือกเอกสารแรกในผลลัพธ์
    if (sitter!.exists) {
      // อัปเดตค่าตัวควบคุมข้อความจากข้อมูลที่ดึงมา
      Map<String, dynamic> data = sitter.data()! as Map<String, dynamic>;
      txtName.text = data.containsKey('name') ? data['name'] : '';
      txtEmail.text = data.containsKey('email') ? data['email'] : '';
      txtAddress.text = data.containsKey('address') ? data['address'] : '';
      txtMobile.text = data.containsKey('mobile') ? data['mobile'] : '';

      setState(() {
        sitterId = sitter.id; // ตั้งค่า ID ของ sitter
        sitterStatus = data.containsKey('active')
            ? data['active']
                ? 'ยืนยันตัวตนสำเร็จ'
                : 'รอการยืนยันตัวตน'
            : 'InActive';
      });

      // อัปเดตตัวเลือกจากข้อมูลที่ดึงมา
      options.forEach((key, option) {
        if (data.containsKey(key)) {
          option.value = data[key];
        }
      });

      // ดึงข้อมูลคะแนนหลังจากข้อมูลของ pet sitter ถูกดึงมาแล้ว
      _fetchRatings();
    }
  }

  // ฟังก์ชันสำหรับดึงข้อมูลคะแนน
  Future<void> _fetchRatings() async {
    if (sitterId == null) return;

    // ดึงข้อมูลจาก Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('petSitterId', isEqualTo: sitterId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      double totalRating = 0.0;
      int count = snapshot.docs.length;

      snapshot.docs.forEach((doc) {
        totalRating += doc['rating'];
      });

      setState(() {
        averageRating = totalRating / count;
        totalRatings = count;
      });
    } else {
      // กรณีที่ไม่มีคะแนนเลย
      setState(() {
        averageRating = 0.0;
        totalRatings = 0;
      });
    }
  }

  @override
  void initState() {
    _fetchSitter(); // เรียกใช้ฟังก์ชันดึงข้อมูลเมื่อเริ่มต้น
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pet Sitter"),
        leading: BackButton(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: const [NotificationBadge()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // แสดงสถานะของ pet sitter
                    Text('Status: ' + (sitterStatus ?? 'InActive')),
                    // แสดงคะแนนเฉลี่ย
                      SizedBox(height: 20),
                    Text(
                      'คะแนนเฉลี่ย: ${averageRating.toStringAsFixed(1)} (${totalRatings} ratings)',
                      style: TextStyle(fontSize: 16),
                    ),
                    RatingBar.builder(
                      initialRating: averageRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      ignoreGestures: true, // ทำให้ไม่สามารถโต้ตอบได้
                      onRatingUpdate: (rating) {
                        // ไม่มีฟังก์ชันสำหรับอัปเดตคะแนนในหน้า PetSitterPage
                      },
                    ),
                    // ฟิลด์สำหรับกรอกชื่อ
                    TextFormField(
                      controller: txtName,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),

                    // ฟิลด์สำหรับกรอกอีเมล
                    TextFormField(
                      controller: txtEmail,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),

                    // ฟิลด์สำหรับกรอกหมายเลขโทรศัพท์
                    TextFormField(
                      controller: txtMobile,
                      decoration: InputDecoration(
                        labelText: 'Mobile',
                      ),
                    ),

                    // ฟิลด์สำหรับกรอกที่อยู่
                    TextFormField(
                      controller: txtAddress,
                      decoration: InputDecoration(
                        labelText: 'Address',
                      ),
                    ),

                    // แสดงตัวเลือกต่าง ๆ
                    ...createOptionWidget(options),

                    // แสดงคะแนนดาว
                  

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Processing Data')));

                            String? sitter_id = await _createSistter(sitterId);
                            if (sitter_id == null) {
                              return;
                            }

                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                text: 'ทำรายการสำเร็จ!',
                                title: 'สำเร็จ!',
                                confirmBtnText: 'ตกลง');
                          }
                        },
                        child: Text('บันทึก'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้าง Widget ของตัวเลือก (options)
  List<Widget> createOptionWidget(Map<String, Option> options) {
    List<Widget> list = [];
    options.forEach((key, option) {
      list.add(
        CheckboxListTile(
          title: Text(option.label),
          value: option.value,
          onChanged: (isSelected) {
            setState(() {
              option.value = !option.value;
            });
          },
        ),
      );
    });
    return list;
  }
}
