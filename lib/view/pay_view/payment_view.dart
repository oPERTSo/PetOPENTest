import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pettakecare/common/consts.dart';
import 'package:pettakecare/view/card/rating.dart';
import 'package:pettakecare/view/home/home_view.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart';
import 'package:pettakecare/view/menu/menu_view.dart';
import 'package:pettakecare/view/pay_view/omise/omise.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

// Enum สำหรับวิธีการชำระเงินที่เลือกได้
enum Payment { promptpay, rabbit_linepay }

// คลาส PaymentView ใช้สำหรับแสดงหน้าเลือกวิธีการชำระเงินและดำเนินการชำระเงิน
class PaymentView extends StatefulWidget {
  // รับค่า bookId จากผู้เรียก
  const PaymentView({super.key, required this.bookId});
  final String? bookId; // รหัสหนังสือหรือการจอง

  @override
  State<PaymentView> createState() => _MenuViewState();
}

// State ของ PaymentView
class _MenuViewState extends State<PaymentView> {
  final books = FirebaseFirestore.instance.collection('books');
  final users = FirebaseFirestore.instance.collection('users');
  final settings = FirebaseFirestore.instance.collection('settings');
  final chats = FirebaseFirestore.instance.collection('chats');
  final notifications = FirebaseFirestore.instance.collection('notifications');
  final payments = FirebaseFirestore.instance.collection('payments');

  Timer? timer; // Timer สำหรับตรวจสอบสถานะการชำระเงิน
  Payment? _payment = Payment.promptpay; // วิธีการชำระเงินที่ถูกเลือก
  bool isScanable = false; // ระบุว่า QR Code สามารถสแกนได้หรือไม่
  String? qrCode; // URL ของ QR Code
  String? payMentLink; // ลิงก์สำหรับการชำระเงิน

  // การตั้งค่าการเชื่อมต่อกับ Omise
  OmiseFlutter omiseClient = OmiseFlutter(OMISE_PUBLIC_KEY);
  OmiseFlutter omise = OmiseFlutter(OMISE_PRIVATE_KEY);

  @override
  void dispose() {
    timer?.cancel(); // หยุด Timer เมื่อลบ widget
    super.dispose();
  }

  // ฟังก์ชันสำหรับตั้งค่าวิธีการชำระเงินที่ถูกเลือก
  void _setPayment(value) {
    setState(() {
      _payment = value;
    });
  }

