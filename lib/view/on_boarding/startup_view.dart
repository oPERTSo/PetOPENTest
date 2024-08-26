import 'package:flutter/material.dart';
import 'package:pettakecare/view/history/propage.dart';
import 'package:pettakecare/view/login/welcome_view.dart';

// คลาส StartupView ใช้สำหรับแสดงหน้าจอเริ่มต้นก่อนที่ผู้ใช้จะถูกนำไปยังหน้า WelcomeView
class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StarupViewState();
}

class _StarupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    goWelcomePage(); // เรียกใช้งานฟังก์ชัน goWelcomePage เมื่อสร้าง State
  }

  // ฟังก์ชัน goWelcomePage ทำงานเป็นระยะเวลา 3 วินาที แล้วเปลี่ยนไปยังหน้า WelcomeView
  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 3)); // รอเป็นเวลา 3 วินาที
    welcomePage(); // เรียกใช้งานฟังก์ชัน welcomePage หลังจากหมดเวลา
  }

  // ฟังก์ชัน welcomePage นำทางไปยังหน้า WelcomeView โดยการแทนที่หน้า StartupView
  void welcomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const WelcomeView()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ

    return Scaffold(
      body: Stack(
        alignment: Alignment.center, // จัดแนวกลาง
        children: [
          // ภาพพื้นหลังที่ครอบคลุมทั้งหน้าจอ
          Image.asset(
            "assets/img/splash_bg.png",
            width: media.width, // กำหนดความกว้างตามขนาดหน้าจอ
            height: media.height, // กำหนดความสูงตามขนาดหน้าจอ
            fit: BoxFit.cover, // ปรับขนาดภาพให้ครอบคลุมทั้งพื้นที่
          ),
          // โลโก้ของแอปที่อยู่ตรงกลางของหน้าจอ
          Image.asset(
            "assets/img/app_logo.png",
            width: media.width *
                0.55, // กำหนดความกว้างของโลโก้เป็น 55% ของความกว้างหน้าจอ
            height: media.width *
                0.55, // กำหนดความสูงของโลโก้เป็น 55% ของความกว้างหน้าจอ
            fit: BoxFit.contain, // ปรับขนาดภาพให้พอดีกับพื้นที่
          ),
        ],
      ),
    );
  }
}
