import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final String category;
  final String propertyId;

  DetailPage({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.propertyId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<String> listOfImageUrl = List.empty(growable: true);
  double _rating = 0.0;
  String _review = '';
  bool _isCollected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWishlist();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Detail'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          // height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category: ${widget.category}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () async {
                        setState(() {
                          _isCollected = !_isCollected;
                          addToWishList();
                        });
                      },
                      icon: Icon(_isCollected ? Icons.favorite : Icons.favorite_border),
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 350,
                child: FutureBuilder(
                    future: _getImageURL(widget.propertyId),
                    builder: (context, AsyncSnapshot<String> urlSnapshot) {
                      return ListView.builder(
                        itemCount: listOfImageUrl.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              listOfImageUrl[index],
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    }),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u{20B9} ${widget.price}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Title - ${widget.title}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Description - ${widget.description}'),
                    // Add more details here as needed
                  ],
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    const double latitude = 21.1725336;
                    const double longitude = 72.7867589;
                    const url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Image.asset(
                    'assets/surat.jpeg',
                    width: double.maxFinite,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Rating: '),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30,
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
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Write a review...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  onChanged: (value) {
                    setState(() {
                      _review = value;
                    });
                  },
                ),
              ),
              // Add submit button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance.collection('reviews').add({
                        'propertyId': widget.propertyId,
                        'title': widget.title,
                        'rating': _rating,
                        'review': _review,
                        'timestamp': Timestamp.now(),
                      });
                      // You can also update the rating for the property if needed
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Rating and review submitted successfully.'),
                      ));
                    } catch (e) {
                      print('Error submitting rating and review: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to submit rating and review.'),
                      ));
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('reviews').where('propertyId', isEqualTo: widget.propertyId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No reviews available.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot document = snapshot.data!.docs[index];
                          final data = document.data() as Map<String, dynamic>;
                          final rating = data['rating'] as double;
                          final review = data['review'] as String;
                          return ListTile(
                            title: Text('Rating: $rating'),
                            subtitle: Text('Review: $review'),
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getImageURL(String imageID) async {
    try {
      listOfImageUrl.clear();
      print("-------id------$imageID");
      final storageRef = FirebaseStorage.instance.ref().child('property_$imageID');
      print(storageRef);
      final listResult = await storageRef.listAll();

      for (var prefix in listResult.items) {
        String message = await prefix.getDownloadURL();
        listOfImageUrl.add(message);
      }
      return ''; // Return default value if no image found
    } catch (e) {
      print('Error fetching image URL: $e');
      return ''; // Return default value if error occurs
    }
  }

  Future<void> addToWishList() async {
    if (_isCollected == true) {
      await FirebaseFirestore.instance.collection('wishlist').doc(FirebaseAuth.instance.currentUser!.uid).collection("property").doc("property${widget.propertyId}").set({
        'propertyId': widget.propertyId,
      });
    } else {
      await FirebaseFirestore.instance.collection('wishlist').doc(FirebaseAuth.instance.currentUser!.uid).collection("property").doc("property${widget.propertyId}").delete();
    }
  }

  Future<void> getWishlist() async {


    final docSnapshot = await FirebaseFirestore.instance
        .collection('wishlist')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('property').doc("property${widget.propertyId}").get();

    setState(() {
      _isCollected = docSnapshot.exists;
    });
  }
}
