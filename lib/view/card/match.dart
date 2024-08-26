import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pettakecare/common/consts.dart';

class BookingCard extends StatelessWidget {
  final String bookId; // ID ของการจอง
  final Function(bool)?
      onAcceptChanged; // ฟังก์ชันที่เรียกเมื่อการตอบรับหรือปฏิเสธเปลี่ยนแปลง

  const BookingCard({
    required this.bookId, // กำหนด bookId เป็นค่าที่จำเป็น
    this.onAcceptChanged, // ฟังก์ชัน onAcceptChanged เป็นออปชัน
  });

  @override
  Widget build(BuildContext context) {
    final books = FirebaseFirestore.instance
        .collection('books'); // การอ้างอิงไปยังคอลเล็กชัน 'books' ใน Firestore
    final users = FirebaseFirestore.instance
        .collection('users'); // การอ้างอิงไปยังคอลเล็กชัน 'users' ใน Firestore

    return Card(
      elevation: 1, // ความสูงของเงาใต้การ์ด
      clipBehavior: Clip.none, // การจัดการการตัดส่วนที่ออกจากการ์ด
      child: StreamBuilder(
        stream: books
            .doc(bookId)
            .snapshots(), // สตรีมข้อมูลการจองจาก Firestore ตาม bookId
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(); // หากยังไม่มีข้อมูล ให้แสดง Container ว่าง
          }
          if (!(snapshot.data!.exists)) {
            return Container(); // หากเอกสารไม่พบ ให้แสดง Container ว่าง
          }
          final book = snapshot.data; // ดึงข้อมูลการจอง

          return Column(children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // จัดแนวขวางตามแนวกลาง
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // กระจายช่องว่างระหว่างเนื้อหา
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30), // มุมโค้งมนของภาพ
                  child: Container(
                      width: 60, // ความกว้างของภาพ
                      height: 60, // ความสูงของภาพ
                      color: Colors.blueGrey, // สีพื้นหลังของภาพ
                      child: Image.asset(
                        'assets/img/app_logo.png', // ภาพที่ใช้
                        fit: BoxFit.cover, // การครอบภาพให้เต็มพื้นที่
                      )),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // จัดแนวเนื้อหาจากด้านซ้าย
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: users
                          .doc(book?.get('user_id').toString())
                          .get(), // ดึงข้อมูลผู้ใช้จาก Firestore
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final user = snapshot.data; // ดึงข้อมูลผู้ใช้
                          return Text('ชื่อลูกค้า: ' +
                              user?.get('name')); // แสดงชื่อผู้ใช้
                        }
                        return const Text(
                            "loading"); // แสดงข้อความ "loading" ขณะรอข้อมูล
                      },
                    ),
                    Text('ฝากเลี้ยงน้อง: ' +
                        book?.get('pet_name')), // แสดงชื่อสัตว์เลี้ยง
                    Text('โรคประจำตัว: ' +
                        book?.get('pet_disease')), // แสดงโรคประจำตัว
                    Text('จำนวนวัน: ' +
                        (book?.get('day')).toString()), // แสดงจำนวนวัน
                    Text(
                        'จำนวนสัตว์เลี้ยง: ${book?.get('pets')}'), // แสดงจำนวนสัตว์เลี้ยง
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                          'ยอดรวม ${(PAY_PERDAY * (book?.get('day') ?? 1) * (book?.get('pets') ?? 1))} บาท'), // คำนวณยอดรวมจากการจอง
                    )
                  ],
                ),
                Image.asset(
                  'assets/img/app_logo.png', // ภาพที่ใช้
                  width: 100, // ความกว้างของภาพ
                ),
              ],
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // กระจายปุ่มออกจากกัน
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
          ]);
        },
      ),
    );
  }
}
