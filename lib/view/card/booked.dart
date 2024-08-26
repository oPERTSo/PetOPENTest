import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettakecare/common/consts.dart';

class BookedCard extends StatelessWidget {
  final String bookId; // ID ของการจอง
  final Function(bool)?
      onAcceptChanged; // ฟังก์ชันที่เรียกเมื่อสถานะการยอมรับการจองเปลี่ยนแปลง

  const BookedCard({
    required this.bookId, // กำหนด bookId เป็นค่าที่จำเป็น
    this.onAcceptChanged, // ฟังก์ชัน onAcceptChanged เป็นออปชัน
  });

  @override
  Widget build(BuildContext context) {
    final books = FirebaseFirestore.instance
        .collection('books'); // การเข้าถึงคอลเลคชัน 'books' จาก Firestore
    final users = FirebaseFirestore.instance
        .collection('users'); // การเข้าถึงคอลเลคชัน 'users' จาก Firestore

    return Card(
      elevation: 1, // ความสูงของเงาที่อยู่ใต้การ์ด
      clipBehavior: Clip.none, // ป้องกันไม่ให้เนื้อหาภายในการ์ดถูกตัดขอบ
      child: StreamBuilder(
        stream: books
            .doc(bookId)
            .snapshots(), // ฟังการเปลี่ยนแปลงของเอกสารที่มี ID bookId
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(); // ถ้าไม่มีข้อมูลให้แสดงเป็นคอนเทนเนอร์ว่าง
          }
          if (!(snapshot.data!.exists)) {
            return Container(); // ถ้าเอกสารไม่พบให้แสดงเป็นคอนเทนเนอร์ว่าง
          }
          final book = snapshot.data; // รับข้อมูลการจองจาก snapshot

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // จัดตำแหน่งให้ตรงกลางตามแนวแกนข้าม
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // กระจายลูกออกจากกันตามแนวแกนหลัก
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        30), // ทำให้มุมของ Container เป็นทรงกลม
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.blueGrey,
                      child: Image.asset(
                        'assets/img/app_logo.png', // รูปภาพโลโก้ที่แสดงใน Container
                        fit:
                            BoxFit.cover, // การครอบภาพเพื่อให้พอดีกับ Container
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // จัดตำแหน่งให้เริ่มจากด้านซ้าย
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: users
                            .doc(book?.get('user_id').toString())
                            .get(), // ดึงข้อมูลผู้ใช้ที่มี user_id
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            final user = snapshot.data;
                            return Text('ชื่อลูกค้า: ' +
                                user?.get('name')); // แสดงชื่อของลูกค้า
                          }
                          return const Text(
                              "loading"); // แสดงข้อความ "loading" ขณะรอข้อมูล
                        },
                      ),
                      Text('ฝากเลี้ยงน้อง: ' +
                          (book?.get('pet_name'))), // แสดงชื่อสัตว์เลี้ยง
                      Text('โรคประจำตัว: ' +
                          (book?.get('pet_disease') ?? '')), // แสดงโรคประจำตัว
                      Text('จำนวนวัน: ' +
                          (book?.get('day')).toString()), // แสดงจำนวนวัน
                      Text(
                          'จำนวนสัตว์เลี้ยง: ${book?.get('pets')}'), // แสดงจำนวนสัตว์เลี้ยง
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                            'ยอดรวม ${(PAY_PERDAY * (book?.get('day') ?? 1) * (book?.get('pets') ?? 1))} บาท'), // แสดงยอดรวม
                      )
                    ],
                  ),
                  Image.asset(
                    'assets/img/app_logo.png', // รูปภาพโลโก้ที่แสดงในด้านขวา
                    width: 100,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // กระจายปุ่มออกจากกัน
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // เปลี่ยนสีพื้นหลังของปุ่ม
                      padding: EdgeInsets.symmetric(
                          horizontal: 80), // เพิ่มช่องว่างด้านข้างของปุ่ม
                    ),
                    onPressed: () {
                      if (onAcceptChanged != null) {
                        onAcceptChanged!(
                            true); // เรียกฟังก์ชัน onAcceptChanged และส่งค่า true
                      }
                    },
                    child: book!.get('user_id') ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? Text('ชำระเงิน')
                        : Text('จบงาน'), // ข้อความที่แสดงบนปุ่ม
                  ),
                  book.get('user_id') == FirebaseAuth.instance.currentUser!.uid
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.amber, // เปลี่ยนสีพื้นหลังของปุ่ม
                            padding: EdgeInsets.symmetric(
                                horizontal: 80), // เพิ่มช่องว่างด้านข้างของปุ่ม
                          ),
                          onPressed: () {
                            if (onAcceptChanged != null) {
                              onAcceptChanged!(
                                  false); // เรียกฟังก์ชัน onAcceptChanged และส่งค่า true
                            }
                          },
                          child: Text('ยกเลิก'))
                      : Container(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