  // ฟังก์ชันสำหรับสร้างการชำระเงิน
  Future<void> _generatePayment(amount) async {
    // สร้าง Source ใหม่เพื่อการชำระเงิน
    final source = await omise.source.create(
        (amount * 100), "THB", _payment.toString().split('.').last.toString());
    // สร้าง Charge ใหม่โดยใช้ Source ที่สร้างขึ้น
    final charge = await omise.charge.create(
        (amount * 100), "THB", source.id.toString(),
        returnUri: 'http://localhost');

    int point = (amount /
            ((await (settings.doc('points')).get()).data()?['point'] ?? 100))
        .floor();

    // ตรวจสอบสถานะการชำระเงินทุก 5 วินาที
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      omise.charge.query(charge.id.toString()).then((charge) async {
        if (charge.status == 'successful') {
          // หากการชำระเงินสำเร็จ
          final payment = await payments.add({
            'book_id': widget.bookId,
            'charge': charge.toJson(),
          });

          // อัพเดตสถานะของหนังสือและเพิ่มคะแนน
          final bookDoc = books.doc(widget.bookId);
          bookDoc.update({'status': 'paid', 'payment_id': payment.id});
          final user = (users.doc(FirebaseAuth.instance.currentUser!.uid));
          final item = await user.get();
          if (item.data()!.containsKey('point')) {
            user.update({
              'point': FieldValue.increment(point),
            });
          } else {
            user.update({
              'point': point,
            });
          }

          // // สร้างการสนทนา
          final book = await bookDoc.get();

          // await chats.add({
          //   'active': true,
          //   'book_id': widget.bookId,
          //   'chats': [],
          //   'members': [
          //     FirebaseAuth.instance.currentUser!.uid,
          //     book.get('sitter_id')
          //   ]
          // });

          try {
            // ส่งการแจ้งเตือน
            await notifications.add({
              'image': book.get('pet_image'),
              'extras': {'book_id': widget.bookId},
              'title': 'งานที่รับ',
              'message': 'กดจบงาน!',
              'type': 'job',
              'read': false,
              'user_id': book.get('sitter_id'),
            });

            final relatedNoti = await notifications
                .where('extras.book_id', isEqualTo: bookDoc.id)
                .where('user_id', isEqualTo: user.id)
                .where('read', isEqualTo: false)
                .get();

            relatedNoti.docs.forEach((element) async {
              await notifications.doc(element.id).update({'read': true});
            });
          } catch (e) {
            // log(e.toString()); // แสดงข้อผิดพลาดในกรณีที่ไม่สามารถส่งการแจ้งเตือนได้
          }

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'สำเร็จ!',
            title: 'คุณได้รับ $point คะแนน',
            onConfirmBtnTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => CustomRatingBottomSheet(
                          petSitterId: book.get('sitter_id'))), // ส่ง ID ของ PetSitter ที่จับคู่
                  (route) => route.isFirst);
            });
          t.cancel();
        }
      });
    });

    // ตรวจสอบว่า Charge มี QR Code หรือไม่
    if (charge.source?.scannableCode != null) {
      String? url = charge.source!.scannableCode!.image!.download_uri;

      setState(() {
        isScanable = true;
        qrCode = url;
      });
      return;
    } else {
      setState(() {
        isScanable = false;
        payMentLink = charge.authorizeUri!;
      });
    }
  }

  // ฟังก์ชันสำหรับเปิดลิงก์ในเบราว์เซอร์
  Future<void> _launchInBrowser(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  // ฟังก์ชันสำหรับโหลดภาพจาก URL
  Future<Object?> loadImageV2(String url, Map<String, String>? headers) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Payment"), // ชื่อแอพบาร์
          leading: BackButton(), // ปุ่มย้อนกลับ
          backgroundColor: Colors.orange, // สีพื้นหลังของแอพบาร์
          foregroundColor: Colors.white, // สีข้อความและไอคอนในแอพบาร์
          elevation: 0, // ไม่มีเงา
          centerTitle: true, // จัดกลางชื่อในแอพบาร์
        ),
        body: SingleChildScrollView(
            child: FutureBuilder<DocumentSnapshot>(
          future:
              books.doc(widget.bookId).get(), // ดึงข้อมูลหนังสือจาก Firestore
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              log(snapshot.error.toString()); // แสดงข้อผิดพลาดหากมี
            }
            if (snapshot.hasData) {
              final book = snapshot.data;

              final sitterRef = book!.get('sitter') as DocumentReference?;

              return Column(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: sitterRef?.get(), // ดึงข้อมูลผู้ดูแลจาก Firestore
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // log(snapshot.error.toString()); // แสดงข้อผิดพลาดหากมี
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        final sitter = snapshot.data?.data() as Map;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ผู้รับฝาก',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.blueGrey,
                                              child: sitter.containsKey('image')
                                                  ? Image.network(
                                                      sitter['image'] ?? '',
                                                      width: 120,
                                                      height: 80,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/img/app_logo.png',
                                                          width: 120,
                                                          height: 80,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/img/app_logo.png',
                                                      width: 120,
                                                      height: 80,
                                                    )),
                                        ),
                                        Column(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ButtonStyle(
                                                side: MaterialStateProperty.all<
                                                    BorderSide>(
                                                  const BorderSide(
                                                      color: Colors.orange,
                                                      width: 2.0),
                                                ),
                                              ),
                                              child: const Text(
                                                'ดูโปรไฟล์',
                                                style: TextStyle(
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                )),
                            const Divider(),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'ที่อยู่',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(sitter.containsKey('address')
                                        ? sitter['address']
                                        : ''),
                                  ],
                                )),
                            const Divider(),
                            const Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'สัตว์เลี้ยง',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                )),
                          ],
                        );
                      }
                      return Container(); // คืนค่า Container ว่างหากยังไม่เสร็จ
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      book.get('pet_image').startsWith('http')
                          ? Image.network(
                              book.get('pet_image') ?? '',
                              width: 120,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/img/app_logo.png',
                                  width: 120,
                                  height: 80,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/img/app_logo.png',
                              width: 120,
                              height: 80,
                            ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ชื่อ: ${book!.get('pet_name')}'),
                          Text('จำนวนวัน: ${book.get('day')}'),
                          Text('จำนวนสัตว์เลี้ยง: ${book.get('pets')}'),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                                'ยอดรวม ${(PAY_PERDAY * (book.get('day') ?? 1) * (book.get('pets') ?? 1))} บาท'),
                          )
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'การชำระเงิน',
                            style: TextStyle(fontSize: 20),
                          ),
                          Column(
                            children: [
                              ListTile(
                                title: const Text('Prompay QR'),
                                leading: Radio<Payment>(
                                  value: Payment.promptpay,
                                  groupValue: _payment,
                                  onChanged: (value) {
                                    _setPayment(value);
                                  },
                                ),
                              ),
                              ListTile(
                                  title: const Text('Rabbit LINE Pay'),
                                  leading: Radio<Payment>(
                                    value: Payment.rabbit_linepay,
                                    groupValue: _payment,
                                    onChanged: (value) {
                                      _setPayment(value);
                                    },
                                  ))
                            ],
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: isScanable
                        ? const CircularProgressIndicator()
                        : payMentLink != null
                            ? TextButton(
                                onPressed: () {
                                  _launchInBrowser(payMentLink!);
                                },
                                child: Text(payMentLink!),
                              )
                            : Container(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            timer?.cancel();
                            _generatePayment((PAY_PERDAY *
                                (book.get('day') ?? 1) *
                                (book.get('pets') ?? 1)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffFC6011),
                            foregroundColor: Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: const Text(
                            'ชำระเงิน',
                          ))
                    ],
                  )
                ],
              );
            }

            return const Text(
                'error'); // แสดงข้อความข้อผิดพลาดหากไม่สามารถดึงข้อมูลได้
          },
        )));
  }
}
