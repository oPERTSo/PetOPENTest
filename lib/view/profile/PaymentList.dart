import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentListView extends StatefulWidget {
  const PaymentListView({Key? key}) : super(key: key);

  @override
  State<PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<PaymentListView> {
  List<Map<String, dynamic>> _payments = []; // รายการเก็บข้อมูลการชำระเงิน
  late QuerySnapshot _querySnapshotUser; // ข้อมูลของผู้ใช้

  @override
  void initState() {
    super.initState();
    getPayments(); // เรียกใช้ฟังก์ชัน getPayments เพื่อดึงข้อมูลเมื่อเริ่มต้น
  }

  // ฟังก์ชันเพื่อดึงข้อมูลการชำระเงินและข้อมูลผู้ใช้จาก Firestore
  Future<void> getPayments() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // ดึงข้อมูลการชำระเงินจากคอลเล็กชัน 'payments'
    QuerySnapshot querySnapshot = await firestore.collection('payments').get();

    // ดึงข้อมูลผู้ใช้จากคอลเล็กชัน 'users'
    QuerySnapshot querySnapshotUser = await firestore.collection('users').get();

    // แปลงข้อมูลจาก QuerySnapshot เป็น List ของ Map
    final allData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // เรียงลำดับข้อมูลการชำระเงินตามวันที่สร้าง (ใหม่ไปเก่า)
    allData.sort((a, b) =>
        (b['created_at'] as Timestamp).compareTo(a['created_at'] as Timestamp));

    setState(() {
      _payments = allData; // อัปเดตสถานะข้อมูลการชำระเงิน
      _querySnapshotUser = querySnapshotUser; // อัปเดตสถานะข้อมูลผู้ใช้
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ

    return ListView.separated(
      itemCount: _payments.length, // จำนวนรายการการชำระเงิน
      separatorBuilder: (context, index) =>
          SizedBox(height: 10), // ความสูงของพื้นที่ระหว่างรายการ
      itemBuilder: (context, index) {
        var payment = _payments[index]; // ข้อมูลการชำระเงินปัจจุบัน

        // ค้นหาข้อมูลผู้ใช้ที่ตรงกับ user_id ของการชำระเงิน
        for (DocumentSnapshot userDataMap in _querySnapshotUser.docs) {
          if (userDataMap.id == payment['user_id']) {
            var createdDateTime =
                payment['created_at']; // วันที่สร้างการชำระเงิน

            // แปลงวันที่เป็นรูปแบบ 'dd/MM/yyyy'
            String dateString =
                DateFormat('dd/MM/yyyy').format(createdDateTime.toDate());

            return Card(
              // การ์ดสำหรับแสดงข้อมูลแต่ละรายการ
              child: ListTile(
                title:
                    Text('ชื่อ: ${userDataMap['name'] ?? ''}'), // ชื่อของผู้ใช้
                subtitle: Text(
                    'Status: ${dateString}\nชื่อสัตว์เลี้ยง: ${payment['amount'].toString() ?? ''} \n ระยะเวลาที่ฝาก: ${payment['status'].toString() ?? ''}วัน'), // ข้อมูลการชำระเงิน
              ),
            );
          }
        }

        // ถ้าไม่มีข้อมูลผู้ใช้ที่ตรงกัน ให้แสดง Widget ว่าง
        return SizedBox.shrink();
      },
    );
  }
}
