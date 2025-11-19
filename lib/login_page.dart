import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homesphere/auth.dart';
import 'package:homesphere/home_page.dart';
import 'package:homesphere/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(
                  height: 70,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Login Account',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.orange,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Please login with registered account',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.orange,
                    ),
                    label: Text('Enter Email'),
                  ),
                  onSaved: (value) => (_emailController.text = value ?? ''),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    prefixIcon: Icon(
                      Icons.key,
                      color: Colors.orange,
                    ),
                    label: Text('Enter Password'),
                  ),
                  onSaved: (value) => (_passwordController.text = value ?? ''),
                ),
                const SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {},
                    child: const Text('forgot password?'),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.orange,
                  ),
                  child: InkWell(
                    onTap: () async {
                      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                        final formState = _formKey.currentState;

                        if (formState!.validate()) {
                          formState.save();

                          try {
                            await _auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          } catch (e) {
                            const snackdemo = SnackBar(
                              content: Text('Invalid Credentials!'),
                              backgroundColor: Colors.red,
                              elevation: 10,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(5),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackdemo);
                          }
                        }
                      } else {
                        const snackdemo = SnackBar(
                          content: Text('Please enter value'),
                          backgroundColor: Colors.green,
                          elevation: 10,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(5),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackdemo);
                      }
                    },
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SignInButton(
                  Buttons.GoogleDark,
                  onPressed: () async {
                    await _authService.signInWithGoogle(context);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.grey,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(),
                        ),
                      );
                    },
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Create an Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
