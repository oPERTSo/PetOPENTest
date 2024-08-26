import 'package:flutter/material.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/common_widget/round_button.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart';

// คลาส OnBoardingView ใช้สำหรับแสดงหน้าจอการเริ่มต้นแอป
class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0; // ตัวแปรที่เก็บหมายเลขของหน้าที่ถูกเลือก
  PageController controller = PageController(); // คอนโทรลเลอร์สำหรับ PageView

  // รายการข้อมูลที่จะแสดงในแต่ละหน้าของการเริ่มต้น
  List pageArr = [
    {
      "title": "Pet Take Care",
      "subtitle":
          "Pet Take Care คือ \n แอพพลิเคชันที่เป็นตัวกลางในการจัดการหาผู้รับเลี้ยงสัตว์เลี้ยง",
      "image": "assets/img/on_boarding_1.png",
    },
    {
      "title": "เจ้าของสัตว์เลี้ยง",
      "subtitle":
          "เจ้าของสัตว์เลี้ยงสามารถ \n ค้นหาผู้รับเลี้ยงที่ตรงความต้องการได้",
      "image": "assets/img/on_boarding_3.png",
    },
    {
      "title": "ผู้รับฝากสัตว์เลี้ยง",
      "subtitle":
          "ผู้รับฝากสัตว์เลี้ยง \n จะถูกคัดกรองจากการลงพื้นที่ไปสัมภาษณ์ \n ว่ามีความพร้อมสำหรับเป็นผู้รับฝากหรือไม่",
      "image": "assets/img/on_boarding_2.png",
    },
  ];

  @override
  void initState() {
    super.initState();

    // เพิ่ม listener ให้กับ PageController เพื่ออัปเดต selectPage ตามการเลื่อนหน้า
    controller.addListener(() {
      setState(() {
        selectPage =
            controller.page?.round() ?? 0; // อัปเดตหมายเลขหน้าที่ถูกเลือก
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // ป้องกันการเลื่อนขึ้นของหน้าจอเมื่อแป้นพิมพ์ปรากฏ
      body: Stack(
        alignment: Alignment.center, // จัดแนวกลาง
        children: [
          PageView.builder(
            controller: controller, // ใช้คอนโทรลเลอร์ที่กำหนด
            itemCount: pageArr.length, // จำนวนหน้าทั้งหมด
            itemBuilder: ((context, index) {
              var pObj = pageArr[index] as Map? ?? {}; // ข้อมูลของหน้าปัจจุบัน
              return Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดแนวกลางในแนวตั้ง
                mainAxisSize: MainAxisSize.min, // ขนาดของ Column ตามเนื้อหา
                children: [
                  Container(
                    width: media.width, // ความกว้างของ Container ตามขนาดหน้าจอ
                    height: media.width, // ความสูงของ Container ตามขนาดหน้าจอ
                    alignment: Alignment.center,
                    child: Image.asset(
                      pObj["image"].toString(), // ภาพไอคอนที่ใช้
                      width: media.width * 0.65, // ความกว้างของภาพไอคอน
                      fit: BoxFit.contain, // การปรับขนาดของภาพไอคอน
                    ),
                  ),
                  SizedBox(
                    height: media.width *
                        0.2, // ขนาดของพื้นที่ว่างระหว่างภาพไอคอนและข้อความ
                  ),
                  Text(
                    pObj["title"].toString(), // ชื่อของหน้าปัจจุบัน
                    style: TextStyle(
                        color: TColor.primaryText, // สีข้อความ
                        fontSize: 28, // ขนาดฟอนต์
                        fontWeight: FontWeight.w800), // น้ำหนักฟอนต์
                  ),
                  SizedBox(
                    height: media.width *
                        0.05, // ขนาดของพื้นที่ว่างระหว่างชื่อและคำบรรยาย
                  ),
                  Text(
                    pObj["subtitle"].toString(), // คำบรรยายของหน้าปัจจุบัน
                    textAlign: TextAlign.center, // จัดแนวข้อความกลาง
                    style: TextStyle(
                        color: TColor.secondaryText, // สีข้อความ
                        fontSize: 13, // ขนาดฟอนต์
                        fontWeight: FontWeight.w500), // น้ำหนักฟอนต์
                  ),
                  SizedBox(
                    height: media.width * 0.20, // ขนาดของพื้นที่ว่างด้านล่าง
                  ),
                ],
              );
            }),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center, // จัดแนวกลางในแนวนอน
            children: [
              SizedBox(
                height: media.height * 0.6, // ขนาดของพื้นที่ว่างด้านบน
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดแนวกลางในแนวนอน
                children: pageArr.map((e) {
                  var index = pageArr.indexOf(e); // ดัชนีของหน้าปัจจุบัน

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4), // ขนาดของพื้นที่ว่างระหว่างดอท
                    height: 6, // ความสูงของดอท
                    width: 6, // ความกว้างของดอท
                    decoration: BoxDecoration(
                        color: index == selectPage
                            ? TColor.primary // สีของดอทที่แสดงสถานะปัจจุบัน
                            : TColor
                                .placeholder, // สีของดอทที่ไม่แสดงสถานะปัจจุบัน
                        borderRadius:
                            BorderRadius.circular(4)), // มุมโค้งของดอท
                  );
                }).toList(),
              ),
              SizedBox(
                height: media.height * 0.28, // ขนาดของพื้นที่ว่างด้านล่าง
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25), // ขอบเขตของ Padding
                child: RoundButton(
                    title: "Next", // ข้อความที่แสดงบนปุ่ม
                    onPressed: () {
                      if (selectPage >= 2) {
                        // หากเป็นหน้าสุดท้าย ให้ไปยังหน้าหลัก (MainTabView)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainTabView(),
                          ),
                        );
                      } else {
                        // ไปยังหน้าถัดไป
                        setState(() {
                          selectPage =
                              selectPage + 1; // อัปเดตหมายเลขหน้าที่ถูกเลือก
                          controller.animateToPage(selectPage,
                              duration: const Duration(
                                  milliseconds:
                                      500), // ความเร็วในการเปลี่ยนหน้า
                              curve:
                                  Curves.bounceInOut); // เอฟเฟกต์การเปลี่ยนหน้า
                        });
                      }
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }
}
