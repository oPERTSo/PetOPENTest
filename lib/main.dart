import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pettakecare/firebase_options.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart';
import 'package:pettakecare/view/on_boarding/on_boarding_view.dart';
import 'package:pettakecare/view/on_boarding/startup_view.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ตรวจสอบให้แน่ใจว่า Flutter ได้รับการเริ่มต้นเรียบร้อยแล้ว

  // เปิดการดีบัก WebView สำหรับ Android ถ้าในโหมดดีบัก
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  // เริ่มต้น Firebase ด้วยตัวเลือกที่กำหนดไว้ในไฟล์ firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // เรียกใช้ MyApp และส่ง StartupView เป็นหน้าหลักเริ่มต้น
  runApp(MyApp(defaultHome: StartupView()));
}

// คลาส MyApp เป็น StatelessWidget ที่ใช้ในการสร้าง MaterialApp
class MyApp extends StatefulWidget {
  final Widget defaultHome; // หน้าเริ่มต้นที่จะแสดง

  const MyApp({super.key, required this.defaultHome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pet Take Care', // ชื่อแอพพลิเคชัน
        debugShowCheckedModeBanner: false, // ซ่อนแบนเนอร์ Debug
        theme: ThemeData(
          fontFamily: "Metropolis", // กำหนดฟอนต์สำหรับแอพ
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple), // กำหนดสีของธีม
          // useMaterial3: true, // ใช้ Material 3 ถ้าต้องการ
        ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance
                .authStateChanges(), // สตรีมการเปลี่ยนแปลงสถานะการเข้าสู่ระบบ
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // แสดงการโหลดถ้าข้อมูลยังไม่พร้อม
              } else {
                if (!snapshot.hasData) {
                  return const StartupView(); // ถ้าไม่มีข้อมูลผู้ใช้ ให้แสดงหน้า StartupView
                }

                log(snapshot.data.toString()); // บันทึกข้อมูลผู้ใช้ในคอนโซล
                return MainTabView(); // ถ้ามีข้อมูลผู้ใช้ให้แสดงหน้า MainTabView
              }
            }));
  }
}

// ฟังก์ชัน _initializeFirebase ถูกคอมเมนต์ไว้ เนื่องจากเริ่มต้น Firebase ได้ถูกเรียกใช้ใน main() แล้ว
// _initializeFirebase() async {
//      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   }
