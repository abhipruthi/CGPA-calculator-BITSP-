import 'package:flutter/material.dart';

void main() {
  runApp(GPACalculatorApp());
}

class Course {
  String courseName;
  String courseCode;
  String grade;
  double credit;

  Course({
    required this.courseName,
    required this.courseCode,
    required this.grade,
    required this.credit,
  });
}

class Semester {
  List<Course> courses = [];
  double sgpa = 0.0;
  double totalCredits = 0.0;
}

class MyAppState extends ChangeNotifier {
  List<Semester> semesters = [];
}

class GPACalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GPACalculator(),
    );
  }
}

class GPACalculator extends StatefulWidget {
  @override
  _GPACalculatorState createState() => _GPACalculatorState();
}

class _GPACalculatorState extends State<GPACalculator> {
  final MyAppState appState = MyAppState();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  List<String> grades = ['A', 'A-', 'B', 'B-', 'C', 'C-', 'D', 'E', 'NC'];
  Map<String, double> gradePoints = {
    'A': 10.0,
    'A-': 9.0,
    'B': 8.0,
    'B-': 7.0,
    'C': 6.0,
    'C-': 5.0,
    'D': 4.0,
    'E': 2.0,
    'NC': 0.0,
  };
  double overallCGPA = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPA Calculator (BITS Pilani)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: appState.semesters.asMap().entries.map((entry) {
                int semesterIndex = entry.key;
                Semester semester = entry.value;

                return Column(
                  children: [
                    ListTile(
                      title: Text('Semester ${semesterIndex + 1}'),
                      subtitle: Text('Credits: ${semester.totalCredits.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                appState.semesters.removeAt(semesterIndex);
                                overallCGPA = calculateOverallCGPA();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: semester.courses.asMap().entries.map((courseEntry) {
                        int courseIndex = courseEntry.key;
                        Course course = courseEntry.value;

                        return ListTile(
                          title: Text(
                            '${course.courseName} (${course.courseCode}) - ${course.grade} - ${course.credit} credits',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    semester.courses.removeAt(courseIndex);
                                    semester.totalCredits -= course.credit;
                                    calculateSGPA(semester);
                                    overallCGPA = calculateOverallCGPA();
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Text('SGPA: ${semester.sgpa.toStringAsFixed(2)}'),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text('Overall CGPA: ${overallCGPA.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addSemester();
              },
              child: Text('Add Semester'),
            ),
            ElevatedButton(
              onPressed: () {
                addCourse();
              },
              child: Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }

  double calculateOverallCGPA() {
    double totalGradePoints = 0.0;
    double totalCredits = 0.0;

    for (var semester in appState.semesters) {
      totalGradePoints += semester.sgpa * semester.totalCredits;
      totalCredits += semester.totalCredits;
    }

    return totalGradePoints / totalCredits;
  }

  void addCourse() {
    showDialog(
      context: context,
      builder: (context) {
        String courseName = '';
        String courseCode = '';
        String grade = '';
        double credit = 0.0;

        return AlertDialog(
          title: Text('Add Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => courseName = value,
                  decoration: InputDecoration(labelText: 'Course Name'),
                ),
                TextField(
                  onChanged: (value) => courseCode = value,
                  decoration: InputDecoration(labelText: 'Course Code'),
                ),
                TextField(
                  onChanged: (value) => grade = value,
                  decoration: InputDecoration(labelText: 'Grade (A, A-, B, B-, C, C-, D, E, NC)'),
                ),
                TextField(
                  onChanged: (value) => credit = double.tryParse(value) ?? 0.0,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Credit Hours'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (courseName.isNotEmpty && courseCode.isNotEmpty && grades.contains(grade) && credit > 0) {
                  int selectedSemesterIndex = appState.semesters.length - 1;
                  appState.semesters[selectedSemesterIndex].courses.add(
                    Course(
                      courseName: courseName,
                      courseCode: courseCode,
                      grade: grade,
                      credit: credit,
                    ),
                  );
                  appState.semesters[selectedSemesterIndex].totalCredits += credit;

                  calculateSGPA(appState.semesters[selectedSemesterIndex]);
                  overallCGPA = calculateOverallCGPA();
                  Navigator.pop(context);
                } else {
                  showInvalidInputError();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addSemester() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Semester'),
          content: Text('Are you sure you want to add a new semester?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                appState.semesters.add(Semester());
                overallCGPA = calculateOverallCGPA();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showInvalidInputError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Input'),
          content: Text('Please enter valid input.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void calculateSGPA(Semester semester) {
    double totalGradePoints = 0.0;
    double totalCredits = 0.0;

    for (var course in semester.courses) {
      totalGradePoints += gradePoints[course.grade]! * course.credit;
      totalCredits += course.credit;
    }

    setState(() {
      semester.sgpa = totalGradePoints / totalCredits;
      semester.totalCredits = totalCredits;
    });
  }
}