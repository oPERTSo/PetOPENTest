import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/view/login/login_view.dart';
import 'package:pettakecare/view/more/notifications.dart';
import 'package:pettakecare/view/profile/BookList.dart';
import 'package:pettakecare/view/profile/PaymentList.dart';

// คลาส MoreView ใช้สำหรับแสดงรายการตัวเลือกเพิ่มเติมในแอป
class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  // รายการตัวเลือกเพิ่มเติม
  List<Map<String, dynamic>> moreArr = [
    {
      "index": "1",
      "name": "Payment Details",
      "image": "assets/img/more_payment.png",
      "base": 0
    },
    {
      "index": "2",
      "name": "My Orders",
      "image": "assets/img/PETI.png",
      "base": 0
    },
    {
      "index": "3",
      "name": "Notifications",
      "image": "assets/img/more_notification.png",
      "base": 0
    },
    {
      "index": "4",
      "name": "Chat",
      "image": "assets/img/more_inbox.png",
      "base": 0
    },
    {
      "index": "5",
      "name": "Log out",
      "image": "assets/img/logout.png",
      "base": 0
    },
  ];

  // ฟังก์ชันสำหรับการออกจากระบบ
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut(); // ออกจากระบบ Firebase Authentication
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 20), // ขอบเขตแนวตั้งของ Padding
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // จัดแนวให้เริ่มต้นที่กลาง
            children: [
              const SizedBox(
                height: 46, // ขนาดของพื้นที่ว่างด้านบน
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), // ขอบเขตแนวนอนของ Padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // จัดแนวให้มีพื้นที่ว่างเท่าๆ กัน
                  children: [
                    Text(
                      "More",
                      style: TextStyle(
                          color: TColor.primaryText, // สีข้อความ
                          fontSize: 20, // ขนาดฟอนต์
                          fontWeight: FontWeight.w800), // น้ำหนักฟอนต์
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsView())); // นำทางไปยังหน้าการแจ้งเตือน
                      },
                      icon: Image.asset(
                        "assets/img/more_notification.png", // ไอคอนการแจ้งเตือน
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                  padding: EdgeInsets.zero, // ไม่มี Padding ภายใน ListView
                  physics:
                      const NeverScrollableScrollPhysics(), // ปิดการเลื่อนของ ListView
                  shrinkWrap: true, // ให้ ListView ขยายขนาดตามความสูงของเนื้อหา
                  itemCount: moreArr.length, // จำนวนรายการใน ListView
                  itemBuilder: (context, index) {
                    var mObj = moreArr[index] as Map? ??
                        {}; // ข้อมูลของรายการใน moreArr
                    var countBase =
                        mObj["base"] as int? ?? 0; // จำนวนที่จะแสดงถ้ามี
                    return InkWell(
                      onTap: () {
                        // การนำทางไปยังหน้าต่างๆ ตามที่ระบุใน moreArr
                        switch (mObj["index"].toString()) {
                          case "1":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentListView())); // นำทางไปยังหน้ารายการการชำระเงิน
                            break;
                          case "2":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BookListView())); // นำทางไปยังหน้ารายการหนังสือ
                            break;
                          case "3":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationsView())); // นำทางไปยังหน้าการแจ้งเตือน
                            break;
                          case "4":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Container())); // หน้ายังไม่ระบุ
                            break;
                          case "5":
                            _signOut().then((value) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginView()))); // ออกจากระบบและนำทางไปยังหน้าลงชื่อเข้าใช้
                            break;
                          default:
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20), // ขอบเขตของ Padding
                        child: Stack(
                          alignment: Alignment
                              .centerRight, // จัดแนวของ Stack ให้จัดอยู่ที่ขวาสุด
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12), // ขอบเขตของ Padding
                              decoration: BoxDecoration(
                                  color: TColor
                                      .textfield, // สีพื้นหลังของ Container
                                  borderRadius: BorderRadius.circular(
                                      5)), // มุมโค้งของ Container
                              margin: const EdgeInsets.only(
                                  right: 15), // ขอบเขตด้านขวาของ Container
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .start, // จัดแนวของ Row ให้เริ่มต้นที่ด้านซ้าย
                                children: [
                                  Container(
                                    width: 50, // ความกว้างของ Container
                                    height: 50, // ความสูงของ Container
                                    padding: const EdgeInsets.all(
                                        8), // ขอบเขตของ Padding
                                    decoration: BoxDecoration(
                                        color: TColor
                                            .placeholder, // สีพื้นหลังของ Container
                                        borderRadius: BorderRadius.circular(
                                            25)), // มุมโค้งของ Container
                                    alignment: Alignment.center,
                                    child: Image.asset(mObj["image"].toString(),
                                        width: 25,
                                        height: 25,
                                        fit: BoxFit.contain), // แสดงภาพไอคอน
                                  ),
                                  const SizedBox(
                                    width:
                                        15, // ขนาดของพื้นที่ว่างระหว่างภาพไอคอนและข้อความ
                                  ),
                                  Expanded(
                                    child: Text(
                                      mObj["name"].toString(),
                                      style: TextStyle(
                                          color:
                                              TColor.primaryText, // สีข้อความ
                                          fontSize: 14, // ขนาดฟอนต์
                                          fontWeight:
                                              FontWeight.w600), // น้ำหนักฟอนต์
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        15, // ขนาดของพื้นที่ว่างระหว่างข้อความและตัวนับ
                                  ),
                                  if (countBase >
                                      0) // แสดงตัวนับถ้ามีจำนวนมากกว่า 0
                                    Container(
                                      padding: const EdgeInsets.all(
                                          4), // ขอบเขตของ Padding
                                      decoration: BoxDecoration(
                                          color:
                                              Colors.red, // สีพื้นหลังของตัวนับ
                                          borderRadius: BorderRadius.circular(
                                              12.5)), // มุมโค้งของตัวนับ
                                      alignment: Alignment.center,
                                      child: Text(
                                        countBase
                                            .toString(), // แสดงจำนวนในตัวนับ
                                        style: TextStyle(
                                            color: TColor
                                                .white, // สีข้อความของตัวนับ
                                            fontSize: 12, // ขนาดฟอนต์
                                            fontWeight: FontWeight
                                                .w600), // น้ำหนักฟอนต์
                                      ),
                                    ),
                                  const SizedBox(
                                    width:
                                        10, // ขนาดของพื้นที่ว่างระหว่างตัวนับและไอคอนถัดไป
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.all(8), // ขอบเขตของ Padding
                              decoration: BoxDecoration(
                                  color: TColor
                                      .textfield, // สีพื้นหลังของ Container
                                  borderRadius: BorderRadius.circular(
                                      15)), // มุมโค้งของ Container
                              child: Image.asset("assets/img/btn_next.png",
                                  width: 10,
                                  height: 10,
                                  color: TColor.primaryText), // ไอคอนถัดไป
                            ),
                          ],
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
