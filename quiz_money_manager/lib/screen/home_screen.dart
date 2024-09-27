import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_transaction_screen.dart';
import 'signin_screen.dart'; // Import your SignInScreen

class HomeScreen extends StatelessWidget {
  Future<double> _getBalance() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .get();

      double totalBalance = 0;
      snapshot.docs.forEach((doc) {
        double amount = doc['amount'];
        String type = doc['type'];
        if (type == 'Income') {
          totalBalance += amount;
        } else {
          totalBalance -= amount;
        }
      });
      return totalBalance;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the user
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SigninScreen()), // Navigate to sign-in screen
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('transactions')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text('${doc['amount']} (${doc['type']})'),
                      subtitle: Text(doc['note']),
                      trailing: Text('${doc['date'].toDate()}'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          FutureBuilder(
            future: _getBalance(),
            builder: (context, AsyncSnapshot<double> snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Total Balance: ${snapshot.data}',
                  style: TextStyle(fontSize: 20),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
        },
      ),
    );
  }
}
