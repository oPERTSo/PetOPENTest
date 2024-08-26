import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/common_widget/round_button.dart';
import 'package:pettakecare/common_widget/round_icon_button.dart';
import 'package:pettakecare/common_widget/round_textfield.dart';
import 'package:pettakecare/view/login/rest_password_view.dart';
import 'package:pettakecare/view/login/sign_up.dart';
import 'package:pettakecare/view/on_boarding/on_boarding_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  String errorMessage = '';

  Future<void> loginUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User ID: ${userCredential.user?.uid}');
      setState(() {
        errorMessage = ''; // ล้างข้อความแสดงข้อผิดพลาดเมื่อเข้าสู่ระบบสำเร็จ
      });
      // เพิ่มการนำทางหรือฟังก์ชันอื่น ๆ ที่นี่หลังจากเข้าสู่ระบบสำเร็จ
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorMessage = e.toString(); // อัพเดทข้อความแสดงข้อผิดพลาด
      });
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // เริ่มกระบวนการตรวจสอบสิทธิ์
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // รับข้อมูลการตรวจสอบสิทธิ์จากคำขอ
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // สร้างข้อมูลรับรองใหม่
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // เมื่อเข้าสู่ระบบแล้ว ให้คืนค่า UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

              // ส่วนข้อความที่อยู่ตรงกลาง
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 30,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add your details to login",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              Text(
                "Your Email:",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              RoundTextfield(
                hintText: "Your Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),
              Text(
                "Password:",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundButton(
                  title: "Login",
                  onPressed: () async {
                    try {
                      await loginUser(txtEmail.text, txtPassword.text);
                      // ตรวจสอบว่าเข้าสู่ระบบสำเร็จหรือไม่
                      if (FirebaseAuth.instance.currentUser != null) {
                        // นำทางไปยังหน้าถัดไปหากเข้าสู่ระบบสำเร็จ
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnBoardingView(),
                          ),
                        );
                      } else {
                        // แสดงข้อความข้อผิดพลาดหรือจัดการกรณีที่เข้าสู่ระบบไม่สำเร็จ
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Login failed. Please try again.')),
                        );
                      }
                    } catch (e) {
                      print('Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }),
              const SizedBox(height: 16),
              if (errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordView(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot your password?",
                    style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpView(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an Account? ",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
