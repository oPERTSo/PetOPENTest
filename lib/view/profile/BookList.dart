import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// คลาส BookListView ใช้ในการแสดงรายการหนังสือในรูปแบบรายการ (ListView)
class BookListView extends StatefulWidget {
  const BookListView({Key? key}) : super(key: key);

  @override
  State<BookListView> createState() => _BookListViewState();
}

// สถานะของ BookListView
class _BookListViewState extends State<BookListView> {
  // รายการหนังสือและข้อมูลการชำระเงิน
  List<Map<String, dynamic>> _books = [];
  Map<String, dynamic> _payments = {};
  late QuerySnapshot _querySnapshotUser;

  @override
  void initState() {
    super.initState();
    getBooks(); // เรียกใช้ฟังก์ชัน getBooks เมื่อเริ่มต้น
  }

  // ฟังก์ชันเพื่อดึงข้อมูลหนังสือและข้อมูลการชำระเงินจาก Firestore
  Future<void> getBooks() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // ดึงข้อมูลจากคอลเล็กชัน 'books'
    QuerySnapshot querySnapshot = await firestore.collection('books').get();
    // ดึงข้อมูลจากคอลเล็กชัน 'users'
    QuerySnapshot querySnapshotUser = await firestore.collection('users').get();

    // แปลงเอกสารที่ดึงมาจาก Firestore เป็น List ของ Map
    final allData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // เรียงลำดับหนังสือตามวันที่หมดอายุ (ใหม่สุดไปเก่าสุด)
    allData.sort((a, b) =>
        (b['expiry'] as Timestamp).compareTo(a['expiry'] as Timestamp));

    // กรองหนังสือที่มีสถานะการจับคู่สำเร็จ (จ่ายเงินแล้ว)
    List<Map<String, dynamic>> matchedBooks =
        allData.where((book) => book['status'] == 'paid').toList();

    Map<String, dynamic> payments = {};

    // ดึงข้อมูลการชำระเงินสำหรับหนังสือที่จับคู่แล้ว
    await Future.forEach(matchedBooks, (book) async {
      final payment =
          await firestore.collection('payments').doc(book['payment_id']).get();
      final charge = payment.get('charge') as Map;
      final source = charge['source'];

      // เพิ่มข้อมูลการชำระเงินลงในหนังสือ
      book['payment_ref'] = source['id'];
      book['payment_type'] = source['type'];
      book['payment_date'] = source['created_at'];
      book['payment_amount'] = source['amount'];
    });

    // อัปเดตสถานะของรายการหนังสือและข้อมูลการชำระเงิน
    setState(() {
      _payments = payments;
      _books = matchedBooks;
      _querySnapshotUser = querySnapshotUser;
    });
  }

  // ฟังก์ชันเพื่อแสดงสถานะของหนังสือ
  String? matchStatus(Map<String, dynamic> book) {
    Map<String, String> dict = {'paid': 'จ่ายแล้ว', 'matched': 'จับคู่แล้ว'};
    final status = book['status'];
    String out = dict.containsKey(status) ? dict[status] : status;

    if (status == 'paid') {
      out += ' ' +
          ' ผ่านช่องทาง ' +
          (book['payment_type'] ?? '') +
          ' เมื่อ ' +
          (book['payment_date'] ?? '') +
          ' REF ' +
          (book['payment_ref'] ?? '');
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    // สร้าง ListView ที่แสดงรายการหนังสือ
    return ListView.separated(
      itemCount: _books.length, // จำนวนรายการที่จะแสดง
      separatorBuilder: (context, index) =>
          SizedBox(height: 10), // ความสูงของ space ระหว่างรายการ
      itemBuilder: (context, index) {
        var book = _books[index];
        // ค้นหาข้อมูลของผู้ใช้ที่ตรงกับ user_id ของหนังสือ
        for (DocumentSnapshot userDataMap in _querySnapshotUser.docs) {
          if (userDataMap.id == book['user_id']) {
            var expiryDateTime = book['expiry'];
            String dateString =
                DateFormat('dd/MM/yyyy').format(expiryDateTime.toDate());

            // แสดงข้อมูลหนังสือใน ListTile ภายใน Card
            return Card(
              color: Color.fromARGB(
                  255, 253, 253, 253), // ตั้งค่าสีพื้นหลังเป็นสีขาว
              child: ListTile(
                title: Text('ชื่อ: ${userDataMap['name'] ?? ''}'), // ชื่อผู้ใช้
                subtitle: Text(
                    'สถานะ: ${matchStatus(book) ?? ''}\nชื่อสัตว์เลี้ยง: ${book['pet_name'].toString() ?? ''}\nวันที่: $dateString \n ระยะเวลาที่ฝาก: ${book['day'].toString() ?? ''}วัน'), // ข้อมูลสถานะและรายละเอียดของหนังสือ
              ),
            );
          }
        }
      },
    );
  }
}
