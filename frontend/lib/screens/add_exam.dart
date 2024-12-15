import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AddExamScreen extends StatefulWidget {
  final String token;

  const AddExamScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AddExamScreenState createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examNameController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _topicController = TextEditingController();
  final _detailController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Exam', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam Name
              Text(
                'Exam Name',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                dropdownColor:
                    Colors.white, // Changed to solid white for better contrast
                style: TextStyle(
                    color: Colors.black), // Updated text color for visibility
                items: [
                  'Class Test',
                  'Quiz Test',
                  'Mid Term',
                  'Final Test',
                  'Lab Mid',
                  'Lab Evaluation'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(color: Colors.green)), // Optional
                  );
                }).toList(),
                onChanged: (value) {
                  _examNameController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an exam type';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Date
              Text(
                'Date',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.green),
                ),
                style: TextStyle(color: Colors.green),
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                      : '',
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Course Name
              Text(
                'Course Name',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _courseNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.green),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Course Code
              Text(
                'Course Code',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _courseCodeController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.green),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Topic
              Text(
                'Topic',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.green),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter topic';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Details
              Text(
                'Details',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _detailController,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.green),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService(token: widget.token);
        final success = await apiService.addExam(
          examName: _examNameController.text,
          courseName: _courseNameController.text,
          courseCode: _courseCodeController.text,
          date: _selectedDate!,
          topic: _topicController.text,
          detail: _detailController.text,
        );

        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add exam. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _topicController.dispose();
    _detailController.dispose();
    super.dispose();
  }
}
