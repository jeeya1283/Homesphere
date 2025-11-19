import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();


  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      _firstNameController.text = (userData.data() as Map<String, dynamic>)['firstname'];
      _lastNameController.text = (userData.data() as Map<String, dynamic>)['lastname'];
      _email = (userData.data() as Map<String, dynamic>)['email'];
      _phoneController.text = (userData.data() as Map<String, dynamic>)['phoneNumber'];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (newValue) => _firstNameController.text = newValue!.trim(),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onSaved: (newValue) => _lastNameController.text = newValue!.trim(),
              ),
              SizedBox(height: 20.0),
              Text('Email: $_email'),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // Add phone number validation if required
                  return null;
                },
                onSaved: (newValue) => _phoneController.text = newValue!.trim(),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    User? user = FirebaseAuth.instance.currentUser;
                    try {
                      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                        'firstname': _firstNameController.text,
                        'lastname': _lastNameController.text,
                        'phoneNumber': _phoneController.text,
                      });
                      setState(() {

                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated successfully')),
                      );
                    } catch (e) {
                      print("Error updating profile: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile')),
                      );
                    }
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
