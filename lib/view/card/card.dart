import 'package:flutter/material.dart';

class PetSitterCard extends StatelessWidget {
  final String imageUrl; // URL ของภาพสำหรับ Pet Sitter
  final String name; // ชื่อของ Pet Sitter
  final String description; // คำอธิบายของ Pet Sitter
  final Function(bool)?
      onAcceptChanged; // ฟังก์ชันที่เรียกเมื่อการตอบรับหรือปฏิเสธเปลี่ยนแปลง

  const PetSitterCard({
    required this.imageUrl, // กำหนด imageUrl เป็นค่าที่จำเป็น
    required this.name, // กำหนด name เป็นค่าที่จำเป็น
    required this.description, // กำหนด description เป็นค่าที่จำเป็น
    this.onAcceptChanged, // ฟังก์ชัน onAcceptChanged เป็นออปชัน
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0), // ขอบเขตของการ์ด
      child: Column(
        children: [
          Image.network(
            imageUrl, // แสดงภาพจาก URL
            width: double.infinity, // กำหนดความกว้างให้เต็มพื้นที่การ์ด
            height: 200, // ความสูงของภาพ
            fit: BoxFit.cover, // การครอบภาพเพื่อให้เต็มพื้นที่
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // ขอบเขตภายในของเนื้อหาการ์ด
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // จัดตำแหน่งเนื้อหาจากด้านซ้าย
              children: [
                Text(
                  name, // แสดงชื่อของ Pet Sitter
                  style: TextStyle(
                    fontSize: 18, // ขนาดตัวอักษร
                    fontWeight: FontWeight.bold, // หนักตัวอักษร
                  ),
                ),
                SizedBox(height: 8), // ช่องว่างระหว่างชื่อและคำอธิบาย
                Text(description), // แสดงคำอธิบายของ Pet Sitter
                SizedBox(height: 16), // ช่องว่างระหว่างคำอธิบายและปุ่ม
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // กระจายปุ่มออกจากกัน
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (onAcceptChanged != null) {
                          onAcceptChanged!(
                              false); // เรียกฟังก์ชัน onAcceptChanged และส่งค่า false (ปฏิเสธ)
                        }
                      },
                      child: Text('ปฏิเสธ'), // ข้อความบนปุ่ม
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (onAcceptChanged != null) {
                          onAcceptChanged!(
                              true); // เรียกฟังก์ชัน onAcceptChanged และส่งค่า true (ตกลง)
                        }
                      },
                      child: Text('ตกลง'), // ข้อความบนปุ่ม
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
