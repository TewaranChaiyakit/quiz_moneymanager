import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_transaction_screen.dart';
import 'signin_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  Stream<Map<String, double>> _getIncomeExpenseDataStream() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Listen for changes in the transactions collection
      yield* FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .snapshots()
          .map((snapshot) {
        double totalIncome = 0;
        double totalExpense = 0;
        snapshot.docs.forEach((doc) {
          double amount = doc['amount'];
          String type = doc['type'];
          if (type == 'Income') {
            totalIncome += amount;
          } else {
            totalExpense += amount;
          }
        });
        return {'Income': totalIncome, 'Expense': totalExpense};
      });
    } else {
      yield {'Income': 0, 'Expense': 0};
    }
  }

  Future<void> _deleteTransaction(String transactionId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    }
  }

  void _editTransaction(BuildContext context, DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          isEdit: true,
          transactionId: doc.id,
          initialAmount: doc['amount'].toString(),
          initialType: doc['type'],
          initialNote: doc['note'],
          initialDate: doc['date'].toDate(),
        ),
      ),
    );
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
                    String type = doc['type'];
                    Color highlightColor = type == 'Income' ? Colors.green[100]! : Colors.red[100]!;
                    return Container(
                      color: highlightColor,
                      child: ListTile(
                        title: Text('${doc['amount'].toStringAsFixed(2)} THB (${doc['type']})'),
                        subtitle: Text(doc['note']),
                        trailing: Text('${doc['date'].toDate()}'),
                        onTap: () => _editTransaction(context, doc), // Edit transaction on tap
                        leading: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Confirm before deleting
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text('Are you sure you want to delete this transaction?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        _deleteTransaction(doc.id); // Delete transaction
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                      child: Text('Yes'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(), // Close dialog
                                      child: Text('No'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          StreamBuilder<Map<String, double>>(
            stream: _getIncomeExpenseDataStream(),
            builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }
              double totalIncome = snapshot.data!['Income'] ?? 0;
              double totalExpense = snapshot.data!['Expense'] ?? 0;
              double totalBalance = totalIncome - totalExpense;

              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Total Income: ${totalIncome.toStringAsFixed(2)} THB',
                        style: TextStyle(fontSize: 20, color: Colors.green[800]),
                      ),
                    ),
                    SizedBox(height: 10), // Spacing between highlights
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Total Expense: ${totalExpense.toStringAsFixed(2)} THB',
                        style: TextStyle(fontSize: 20, color: Colors.red[800]),
                      ),
                    ),
                    SizedBox(height: 10), // Spacing between highlights
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Total Balance: ${totalBalance.toStringAsFixed(2)} THB',
                        style: TextStyle(fontSize: 20, color: Colors.blue[800]),
                      ),
                    ),
                  ],
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
