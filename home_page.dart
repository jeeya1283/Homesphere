import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:homesphere/addProperty.dart';
import 'package:homesphere/admin_chat_list.dart';
import 'package:homesphere/chat_page.dart';
import 'package:homesphere/detail_page.dart';
import 'package:homesphere/login_page.dart';
import 'package:homesphere/profile.dart';
import 'package:homesphere/properties.dart';
import 'package:homesphere/viewProperty.dart';
import 'package:homesphere/wishlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  String _selectedOption = 'None';
  String? _selectedCategory;
  String? _adminId;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAdminId();
  }
  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void _getAdminId() async {
    final QuerySnapshot adminSnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: 'jeeyaroy1283@gmail.com').limit(1).get();
    if (adminSnapshot.docs.isNotEmpty) {
      setState(() {
        _adminId = adminSnapshot.docs.first.id;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Homesphere",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: Image.asset('assets/logo.png'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return (_auth.currentUser?.email == 'jeeyaroy1283@gmail.com')
                  ? [
                      PopupMenuItem(
                        child: Text('Properties'),
                        value: 'option1',
                      ),
                      PopupMenuItem(
                        child: Text('Profile'),
                        value: 'option2',
                      ),
                      PopupMenuItem(
                        child: Text('Chat'),
                        value: 'option3',
                      ),
                      PopupMenuItem(
                        child: Text('Wishlist'),
                        value: 'option4',
                      ),PopupMenuItem(
                        child: Text('LogOut'),
                        value: 'option5',
                      ),
                    ]
                  : [
                      PopupMenuItem(
                        child: Text('Profile'),
                        value: 'option2',
                      ),
                PopupMenuItem(
                  child: Text('Chat'),
                  value: 'option3',
                ),
                PopupMenuItem(
                  child: Text('Wishlist'),
                  value: 'option4',
                ),PopupMenuItem(
                  child: Text('LogOut'),
                  value: 'option5',
                ),
                    ];
            },
            onSelected: (value) async {
              // Handle menu item selection
              if (value == 'option1') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewProperties(),
                  ),
                );
              } else if (value == 'option2') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              } else if (value == 'option3') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>  FirebaseAuth.instance.currentUser?.email == "jeeyaroy1283@gmail.com"? AdminList(user: _auth.currentUser!) :ChatPage(userId: _auth.currentUser!.uid, recipientId: _adminId!,),
                  ),
                );
              }
              else if (value == 'option4') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>  WishlistPage(userId: _auth.currentUser!.uid),
                  ),
                );
              }
              else if (value == 'option5') {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              }
              print('Selected $value');
            },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,

                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Search by category...',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {

                          });
                          // _searchController.clear();
                          print('search');
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.orange,
                        ),
                      ),
                      label: Text('Search Property'),
                    ),
                    onChanged: (value) {
                      // Update selected category as user types
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.sort_by_alpha),
                              title: Text('Default'),
                              onTap: () {
                                setState(() {
                                  _selectedOption = 'default';
                                });
                                Navigator.pop(context);
                              },
                            ),ListTile(
                              leading: Icon(Icons.sort_by_alpha),
                              title: Text('Low to High'),
                              onTap: () {
                                setState(() {
                                  _selectedOption = 'low_to_high';
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.sort_by_alpha),
                              title: Text('High to Low'),
                              onTap: () {
                                setState(() {
                                  _selectedOption = 'high_to_low';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.filter_alt),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Featured Property',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _searchController.text == '' ? Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('properties').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                List<DocumentSnapshot> sortedData = snapshot.data!.docs;
                if (_selectedOption == 'low_to_high') {
                  sortedData.sort((a, b) => a['price'].compareTo(b['price']));
                } else if (_selectedOption == 'high_to_low') {
                  sortedData.sort((a, b) => b['price'].compareTo(a['price']));
                }else{
                  sortedData;
                }
                return ListView.builder(
                  itemCount: sortedData.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = sortedData[index];
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return FutureBuilder(
                      future: _getImageURL('property_${data['propertyId']}'),
                      builder: (context, AsyncSnapshot<String> urlSnapshot) {
                        if (urlSnapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox();
                        }
                        if (urlSnapshot.hasError) {
                          return Text('Error: ${urlSnapshot.error}');
                        }
                        if (!urlSnapshot.hasData) {
                          return Text('No image available');
                        }
                        String imageURL = urlSnapshot.data!;
                        return Card(
                          margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 6.0),
                          child: ListTile(
                            leading: imageURL.isEmpty ? Center(child: SizedBox(height: 10, width: 10,child: CircularProgressIndicator()),):Image.network(
                              imageURL,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            title: Text('${data['title']} \n'),
                            subtitle: Text(data['category']),
                            trailing: Text('\u{20B9} ${data['price']}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  title: data['title'],
                                  description: data['description'],
                                  price: data['price'],
                                  category: data['category'],
                                  propertyId:  data['propertyId'],
                                ),
                              ),
                            );
                          },
                          ),
                        );
                      }
                    );
                  },
                );
              },
            ),
          ):
          Expanded(
            child: StreamBuilder(
              stream:FirebaseFirestore.instance.collection('properties')
                  .where('search_category', isEqualTo: _selectedCategory!.toLowerCase())
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No results found'));
                }
                List<DocumentSnapshot> sortedData = snapshot.data!.docs;
                if (_selectedOption == 'low_to_high') {
                  sortedData.sort((a, b) => a['price'].compareTo(b['price']));
                } else if (_selectedOption == 'high_to_low') {
                  sortedData.sort((a, b) => b['price'].compareTo(a['price']));
                }else{
                  sortedData;
                }
                return ListView.builder(
                  itemCount: sortedData.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = sortedData[index];
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return FutureBuilder(
                        future: _getImageURL('property_${data['propertyId']}'),
                        builder: (context, AsyncSnapshot<String> urlSnapshot) {
                          if (urlSnapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox();
                          }
                          if (urlSnapshot.hasError) {
                            return Text('Error: ${urlSnapshot.error}');
                          }
                          if (!urlSnapshot.hasData) {
                            return Text('No image available');
                          }
                          String imageURL = urlSnapshot.data!;

                        return Card(
                          margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 6.0),
                          child: ListTile(
                            leading:
                            imageURL.isEmpty ? Center(child: SizedBox(height: 10, width: 10,child: CircularProgressIndicator()),):Image.network(
                              imageURL,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            title: Text(data['title']),
                            trailing: Text('\u{20B9} ${data['price']}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    title: data['title'],
                                    description: data['description'],price: data['price'],
                                    category: data['category'],
                                    propertyId:  data['propertyId'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getImageURL(String imageID) async {
    try {
      print("-------id------$imageID");
      final storageRef = FirebaseStorage.instance.ref().child(imageID);
      print(storageRef);
      final listResult = await storageRef.listAll();

      for (var prefix in listResult.items) {
        String message = await prefix.getDownloadURL();
        return message;
      }
      return ''; // Return default value if no image found
    } catch (e) {
      print('Error fetching image URL: $e');
      return ''; // Return default value if error occurs
    }
  }
}
