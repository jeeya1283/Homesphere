import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homesphere/home_page.dart';
import 'package:homesphere/login_page.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.orange,
                      fontSize: 30,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),
                    label: Text('Enter First Name'),
                  ),
                  onSaved: (value) => (_firstNameController.text = value ?? ''),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),
                    label: Text('Enter Last Name'),
                  ),
                  onSaved: (value) => (_lastNameController.text = value ?? ''),
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.orange,
                    ),
                    label: Text('Enter Phone Number'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    } else if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null; // Return null if the input is valid
                  },
                  onSaved: (value) => (_phoneController.text = value ?? ''),
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
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
                    label: Text('Enter Confirm Password'),
                  ),
                  validator: (value) {
                    if (_passwordController.text != value) {
                      return 'Password doesn\'t match';
                    }
                  },
                  onSaved: (value) => (_confirmPasswordController.text = value ?? ''),
                ),
                SizedBox(height: 20),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.orange,
                  ),
                  child: InkWell(
                    onTap: () async {
                      if (_firstNameController.text.isNotEmpty &&
                          _lastNameController.text.isNotEmpty &&
                          _emailController.text.isNotEmpty &&
                          _phoneController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty) {
                        final formState = _formKey.currentState;
                        if (formState!.validate()) {
                          formState.save();
                          try {
                            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);

                            // Add user data to Firestore
                            await _firestore.collection('users').doc(userCredential.user?.uid).set({
                              'firstname': _firstNameController.text,
                              'lastname': _lastNameController.text,
                              'email': _emailController.text,
                              'phoneNumber': _phoneController.text,
                            });

                            // Navigate to home page or wherever after registration
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          } catch (e) {
                            print(e.toString());
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
                    child: Align(
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
                SizedBox(height: 20),
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
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Back to Login',
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
