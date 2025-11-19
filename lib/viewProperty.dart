import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homesphere/addProperty.dart';

class ViewProperties extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property List'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProperty()),
        );
      },
      child: Icon(Icons.add)),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('properties').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 6.0),
                child: ListTile(
                  title: Text(data['category']),
                  subtitle: Text(data['title']),
                  trailing: Text('\u{20B9} ${data['price']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddProperty(data:data)),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class EditItemPage extends StatelessWidget {
  final DocumentSnapshot document;

  EditItemPage(this.document);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Delete the item from Firestore
              FirebaseFirestore.instance.collection('items').doc(document.id).delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${document['title']}'),
            Text('Description: ${document['description']}'),
            Text('Price: \$${document['price']}'),
            // Add form fields here for editing
          ],
        ),
      ),
    );
  }
}
