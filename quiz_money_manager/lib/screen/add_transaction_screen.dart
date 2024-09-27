import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isEdit;
  final String transactionId;
  final String initialAmount;
  final String initialType;
  final String initialNote;
  final DateTime initialDate;

  AddTransactionScreen({
    this.isEdit = false,
    this.transactionId = '',
    this.initialAmount = '',
    this.initialType = 'Income',
    this.initialNote = '',
    DateTime? initialDate,
  }) : initialDate = initialDate ?? DateTime.now();

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _amount = '';
  String _note = '';
  String _type = 'Income'; // Default type
  DateTime _selectedDate;

  _AddTransactionScreenState() : _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
    _type = widget.initialType;
    _note = widget.initialNote;
    _selectedDate = widget.initialDate;
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (widget.isEdit) {
          // Update existing transaction
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .doc(widget.transactionId)
              .update({
            'amount': double.parse(_amount),
            'type': _type,
            'note': _note,
            'date': Timestamp.fromDate(_selectedDate), // Convert to Timestamp
          });
        } else {
          // Add new transaction
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .add({
            'amount': double.parse(_amount),
            'type': _type,
            'note': _note,
            'date': Timestamp.fromDate(_selectedDate), // Convert to Timestamp
          });
        }
        Navigator.pop(context); // Return to the previous screen
      }
    }
  }

  _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
                onSaved: (value) => _amount = value!,
                initialValue: _amount,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Income', 'Expense']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Note'),
                onSaved: (value) => _note = value!,
                initialValue: _note,
              ),
              Row(
                children: [
                  Expanded(child: Text('Date: ${_selectedDate.toLocal()}')),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Pick a Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTransaction,
                child: Text(widget.isEdit ? 'Update Transaction' : 'Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
