import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettakecare/common_widget/round_button.dart';
import 'package:pettakecare/common_widget/round_textfield.dart';
import 'package:pettakecare/view/match/matching_view.dart';
import 'package:uuid/uuid.dart';

// คลาส PetOwnerView ที่เป็น StatefulWidget
class PetOwnerView extends StatefulWidget {
  const PetOwnerView({super.key, this.pet});
  final dynamic pet;

  @override
  State<PetOwnerView> createState() => _PetOwnerViewState();
}

// คลาส Option เพื่อเก็บข้อมูลเกี่ยวกับตัวเลือกต่างๆ
class Option {
  final String key; // คีย์สำหรับตัวเลือก เช่น 'cat'
  final String label; // ป้ายชื่อสำหรับตัวเลือก เช่น 'แมว'
  bool value; // ค่าของตัวเลือก (true หรือ false)

  Option(this.key, this.label, this.value);
}

// คลาส State สำหรับ PetOwnerView
class _PetOwnerViewState extends State<PetOwnerView> {
  var uuid = Uuid(); // ตัวแปรสำหรับสร้าง UUID ใหม่
  final storageRef =
      FirebaseStorage.instance.ref(); // การอ้างอิงไปยัง Firebase Storage
  TextEditingController txtSearch =
      TextEditingController(); // ตัวควบคุมข้อความสำหรับชื่อสัตว์เลี้ยง
  TextEditingController textDisease =
      TextEditingController(); // ตัวควบคุมข้อความสำหรับโรคประจำตัว

