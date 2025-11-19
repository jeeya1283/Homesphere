import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:homesphere/firebase_methods.dart';
import 'package:homesphere/viewProperty.dart';

class AddProperty extends StatefulWidget {
  final Map<String, dynamic>? data;

  const AddProperty({super.key, this.data});

  @override
  State<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String storageUrl = '';
  String? propertyId;
  String? _title;
  String? _description;
  String? _price;
  String? _category;
  String? _city;

  List<String> _categories = ['Home', 'Building', 'Town houses'];
  List propertyImages = List.empty(growable: true);
  List<String> listOfImageUrl = List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final docRef = DatabaseServices().propertyCollection;
    if (widget.data == null) {
      propertyId = docRef.doc().id;
    }
    if (widget.data != null) {
      _title = widget.data?['title'];
      _description = widget.data?['description'];
      _price = widget.data?['price'];
      propertyId = widget.data?['propertyId'];
      _category = widget.data?['category'];
      _city = widget.data?['city'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Property'),
      ),
      body: FutureBuilder(
        future: getImage(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField(
                      value: _category,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    TextFormField(
                      initialValue: _title ?? '',
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value!;
                      },
                    ),
                    TextFormField(
                      initialValue: _description ?? '',
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value!;
                      },
                    ),
                    TextFormField(
                      initialValue: _price,
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter price';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _price = value!;
                      },
                    ),
                    TextFormField(
                      initialValue: _city,
                      decoration: InputDecoration(labelText: 'City'),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _city = value!;
                      },
                    ),
                    FormBuilderImagePicker(
                      name: 'photos',
                      displayCustomType: (obj) => obj is ApiImage ? obj.imageUrl : obj,
                      decoration: const InputDecoration(labelText: 'Pick Photos'),
                      maxImages: 5,
                      previewAutoSizeWidth: true,
                      previewMargin: const EdgeInsetsDirectional.only(end: 8),
                      fit: BoxFit.cover,
                      imageQuality: 55,
                      onSaved: (List<dynamic>? newValue) async {
                        for (int i = 0; i < newValue!.length; i++) {
                          if (newValue.elementAt(i).runtimeType != String) propertyImages.add(await newValue.elementAt(i).readAsBytes());
                        }
                      },
                      onChanged: (List<dynamic>? value) async {
                        for (var e in listOfImageUrl) {
                          if (!value!.contains(e)) {
                            final storageRef = FirebaseStorage.instance.refFromURL(e);
                            // storageRef.child(Uri.parse(e).pathSegments.last);
                            storageRef.delete();
                          }
                        }
                      },
                      initialValue: listOfImageUrl,
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState!.save();

                            if (widget.data != null) {
                              await _firestore.collection('properties').doc(propertyId).update({
                                'propertyId': propertyId,
                                'category': _category,
                                'search_category': _category!.toLowerCase(),
                                'title': _title,
                                'description': _description,
                                'price': _price,
                                'city': _city,
                              }).then((_) {
                                Navigator.pop(context);
                                // Navigator.of(context).pushReplacement(
                                //   MaterialPageRoute(
                                //     builder: (context) => ViewProperties(),
                                //   ),
                                // );
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Property updated'),
                                ));
                                // Clear the form after successful submission
                                _formKey.currentState!.reset();
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Failed to add Property: $error'),
                                ));
                              });
                            } else {
                              await _firestore.collection('properties').doc(propertyId).set({
                                'propertyId': propertyId,
                                'title': _title,
                                'description': _description,
                                'price': _price,
                                'city': _city,
                                'category': _category,
                                'search_category': _category!.toLowerCase(),
                                // 'imageUrl': storageUrl ?? '',
                              }).then((_) {
                                Navigator.pop(context);
                                // Navigator.of(context).pushReplacement(
                                //   MaterialPageRoute(
                                //     builder: (context) => ViewProperties(),
                                //   ),
                                // );
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Property added '),
                                ));
                                // Clear the form after successful submission
                                _formKey.currentState!.reset();
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Failed to add Property: $error'),
                                ));
                              });
                            }

                            Reference ref = FirebaseStorage.instance.ref().child("property_$propertyId");

                            for (int i = 0; i < propertyImages.length; i++) {
                              Uint8List? imageData = await propertyImages[i];
                              if (imageData != null) {
                                int index = listOfImageUrl.length + i;
                                UploadTask uploadTask = ref.child(index.toString()).putData(imageData, SettableMetadata(contentType: 'image/png'));

                                TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {
                                  // print('done');
                                }).catchError((error) {
                                  // print('Something went wrong');
                                  return error;
                                });

                                // Navigator.pop(context);
                                String url = await taskSnapshot.ref.getDownloadURL();
                                // print(url);
                              }
                            }
                          }
                        },
                        child: Text(widget.data != null ?'Update Property':'Insert Property'),
                      ),
                    ),
                    SizedBox(height: 20),
                    widget.data?['propertyId'] != null
                        ? Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () async {
                                await FirebaseStorage.instance.ref("property_${widget.data?['propertyId']}").listAll().then((value) {
                                  FirebaseStorage.instance.ref(value.items.first.fullPath).delete().then((value) async {
                                    await _firestore.collection('properties').doc(propertyId).delete().then((value) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => ViewProperties(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Property Deleted'),
                                      ));
                                    });
                                  });
                                });
                                print('success');
                              },
                              child: Text('Delete Property'),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Future<void> getImage() async {
    final storageRef = FirebaseStorage.instance.ref().child("property_$propertyId");
    print(storageRef);
    final listResult = await storageRef.listAll();

    for (var prefix in listResult.items) {
      String message = await prefix.getDownloadURL();
      listOfImageUrl.add(message);
    }
  }
}

class ApiImage {
  final String imageUrl;
  final String id;

  ApiImage({
    required this.imageUrl,
    required this.id,
  });
}
