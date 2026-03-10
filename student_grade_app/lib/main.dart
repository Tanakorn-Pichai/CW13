import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: GradePage());
  }
}

class GradePage extends StatefulWidget {
  @override
  _GradePageState createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final keepController = TextEditingController();
  final midController = TextEditingController();
  final finalController = TextEditingController();

  double total = 0;
  String grade = "";

  String calculateGrade(double score) {
    if (score >= 80) return "A";
    if (score >= 70) return "B";
    if (score >= 60) return "C";
    if (score >= 50) return "D";

    return "F";
  }

  void calculate() {
    double keep = double.parse(keepController.text);
    double mid = double.parse(midController.text);
    double fin = double.parse(finalController.text);

    total = keep + mid + fin;

    grade = calculateGrade(total);

    setState(() {});
  }

  Future saveData() async {
    await FirebaseFirestore.instance.collection("students").add({
      "name": nameController.text,
      "subject": subjectController.text,
      "keep": keepController.text,
      "midterm": midController.text,
      "final": finalController.text,
      "total": total,
      "grade": grade,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Grade App")),

      body: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "ชื่อนักศึกษา"),
            ),

            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: "ชื่อวิชา"),
            ),

            TextField(
              controller: keepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "คะแนนเก็บ"),
            ),

            TextField(
              controller: midController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "คะแนนกลางภาค"),
            ),

            TextField(
              controller: finalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "คะแนนปลายภาค"),
            ),

            SizedBox(height: 20),

            ElevatedButton(onPressed: calculate, child: Text("คำนวณคะแนน")),

            SizedBox(height: 10),

            Text("คะแนนรวม: $total", style: TextStyle(fontSize: 18)),

            Text("เกรด: $grade", style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: saveData,
              child: Text("บันทึกลง Firebase"),
            ),

            SizedBox(height: 20),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("students")
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      var d = docs[index];

                      return Card(
                        child: ListTile(
                          title: Text(d["name"]),

                          subtitle: Text(
                            "${d["subject"]} | Total:${d["total"]} | Grade:${d["grade"]}",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
