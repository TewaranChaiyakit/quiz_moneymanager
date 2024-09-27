import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class SummaryScreen extends StatelessWidget {
  Future<Map<String, double>> _getIncomeExpenseData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('date', isGreaterThan: DateTime.now().subtract(Duration(days: 60)))
          .get();

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
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in.'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Summary')),
      body: FutureBuilder(
        future: _getIncomeExpenseData(),
        builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Map<String, double> data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: data['Income'] ?? 0,  // แก้ไขจาก 'y' เป็น 'toY'
                        color: Colors.green,
                        width: 30,  // เพิ่มความกว้างของแท่ง
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: data['Expense'] ?? 0,  // แก้ไขจาก 'y' เป็น 'toY'
                        color: Colors.red,
                        width: 30,  // เพิ่มความกว้างของแท่ง
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
