import 'package:chatapp/pages/otpVerification_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onTapLogin;
  const RegisterPage({Key? key, this.onTapLogin}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();

  int currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void signUp() async {
    final phone = "+91${phoneController.text.trim()}";
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.verifyPhoneNumber(phone, (verificationId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
                verificationId: verificationId,
                onVerified: () async {
                  await authService.signUpWithEmailandPassword(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );

                  await authService.saveUserDetailsToFirestore(
                    username: usernameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    dob: dobController.text.trim(),
                  );

                  Navigator.popUntil(context, (route) => route.isFirst);
                }),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void nextStep() {
    if (currentStep < 4) {
      setState(() => currentStep++);
    } else {
      signUp();
    }
  }

  Widget getCurrentStepWidget() {
    switch (currentStep) {
      case 0:
        return _buildTextField(
          controller: usernameController,
          hintText: "Username",
          icon: Icons.person,
        );
      case 1:
        return _buildTextField(
          controller: phoneController,
          hintText: "Phone Number",
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        );
      case 2:
        return _buildTextField(
          controller: emailController,
          hintText: "Email",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        );
      case 3:
        return _buildTextField(
          controller: passwordController,
          hintText: "Password",
          icon: Icons.lock_outline,
          obscureText: true,
        );
      case 4:
        return _buildTextField(
          controller: dobController,
          hintText: "Date of Birth (dd/mm/yyyy)",
          icon: Icons.cake,
          keyboardType: TextInputType.datetime,
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade800, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_outlined,
                      size: 90, color: Colors.white),
                  SizedBox(height: 40),
                  Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 45),
                  getCurrentStepWidget(),
                  SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black45,
                      ),
                      child: Text(
                        currentStep < 4 ? "Next" : "Sign Up",
                        style: TextStyle(
                          color: Colors.deepPurple.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already a member? ",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 15)),
                      GestureDetector(
                        onTap: widget.onTapLogin,
                        child: Text(
                          "Login now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
    );
  }
}
