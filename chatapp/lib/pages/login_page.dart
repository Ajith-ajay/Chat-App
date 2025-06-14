import 'package:chatapp/pages/otpVerification_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onTapRegister;
  const LoginPage({Key? key, this.onTapRegister}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool usePhone = false;
  bool otpSent = false;

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
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (usePhone) {
      final phone = "+91${phoneController.text.trim()}";
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.verifyPhoneNumber(phone, (verificationId) {
          print("Ajithotp: " + verificationId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(
                verificationId: verificationId,
                onVerified: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          );
        });
      } catch (e) {
        _showSnack(e.toString());
      }
      _showSnack("Phone Number Verified Successfully");
    } else {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        _showSnack("Please enter email and password");
        return;
      }
      try {
        await authService.signInWithEmailandPassword(
            emailController.text.trim(), passwordController.text.trim());
      } catch (e) {
        _showSnack(e.toString());
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                  Icon(Icons.message_outlined, size: 90, color: Colors.white),
                  SizedBox(height: 40),
                  Text(
                    "Welcome back, you've been missed!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 45),
                  if (usePhone)
                    _buildTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    )
                  else ...[
                    _buildTextField(
                      controller: emailController,
                      hintText: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: passwordController,
                      hintText: "Password",
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                  ],
                  SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        elevation: 8,
                        shadowColor: Colors.black45,
                      ),
                      child: Text(
                        usePhone ? "Send OTP" : "Sign In",
                        style: TextStyle(
                          color: Colors.deepPurple.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () => setState(() => usePhone = !usePhone),
                    child: Text(
                      usePhone
                          ? "Use Email/Password Login"
                          : "Use Phone Number Login",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Not a member? ",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 15)),
                      GestureDetector(
                        onTap: widget.onTapRegister,
                        child: Text("Register now",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: TextDecoration.underline)),
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
