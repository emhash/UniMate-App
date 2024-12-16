import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:unimate/screens/pendings.dart';
import '../services/api_services.dart';
import '../screens/add_exam.dart';
import '../screens/exam_detail.dart';
import 'all_announcements_screen.dart';
import 'all_exams_screen.dart';
import 'auth/login_screen.dart';
import 'editExam.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String token;

  const HomeScreen({Key? key, required this.userEmail, required this.token})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiService _apiService;
  List<Map<String, dynamic>> upcomingExams = [];
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(token: widget.token);
    _loadData();
  }

  Map<String, dynamic>?
      profileData; // Add this at the beginning of the class (_HomeScreenState)

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // Fetch profile data
      final profile = await _apiService.getProfile();
      setState(() {
        profileData = profile['data']; // Update profileData
        // print("The profile data is: $profileData");
      });

      // Fetch upcoming exams and announcements
      final exams = await _apiService.getUpcomingExams();
      final announcs = await _apiService.getAnnouncements();
      setState(() {
        upcomingExams = exams;
        announcements = announcs;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteExam(String uid) async {
    try {
      await _apiService.deleteExam(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exam deleted successfully')),
      );
      _loadData(); // Refresh the list of exams
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete exam: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refreshPage, // Call the refresh function when pulled down
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: OvalBottomBorderClipper(),
                  child: Container(
                    height: 220,
                    color: Colors.blueAccent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Image
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              profileData?['image'] ??
                                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                            ),
                            radius: 40,
                          ),
                          const SizedBox(width: 12),
                          // Name, Email, and Additional Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  profileData?['name'] ?? 'Guest',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      "Intake: ${profileData?['intake'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Section: ${profileData?['section'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Department: ${profileData?['department'] ?? 'N/A'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            tooltip: 'Logout',
                            onPressed: () async {
                              final isLoggedOut = await _apiService.logout();
                              if (isLoggedOut) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Logout failed. Try again!')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pending Tasks',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTaskCard(
                                  'Exams',
                                  upcomingExams.length.toString(),
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTaskCard(
                                  'Assignments',
                                  '3',
                                  Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Upcoming Exams',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (upcomingExams.isEmpty)
                            const Center(
                              child: Text(
                                'No upcoming exams available.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: upcomingExams
                                  .map((exam) => _buildExamItem(exam))
                                  .toList(),
                            ),
                          const SizedBox(height: 24),
                          const Text(
                            'Announcements',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (announcements.isEmpty)
                            const Center(
                              child: Text(
                                'No announcements available.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: announcements
                                  .map((announcement) =>
                                      _buildAnnouncementItem(announcement))
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExamScreen(token: widget.token),
            ),
          );
          if (result == true) {
            _loadData(); // Refresh the data
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        tooltip: 'Add Exam',
      ),

// Inside the Widget build method
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Exams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            // New Bottom Bar Item
            icon: Icon(Icons.pending_actions),
            label: 'Pendings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            switch (index) {
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllExamsScreen(token: widget.token),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AllAnnouncementsScreen(token: widget.token),
                  ),
                );
                break;
              case 3: // Navigate to Pending Applications Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PendingApplicationsScreen(token: widget.token),
                  ),
                );
                break;
            }
          });
        },
      ),
    );
  }

  /// Refresh function
  Future<void> _refreshPage() async {
    // Reload data
    await _loadData();
  }

  Widget _buildTaskCard(String title, String count, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              title == 'Exams' ? Icons.book : Icons.assignment,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamItem(Map<String, dynamic> exam) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          exam['exam_name'] ?? '',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          exam['course_name'] ?? '',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamDetailScreen(
                        examId: exam['uid'], token: widget.token),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditExamScreen(token: widget.token, examDetails: exam),
                  ),
                ).then((value) {
                  // Refresh the list if the exam was edited
                  if (value == true) _loadData();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteExam(exam['uid']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(Map<String, dynamic> announcement) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          announcement['announcement'] ?? '',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          announcement['created_at'] ?? '',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
