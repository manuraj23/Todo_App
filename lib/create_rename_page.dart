import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controller/task_handler.dart';

class TaskListPage extends StatelessWidget {
  final String title; // Page title
  final String initialText; // Initial text for the text field
  final Function(String) onDone; // Callback for when "Done" is clicked
  final Color doneButtonColor; // Color of the "Done" button
  final String selectedTask; // The selected task
  var titleText = TextEditingController();
  TaskHandler _taskHandler = new TaskHandler();
  TaskListPage({
    required this.title,
    required this.initialText,
    required this.onDone,
    required this.doneButtonColor,
    required this.selectedTask,
  }) {
    titleText = TextEditingController(text: initialText);
  }
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 22, 25, 22),
        leading: IconButton(
          icon: Icon(
            Icons.close, // Use the close icon (cross)
            color: Color.fromARGB(200, 255, 255, 255), // Set the color to white
          ),
          onPressed: () {
            onDone(selectedTask);
            Navigator.pop(context, "done");
          },
        ),
        actions: [
          TextButton(
            onPressed: () async{
              if(titleText.text.trim().isNotEmpty){
                switch (title) {
                  case 'Create new list':
                    _taskHandler.saveTask(titleText: titleText.text);
                    break;
                  case 'Rename List':
                    bool success = await _taskHandler.renameCollection(oldCollectionName: selectedTask, newCollectionName: titleText.text);
                    if(success){
                      print("Collection renamed successfully");
                    }else{
                      print("Error renaming collection");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task list name already exists'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        ),
                      );
                    }
                    break;
                  default:
                    break;
                }
                onDone(titleText.text);
                Navigator.pop(context, "done");
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: doneButtonColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: GoogleFonts.afacad(
              textStyle: TextStyle(color: Colors.white,fontSize: 25.0,),
            ),
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 22, 25, 22),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(15.0),
                child:TextField(
                  controller: titleText,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent.withAlpha(200), width: 1.5), // Blue border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent.withAlpha(200), width: 1.5), // Blue border when focused
                    ),
                    border: OutlineInputBorder(), // Default border when not focused
                    hintText: 'Enter list title', // Optional hint text
                    hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w300), // Optional hint text style
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
