import 'package:flutter/material.dart';
import 'package:pettakecare/view/menu/PetOwner_view.dart'; // นำเข้า PetOwnerView
import 'package:pettakecare/view/menu/PetSitter_view.dart';
import 'package:pettakecare/view/profile/PetSitter_page.dart'; // นำเข้า PetSitterPage

// คลาส MenuView ใช้สำหรับแสดงเมนูหลัก
class MenuView extends StatefulWidget {
  const MenuView({Key? key}) : super(key: key);

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  // ฟังก์ชันนำทางไปยังหน้าจอ PetSitterPage
  void _navigateToPetSitterPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PetSitterPage()));
  }

  // ฟังก์ชันนำทางไปยังหน้าจอ PetOwnerView
  void _navigateToPetOwnerPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PetOwnerView()));
  }

  // ตัวแปรสถานะที่ใช้เก็บค่าของเมนูที่เลือก
  String _selectedPage = 'รับดูแลสัตว์เลี้ยง';

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: media.height * 0.05),
                child: Image.asset(
                  "assets/img/app_logo.png", // แสดงโลโก้แอป
                  width: media.width * 0.55,
                  height: media.width * 0.55,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: media.height * 0.05), // เพิ่มระยะห่าง
              DropdownButton<String>(
                value: _selectedPage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPage =
                        newValue!; // อัพเดตค่าของ _selectedPage เมื่อมีการเปลี่ยนแปลง
                  });
                },
                items: <String>['รับดูแลสัตว์เลี้ยง']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // แสดงรายการใน DropdownButton
                  );
                }).toList(),
              ),

              // แสดงปุ่มตามสถานะที่เลือกใน DropdownButton
              if (_selectedPage == 'รับดูแลสัตว์เลี้ยง')
                GestureDetector(
                  onTap: _navigateToPetSitterPage, // เมื่อนำทางไปยังหน้าจอ PetSitterPage
                  child: Container(
                    width: media.width * 0.4,
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.blue, // สีพื้นหลังของปุ่ม
                      borderRadius: BorderRadius.circular(40), // ขอบโค้งของปุ่ม
                    ),
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Center(
                      child: Text(
                        "รับดูแลสัตว์เลี้ยง", // ข้อความในปุ่ม
                        style: TextStyle(
                          color: Colors.white, // สีข้อความ
                          fontSize: 20, // ขนาดข้อความ
                          fontWeight: FontWeight.bold, // น้ำหนักข้อความ
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ฟังก์ชันหลักของแอปพลิเคชัน
void main() {
  runApp(MaterialApp(
    home: MenuView(), // เรียกใช้ MenuView เป็นหน้าเริ่มต้นของแอป
  ));
}
