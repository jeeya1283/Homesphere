import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homesphere/detail_page.dart';

class WishlistPage extends StatelessWidget {
  final String userId;

  WishlistPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('wishlist').doc(userId).collection('property').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<DocumentSnapshot> wishlistDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: wishlistDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = wishlistDocs[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('properties').doc(doc['propertyId']).get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (productSnapshot.hasError) {
                    return Text('Error: ${productSnapshot.error}');
                  }
                  Map<String, dynamic> productData = productSnapshot.data!.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 6.0),
                    child: ListTile(

                      title: Text('${productData['title']} \n'),
                      subtitle: Text(productData['category']),
                      trailing: Text('\u{20B9} ${productData['price']}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              title: productData['title'],
                              description: productData['description'],
                              price: productData['price'],
                              category: productData['category'],
                              propertyId:  productData['propertyId'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
