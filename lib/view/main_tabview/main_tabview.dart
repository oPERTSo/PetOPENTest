import 'package:flutter/material.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/common_widget/tab_button.dart';
import 'package:pettakecare/view/chat/channel_view.dart';
import 'package:pettakecare/view/home/home_view.dart';
import 'package:pettakecare/view/menu/menu_view.dart';
import 'package:pettakecare/view/more/more_view.dart';
import 'package:pettakecare/view/profile/profile_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selctTab =
      2; // ตัวแปรสำหรับเก็บหมายเลขแท็บที่เลือกอยู่ (เริ่มต้นที่แท็บที่ 2 ซึ่งเป็น HomeView)
  PageStorageBucket storageBucket =
      PageStorageBucket(); // ใช้สำหรับเก็บสถานะของ PageStorage
  Widget selectPageView =
      const HomeView(); // ตัวแปรสำหรับเก็บ Widget ของหน้าที่เลือก (เริ่มต้นที่ HomeView)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
          bucket: storageBucket,
          child: selectPageView), // ใช้ PageStorage เพื่อเก็บสถานะของหน้าต่าง
      backgroundColor: const Color(0xffF5F5F5), // สีพื้นหลังของ Scaffold
      floatingActionButtonLocation: FloatingActionButtonLocation
          .miniCenterDocked, // ตำแหน่งของ FloatingActionButton
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            if (selctTab != 2) {
              // ตรวจสอบว่าแท็บที่เลือกไม่ใช่ HomeView
              selctTab = 2; // ตั้งค่าแท็บที่เลือกเป็น HomeView
              selectPageView =
                  const HomeView(); // ตั้งค่า selectPageView เป็น HomeView
            }
            if (mounted) {
              // ตรวจสอบว่า Widget ยังถูกสร้างอยู่
              setState(() {}); // เรียก setState เพื่ออัพเดต UI
            }
          },
          shape:
              const CircleBorder(), // รูปทรงของ FloatingActionButton เป็นวงกลม
          backgroundColor: selctTab == 2
              ? TColor.primary
              : TColor
                  .placeholder, // เปลี่ยนสีพื้นหลังของ FloatingActionButton ขึ้นอยู่กับสถานะของ selctTab
          child: Image.asset(
            "assets/img/tab_home.png", // รูปไอคอนของ FloatingActionButton
            width: 30,
            height: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: TColor.white, // สีพื้นผิวของ BottomAppBar
        shadowColor: Colors.black, // สีเงาของ BottomAppBar
        elevation: 1, // ความสูงของเงา
        notchMargin: 12, // ขนาดของช่องที่ยื่นออกมาจาก BottomAppBar
        height: 64, // ความสูงของ BottomAppBar
        shape:
            const CircularNotchedRectangle(), // รูปร่างของ BottomAppBar เป็นวงกลมที่มีช่อง
        child: SafeArea(
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // จัดตำแหน่งลูกในแถวให้กระจายออก
            children: [
              TabButton(
                  title: "Menu", // ชื่อแท็บ
                  icon: "assets/img/tab_menu.png", // ไอคอนของแท็บ
                  onTap: () {
                    if (selctTab != 0) {
                      // ตรวจสอบว่าแท็บที่เลือกไม่ใช่ Menu
                      selctTab = 0; // ตั้งค่าแท็บที่เลือกเป็น Menu
                      selectPageView =
                          const MenuView(); // ตั้งค่า selectPageView เป็น MenuView
                    }
                    if (mounted) {
                      // ตรวจสอบว่า Widget ยังถูกสร้างอยู่
                      setState(() {}); // เรียก setState เพื่ออัพเดต UI
                    }
                  },
                  isSelected: selctTab ==
                      0), // เปลี่ยนลักษณะของ TabButton ขึ้นอยู่กับสถานะของ selctTab
              TabButton(
                  title: "chat", // ชื่อแท็บ
                  icon: "assets/img/chat.png", // ไอคอนของแท็บ
                  onTap: () {
                    if (selctTab != 1) {
                      // ตรวจสอบว่าแท็บที่เลือกไม่ใช่ chat
                      selctTab = 1; // ตั้งค่าแท็บที่เลือกเป็น chat
                      selectPageView =
                          ChannelView(); // ตั้งค่า selectPageView เป็น ChannelView
                    }
                    if (mounted) {
                      // ตรวจสอบว่า Widget ยังถูกสร้างอยู่
                      setState(() {}); // เรียก setState เพื่ออัพเดต UI
                    }
                  },
                  isSelected: selctTab ==
                      1), // เปลี่ยนลักษณะของ TabButton ขึ้นอยู่กับสถานะของ selctTab
              const SizedBox(
                width: 40,
                height: 40,
              ), // ช่องว่างตรงกลาง BottomAppBar
              TabButton(
                  title: "Profile", // ชื่อแท็บ
                  icon: "assets/img/tab_profile.png", // ไอคอนของแท็บ
                  onTap: () {
                    if (selctTab != 3) {
                      // ตรวจสอบว่าแท็บที่เลือกไม่ใช่ Profile
                      selctTab = 3; // ตั้งค่าแท็บที่เลือกเป็น Profile
                      selectPageView =
                          const ProfileView(); // ตั้งค่า selectPageView เป็น ProfileView
                    }
                    if (mounted) {
                      // ตรวจสอบว่า Widget ยังถูกสร้างอยู่
                      setState(() {}); // เรียก setState เพื่ออัพเดต UI
                    }
                  },
                  isSelected: selctTab ==
                      3), // เปลี่ยนลักษณะของ TabButton ขึ้นอยู่กับสถานะของ selctTab
              TabButton(
                  title: "more", // ชื่อแท็บ
                  icon: "assets/img/tab_more.png", // ไอคอนของแท็บ
                  onTap: () {
                    if (selctTab != 4) {
                      // ตรวจสอบว่าแท็บที่เลือกไม่ใช่ more
                      selctTab = 4; // ตั้งค่าแท็บที่เลือกเป็น more
                      selectPageView =
                          MoreView(); // ตั้งค่า selectPageView เป็น MoreView
                    }
                    if (mounted) {
                      // ตรวจสอบว่า Widget ยังถูกสร้างอยู่
                      setState(() {}); // เรียก setState เพื่ออัพเดต UI
                    }
                  },
                  isSelected: selctTab ==
                      4), // เปลี่ยนลักษณะของ TabButton ขึ้นอยู่กับสถานะของ selctTab
            ],
          ),
        ),
      ),
    );
  }
}
