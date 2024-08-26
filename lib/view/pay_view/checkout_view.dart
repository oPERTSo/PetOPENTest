import 'package:flutter/material.dart';

// คลาส CheckoutView ใช้สำหรับแสดงหน้าเช็คเอาต์ (checkout) ซึ่งจะเป็นหน้าจอหลักที่มีโลโก้ของแอป
class CheckoutView extends StatefulWidget {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // จัดแนวลูกค้ากลาง
            children: [
              // แสดงโลโก้ของแอป
              Image.asset(
                "assets/img/app_logo.png",
                width: media.width *
                    0.55, // กำหนดความกว้างของโลโก้เป็น 55% ของความกว้างหน้าจอ
                height: media.width *
                    0.55, // กำหนดความสูงของโลโก้เป็น 55% ของความกว้างหน้าจอ
                fit: BoxFit.contain, // ปรับขนาดภาพให้พอดีกับพื้นที่ที่กำหนด
              ),
            ],
          ),
        ),
      ),
    );
  }
}
