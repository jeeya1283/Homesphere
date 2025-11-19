import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices{
  final CollectionReference propertyCollection = FirebaseFirestore.instance.collection('properties');
}