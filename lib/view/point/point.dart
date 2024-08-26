import 'package:flutter/material.dart';

// คลาส User ใช้เพื่อเก็บข้อมูลของผู้ใช้
class User {
  String name; // ชื่อของผู้ใช้
  int points; // คะแนนของผู้ใช้

  // คอนสตรัคเตอร์ของ User
  User({required this.name, required this.points});
}

// คลาส PointCollection ใช้เพื่อจัดการการเก็บข้อมูลคะแนนของผู้ใช้
class PointCollection {
  Map<String, User> users =
      {}; // แผนที่เก็บข้อมูลผู้ใช้ โดยใช้ชื่อเป็นคีย์และ User เป็นค่า

  // ฟังก์ชันสำหรับเพิ่มผู้ใช้ใหม่
  void addUser(String name) {
    users[name] =
        User(name: name, points: 0); // เพิ่มผู้ใช้ใหม่ที่มีคะแนนเริ่มต้นเป็น 0
  }

  // ฟังก์ชันสำหรับเพิ่มคะแนนให้กับผู้ใช้ที่มีอยู่
  void addPoints(String name, int points) {
    if (users.containsKey(name)) {
      // ตรวจสอบว่าผู้ใช้มีอยู่ในแผนที่หรือไม่
      users[name]!.points += points; // เพิ่มคะแนนให้กับผู้ใช้
    } else {
      print('User not found'); // แสดงข้อความหากผู้ใช้ไม่พบ
    }
  }

  // ฟังก์ชันสำหรับดึงคะแนนของผู้ใช้
  int getPoints(String name) {
    if (users.containsKey(name)) {
      // ตรวจสอบว่าผู้ใช้มีอยู่ในแผนที่หรือไม่
      return users[name]!.points; // คืนค่าคะแนนของผู้ใช้
    } else {
      print('User not found'); // แสดงข้อความหากผู้ใช้ไม่พบ
      return 0; // คืนค่า 0 หากผู้ใช้ไม่พบ
    }
  }
}

// ฟังก์ชันหลักของแอพพลิเคชัน
void main() {
  runApp(MyApp()); // เรียกใช้ MyApp
}

// คลาส MyApp เป็น StatelessWidget ที่แสดง UI ของแอพพลิเคชัน
class MyApp extends StatelessWidget {
  final PointCollection pointCollection =
      PointCollection(); // สร้าง PointCollection ใหม่

  @override
  Widget build(BuildContext context) {
    // เพิ่มผู้ใช้และคะแนนใน PointCollection
    pointCollection.addUser('John'); // เพิ่มผู้ใช้ชื่อ John
    pointCollection.addPoints('John', 5); // เพิ่มคะแนน 5 ให้กับ John

    // สร้าง UI ของแอพพลิเคชัน
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Point Collection'), // ชื่อของแอพบาร์
        ),
        body: Center(
          child: Container(
            width: 200, // กว้าง 200
            height: 200, // สูง 200
            decoration: BoxDecoration(
              shape: BoxShape.circle, // รูปทรงเป็นวงกลม
              color: Colors.blue, // สีพื้นหลังเป็นสีฟ้า
            ),
            child: Center(
              child: Text(
                '${pointCollection.getPoints('John')} Points', // แสดงคะแนนของ John
                style: TextStyle(
                  fontSize: 24, // ขนาดตัวอักษร 24
                  color: Colors.white, // สีตัวอักษรเป็นสีขาว
                ),
                textAlign: TextAlign.center, // จัดแนวข้อความให้อยู่กลาง
              ),
            ),
          ),
        ),
      ),
    );
  }
}