  final ImagePicker picker = ImagePicker(); // สำหรับเลือกภาพจากคลัง
  late XFile? image; // ตัวแปรสำหรับเก็บข้อมูลภาพ
  List<Map<String, dynamic>> selectedList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onInitBind();
    });
  }

  _onInitBind() async {
    // txtSearch.text = widget.pet['name'] ?? '';
    // textDisease.text = widget.pet['history'] ?? '';
    setState(() {
      selectedList.add(widget.pet);
    });
  }

  // ฟังก์ชันสำหรับอัปโหลดไฟล์ไปยัง Firebase Storage
  Future<String> uploadFileFirebase(File file) async {
    final imgRef = storageRef.child('images'); // อ้างอิงไปยังโฟลเดอร์ images
    String fileName = uuid.v4() +
        '.' +
        file.path.split(
            '.')[file.path.split('.').length - 1]; // สร้างชื่อไฟล์ที่ไม่ซ้ำกัน
    final petRef = imgRef.child(fileName); // อ้างอิงไปยังไฟล์ที่กำลังจะอัปโหลด
    return (await petRef.putFile(file))
        .ref
        .getDownloadURL(); // อัปโหลดไฟล์และรับ URL
  }

  // ตัวเลือกสำหรับฟิลด์ต่างๆ
  Map<String, Option> options = <String, Option>{
    'cat': Option('cat', 'แมว', false),
    'condo': Option('condo', 'คอนโดแมว', false),
    'fountain': Option('fountain', 'น้ำพุแมว', false),
    'dog': Option('dog', 'หมา', false),
    'smalldog': Option('smalldog', 'หมาเล็ก', false),
    'bigdog': Option('bigdog', 'หมาใหญ่', false),
    'large': Option('large', 'พื้นที่สำหรับหมา', false),
    'boxdog': Option('boxdog', 'กรงหมา', false),
  };

  int depositDays = 1; // จำนวนวันที่จะฝาก
  int depositPets = 1; // จำนวนสัตว์เลี้ยง
  bool isHomeCareSelected = true; // สถานะการเลือกการดูแลที่บ้าน
  Map<String, String> uploadImage = {
    'url': 'assets/img/upload.png', // URL รูปภาพเริ่มต้น
    'type': 'asset'
  };

  // ฟังก์ชันสำหรับตั้งค่ารูปภาพที่อัปโหลด
  void setUploadImage(newImage) {
    setState(() {
      uploadImage = newImage; // อัปเดตข้อมูลรูปภาพ
    });
  }

  // ฟังก์ชันเพิ่มจำนวนวัน
  void incrementDepositDays() {
    setState(() {
      depositDays++; // เพิ่มจำนวนวัน
    });
  }

  // ฟังก์ชันลดจำนวนวัน
  void decrementDepositDays() {
    setState(() {
      if (depositDays > 0) {
        depositDays--; // ลดจำนวนวันถ้ามากกว่า 0
      }
    });
  }

  // ฟังก์ชันเพิ่มจำนวนสัตว์เลี้ยง
  void incrementDepositPets() {
    setState(() {
      depositPets++; // เพิ่มจำนวนสัตว์เลี้ยง
    });
  }

  // ฟังก์ชันลดจำนวนสัตว์เลี้ยง
  void decrementDepositPets() {
    setState(() {
      if (depositPets > 0) {
        depositPets--; // ลดจำนวนสัตว์เลี้ยงถ้ามากกว่า 0
      }
    });
  }

  // ฟังก์ชันสร้างการจองใหม่
  Future<String?> _createBooking() async {
    CollectionReference books = FirebaseFirestore.instance.collection('books');
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;

    if (currentUser == null) {
      return null; // หยุดการทำงานถ้าผู้ใช้ไม่ได้เข้าสู่ระบบ
    }

    DateTime currentTime = DateTime.now();
    DateTime expirationTime = currentTime.add(Duration(minutes: 3));

    try {
      // สร้างแผนที่ข้อมูลที่ต้องการเพิ่มลงใน Firestore
      Map<String, Object>? data = {
        'user_id': currentUser,
        'day': depositDays,
        'onsite': isHomeCareSelected,
        'status': 'waiting', // สถานะเริ่มต้น
        // 'pet_name': txtSearch.value.text.toString(), // ชื่อสัตว์เลี้ยง
        // 'pet_disease': textDisease.value.text.toString(), // โรคประจำตัว
        // 'pet_image': uploadImage['url'] ?? '', // URL รูปภาพสัตว์เลี้ยง
        // 'pets': depositPets,
        'pets': selectedList.length,
        'pets_details': selectedList,
        'pet_name':
            selectedList.map((e) => e['name']).join(','), // ชื่อสัตว์เลี้ยง
        'pet_disease': widget.pet['history'], // โรคประจำตัว // TODO: remove
        'pet_image': widget.pet['imageUrl'] ??
            '', // URL รูปภาพสัตว์เลี้ยง // TODO: remove
        'timestamp': FieldValue.serverTimestamp(), // เวลาปัจจุบัน
        'expiry': expirationTime, // เวลาหมดอายุ
      };
      data['options'] = options.map<String, bool>(
          (key, value) => MapEntry(key, value.value)); // เพิ่มตัวเลือกต่างๆ
      DocumentReference docRef =
          await books.add(data); // เพิ่มข้อมูลลงใน Firestore
      return docRef.id; // ส่งคืน ID ของเอกสารที่ถูกสร้าง
    } catch (e) {
      // แสดงข้อความผิดพลาดถ้ามี
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding data to Firestore')),
      );
    }

    return null; // ส่งคืนค่า null ถ้าเกิดข้อผิดพลาด
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // ขนาดของหน้าจอ

    return Scaffold(
      appBar: AppBar(
        title: Text("Pet Owner"), // ชื่อแถบเครื่องมือ
        leading: BackButton(), // ปุ่มกลับ
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey, // เชื่อมโยงกับฟอร์ม
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // แสดงโลโก้แอป
              Image.asset(
                "assets/img/app_logo.png",
                width: media.width * 0.35,
                height: media.width * 0.35,
                fit: BoxFit.contain,
              ),
              // กล่องแสดงชื่อ 'สัตว์เลี้ยง'
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(media.width * 0.2),
                ),
                child: const Center(
                  child: Text(
                    "สัตว์เลี้ยง",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // Card(
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Text(
              //               'ชื่อสัตว์เลี้ยง: ${widget.pet['name']}', // แสดงชื่อสัตว์เลี้ยง
              //               style: const TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 10),
              //         Text(
              //           'ประวัติโรคประจำตัวสัตว์เลี้ยง: ${widget.pet['history']}', // แสดงประวัติโรคประจำตัว
              //           style: const TextStyle(fontSize: 16),
              //         ),
              //         const SizedBox(height: 10),
              //         Text(
              //           'ที่อยู่: ${widget.pet['address']}', // แสดงที่อยู่
              //           style: const TextStyle(fontSize: 16),
              //         ),
              //         if (widget.pet['imageUrl'] != null)
              //           SizedBox(
              //             height: 200,
              //             width: double.infinity,
              //             child: Image.network(
              //               widget.pet['imageUrl'], // แสดงภาพสัตว์เลี้ยงจาก URL
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),

              ...selectedList.map((element) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ชื่อสัตว์เลี้ยง: ${element['name']}', // แสดงชื่อสัตว์เลี้ยง
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ประวัติโรคประจำตัวสัตว์เลี้ยง: ${element['history']}', // แสดงประวัติโรคประจำตัว
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ที่อยู่: ${element['address'] ?? ''}', // แสดงที่อยู่
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (element['imageUrl'] != null)
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Image.network(
                              element['imageUrl'], // แสดงภาพสัตว์เลี้ยงจาก URL
                              fit: BoxFit.cover,
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedList.remove(element);
                                });
                              },
                              child: const Text('ลบ'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              // Expanded(
              //   child: SizedBox(
              //     height: 200,
              //     width: 200,
              //     child: ListView.builder(
              //       scrollDirection: Axis.vertical,
              //       padding: const EdgeInsets.all(8.0),
              //       itemCount: 1,
              //       itemBuilder: (context, index) {
              //         return
              //       },
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('history')
                      .where('userId',
                          isEqualTo:
                              FirebaseAuth.instance.currentUser?.uid.toString())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.length > 1) {
                      return DropdownMenu<Map<String, dynamic>>(
                        width: 300,
                        onSelected: (value) {
                          setState(() {
                            if (!selectedList.any((element) =>
                                element['name'] == value!['name'])) {
                              selectedList.add(value as Map<String, dynamic>);
                            }
                          });
                        },
                        hintText: "เพิ่มสัตว์เลี้ยงที่คุณมี",
                        dropdownMenuEntries: snapshot.data!.docs.map((doc) {
                          final item = doc.data();
                          return DropdownMenuEntry<Map<String, dynamic>>(
                            label: item.containsKey('name') ? item['name'] : '',
                            value: item,
                          );
                        }).toList(),
                      );
                    } else {
                      return SizedBox
                          .shrink(); // ถ้ามีสัตว์เลี้ยงน้อยกว่าหรือเท่ากับ 1 ตัว ซ่อน Dropdown
                    }
                  },
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              // กล่องแสดงชื่อ 'แท็กสื่อที่ต้องการ'
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(media.width * 0.2),
                ),
                child: const Center(
                  child: Text(
                    "กำหนดขอบเขตหมวดหมู่ที่ต้องการจับคู่",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // แสดงตัวเลือกต่างๆ
              Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: createOptionWidget(options)),
              const SizedBox(
                height: 20,
              ),
              // แสดงจำนวนวัน
              Text(
                'จำนวนวัน: $depositDays',
                style: const TextStyle(fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: decrementDepositDays, // ลดจำนวนวัน
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: incrementDepositDays, // เพิ่มจำนวนวัน
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ปุ่มเลือกดูแลที่บ้าน
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isHomeCareSelected =
                            true; // กำหนดให้เลือก "ดูแลที่บ้าน"
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isHomeCareSelected ? Colors.green : Colors.grey,
                    ),
                    child: const Text('ดูแลที่บ้าน'),
                  ),
                  const SizedBox(width: 20),
                  // ปุ่มเลือกฝากผู้ดูแล
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isHomeCareSelected =
                            false; // กำหนดให้เลือก "ฝากผู้ดูแล"
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isHomeCareSelected ? Colors.green : Colors.grey,
                    ),
                    child: const Text('ฝากผู้ดูแล'),
                  ),
                ],
              ),
              // ปุ่มค้นหาผู้รับฝาก
              RoundButton(
                  title: "ค้นหาผู้รับฝาก",
                  onPressed: () async {
                    String? bookId =
                        await _createBooking(); // สร้างการจองและรับ ID
                    if (bookId == null) {
                      return; // หยุดการทำงานถ้า ID เป็น null
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchingView(
                          bookId: bookId, // ส่ง ID ไปยังหน้า MatchingView
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      )),
    );
  }

  // ฟังก์ชันสำหรับสร้าง ChoiceChip สำหรับตัวเลือกต่างๆ
  List<Widget> createOptionWidget(Map<String, Option> options) {
    List<Widget> list = [];
    options.forEach((key, option) {
      list.add(
        ChoiceChip(
          label: Text(option.label), // ป้ายชื่อของตัวเลือก
          selected: option.value, // สถานะการเลือกตัวเลือก
          onSelected: (isSelected) {
            setState(() {
              option.value =
                  !option.value; // เปลี่ยนสถานะของตัวเลือกเมื่อถูกเลือก
            });
          },
          selectedColor: Colors.green, // สีเมื่อเลือก
          labelStyle: TextStyle(
            color: option.value ? Colors.black : Colors.white, // สีข้อความ
          ),
          backgroundColor:
              option.value ? Colors.white : Colors.green, // สีพื้นหลัง
        ),
      );
    });
    return list;
  }
}
