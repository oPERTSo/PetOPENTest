import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pettakecare/common_widget/round_textfield.dart';
import 'package:pettakecare/view/home/home_view.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart';

// class RatingVote extends StatefulWidget {
//   const RatingVote({super.key});

//   @override
//   State<RatingVote> createState() => _RatingVoteState();
// }

// class _RatingVoteState extends State<RatingVote> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: Text(
//           'Review',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//       body: SizedBox(
//         width: double.infinity,
//         height: double.infinity,
//         child: Center(
//           child: MaterialButton(
//             height: 50,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             color: Colors.purple,
//             onPressed: () {
//               CustomRatingButtomSheet.showFeedBackBottomSheet(context: context);
//             },
//             child: Text('Review'),
//           ),
//         ),
//       ),
//     );
//   }
// }

// RatingVote
class CustomRatingBottomSheet extends StatefulWidget {
  final String petSitterId;
  const CustomRatingBottomSheet({Key? key, required this.petSitterId}) : super(key: key);

  @override
  _CustomRatingBottomSheetState createState() => _CustomRatingBottomSheetState();
}

class _CustomRatingBottomSheetState extends State<CustomRatingBottomSheet> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();

  Future<void> _submitRating() async {
  try {
    await FirebaseFirestore.instance.collection('ratings').add({
      'petSitterId': widget.petSitterId,
      'rating': _rating,
      'review': _reviewController.text,
      'timestamp': Timestamp.now(),
    });

    // นำทางกลับไปที่ MainTabView พร้อมกับเลือกแท็บ Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainTabView()),
    );
  } catch (e) {
    print('Error: $e');
    // คุณอาจต้องการแสดงข้อความแสดงข้อผิดพลาด
  }
}




  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.0),
            Text('ให้คะแนน PetSitter', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(labelText: 'แสดงความคิดเห็น'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitRating,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}