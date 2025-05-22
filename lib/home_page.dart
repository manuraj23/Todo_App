// import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/profile.dart';
import 'Widgets/task_tile_viewer.dart';
import 'create_rename_page.dart';
import 'new_list.dart';
import 'package:todo_app/controller/task_handler.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  final taskHandler = TaskHandler();
  bool description_field_enabler = false;
  bool star_icon_enabler = false;
  bool showCompletedTasks = false;
  String? selectedTask = "My Tasks"; // Variable to keep track of the selected task
  // Define the specific date and time you want to check for
  final specificDateTime = DateTime(2000, 1, 1, 0, 0, 0); // "2000-01-01 00:00:00" used in the case of no date selected by user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: kToolbarHeight,
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Tasks',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: FirebaseAuth.instance.currentUser?.photoURL != null
                        ? Image.network(
                      FirebaseAuth.instance.currentUser!.photoURL!,
                      width: 35,
                      height: 35,
                    )
                        : Image.asset(
                      'assets/images/profile_image.png',
                      width: 35,
                      height: 35,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        child: Container(
          margin: EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: EdgeInsets.only(left: 0, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print("Star button pressed");
                                    print(selectedTask);
                                    setState(() {
                                      selectedTask="Starred";
                                    });
                                    print(selectedTask);  //added this line just to check if everything is working fine
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 15.0),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userEmail)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }

                                    if (!snapshot.hasData || !snapshot.data!.exists) {
                                      return Center(
                                        child: Text(
                                          '', // No tasks available
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }

                                    final taskList = snapshot.data!.data()?['tasks'];
                                    if (taskList == null || taskList.isEmpty) {
                                      return Center(
                                        child: Text(
                                          '', // No tasks available
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: taskList.map<Widget>((task) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedTask = task; // Update selected task
                                              });
                                            },
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 15, right: 15),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      task.toString(),
                                                      style: TextStyle(
                                                        color: selectedTask == task
                                                            ? Colors.blue.shade300
                                                            : Colors.white,
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 12),
                                                    // Conditionally render the Container only if the task is selected
                                                    if (selectedTask == task)
                                                      Container(
                                                        width: 60,
                                                        height: 3,
                                                        decoration: BoxDecoration(
                                                          color: Colors.blueAccent, // Blue color when selected
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(10),
                                                            topRight: Radius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TaskListPage(
                                          title: "Create new list",
                                          initialText: "", // Replace with the actual current name
                                          doneButtonColor: Colors.grey,
                                          selectedTask: selectedTask!,
                                          onDone: (updatedListName) {
                                            // Handle the logic for renaming the list
                                              setState(() {
                                                selectedTask=updatedListName;
                                              });
                                            print("Renamed to: $updatedListName");
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 15.0, left: 15),
                                      child: Text(
                                        "+ New list",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            borderRadius: BorderRadius.circular(15),
                          ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top:20.0,left: 20,right: 20),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left:10.0),
                                          child: Text(
                                            selectedTask ?? 'No task selected',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Spacer(), // This will push the following icons to the right
                                        Icon(
                                          Icons.swap_vert,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10), // Optional spacing between icons
                                        IconButton(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(15),
                                                ),
                                              ),
                                              backgroundColor: Colors.grey[900]!.withAlpha(180),
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(15.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min, // Set the size to the minimum needed
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ListTile(
                                                        title: Text(
                                                          'Rename list',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        onTap: () {
                                                          // Close the bottom sheet first
                                                          print(selectedTask);

                                                          Navigator.pop(context);

                                                          // Then navigate to the TaskListPage
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => TaskListPage(
                                                                title: "Rename List",
                                                                initialText: selectedTask!, // Replace with the actual current name
                                                                doneButtonColor: Colors.blueAccent.withAlpha(250),
                                                                selectedTask: selectedTask!,
                                                                onDone: (updatedListName) {
                                                                  // Handle the logic for renaming the list
                                                                  setState(() {
                                                                    selectedTask=updatedListName;
                                                                  });
                                                                  print("Renamed to: $updatedListName");
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          'Delete list',
                                                          style: (selectedTask=="My Tasks")?TextStyle(color: Colors.white.withAlpha(100)):TextStyle(color: Colors.white),
                                                        ),
                                                        // add description
                                                        subtitle: (selectedTask=="My Tasks")?Text(
                                                          "Default list can't be deleted",
                                                          style: (selectedTask=="My Tasks")?TextStyle(color: Colors.white.withAlpha(100),fontSize: 12):TextStyle(color: Colors.white,fontSize: 12),
                                                        ):null,
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          // Handle delete list action
                                                          if (selectedTask != "My Tasks") {
                                                            if(await taskHandler.deleteTask(selectedTask)){
                                                              setState(() {
                                                                selectedTask="My Tasks";
                                                              });

                                                              print("Task deleted successfully main");

                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text('Task deleted successfully'),
                                                                  duration: Duration(seconds: 2),
                                                                  behavior: SnackBarBehavior.floating,
                                                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                                                ),
                                                              );
                                                            }
                                                            else{
                                                              print("Task deletion failed");
                                                            }
                                                          }
                                                        },
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          'Delete all completed tasks',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          // Handle delete completed tasks action
                                                          bool deleted = await taskHandler.delete_completed_task(selectedTask!);
                                                          if (deleted) {
                                                            print("All completed tasks deleted successfully");
                                                          } else {
                                                            print("Error deleting completed tasks");
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // if no task found or all are completed
                                Container(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userEmail)
                                        .collection(selectedTask ?? 'My Tasks')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        print("Waiting for data...");
                                      //   return Center(child: CircularProgressIndicator());
                                      }

                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0, left: 50, right: 50, bottom: 50),
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/empty-tasks-light.svg',
                                                width: 250.0,
                                                height: 250.0,
                                                fit: BoxFit.cover,
                                              ),
                                              Center(
                                                child: Text(
                                                  "No tasks yet",
                                                  style: TextStyle(fontSize: 20, color: Colors.white.withAlpha(180)),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  "Add your to-dos and keep\n track of them across Google \nWorkspace",
                                                  style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(180)),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // Check if all tasks have status = 1
                                      final tasks = snapshot.data!.docs;
                                      bool allTasksCompleted = tasks.every((task) => task['status'] == 1);

                                      if (allTasksCompleted) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0, left: 50, right: 50, bottom: 50),
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/all-tasks-completed-light.svg',
                                                width: 250.0,
                                                height: 250.0,
                                                fit: BoxFit.cover,
                                              ),
                                              Center(
                                                child: Text(
                                                  "All tasks completed!",
                                                  style: TextStyle(fontSize: 20, color: Colors.white.withAlpha(180)),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  "Nice Work!",
                                                  style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(180)),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // If there are tasks but not all are completed, show tasks normally (implement your task list UI here)
                                      return SizedBox.shrink();
                                    },
                                  ),
                                ),
                                 // past container
                                taskContainer(
                                  label: "Past",
                                  labelColor: Colors.pink.shade200,
                                  userEmail: userEmail,
                                  selectedTask: selectedTask,
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userEmail)
                                      .collection(selectedTask ?? 'My Tasks')
                                      .where('status', isEqualTo: 0)
                                      .where('task_date',isLessThan: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),),)
                                      .where('task_date', isNotEqualTo: Timestamp.fromDate(specificDateTime))
                                      .snapshots(),
                                ),
                                // today container
                                taskContainer(
                                  label: "Today",
                                  labelColor: Colors.blue.shade300,
                                  userEmail: userEmail,
                                  selectedTask: selectedTask,
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userEmail)
                                      .collection(selectedTask ?? 'My Tasks')
                                      .where('task_date',isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),),)
                                      .where('task_date',isLessThan: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: 1)),),)
                                      .where('status', isEqualTo: 0)
                                      .snapshots(),
                                ),
                                // future container
                                taskContainer(
                                  label: "",
                                  labelColor: Colors.white,
                                  userEmail: userEmail,
                                  selectedTask: selectedTask,
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userEmail)
                                        .collection(selectedTask ?? 'My Tasks')
                                        .where('task_date',isGreaterThan: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),),)
                                        .where('status', isEqualTo: 0)
                                        .snapshots(),
                                  showDateHeader: true
                                ),
                                // no date container
                                taskContainer(
                                  label: "No date",
                                  labelColor: Colors.white,
                                  userEmail: userEmail,
                                  selectedTask: selectedTask,
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userEmail)
                                      .collection(selectedTask ?? 'My Tasks')
                                      .where('task_date', isEqualTo: Timestamp.fromDate(specificDateTime))
                                      .where('status',isEqualTo: 0)
                                      .snapshots(),
                                ),
                              ],
                            )
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userEmail)
                                .collection(selectedTask ?? 'My Tasks')
                                .where('status', isEqualTo: 1) // Only completed tasks
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                // return Center(child: CircularProgressIndicator());
                                print("Waiting for data...");
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                // Don't show the container if there are no completed tasks
                                return SizedBox.shrink();
                              }

                              final tasks = snapshot.data!.docs;

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showCompletedTasks = !showCompletedTasks;
                                      });
                                    },
                                    child: Container(
                                      color: Colors.transparent,  // Makes the entire row tappable, including empty spaces
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                      child: Row(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Completed (${tasks.length})',
                                              style: GoogleFonts.afacad(
                                                textStyle: TextStyle(color: Colors.white, fontSize: 20.0),
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 5.0),
                                            child: Icon(
                                              showCompletedTasks
                                                  ? Icons.keyboard_arrow_up_outlined
                                                  : Icons.keyboard_arrow_down_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (showCompletedTasks)
                                    Column(
                                      children: tasks.map((task) {
                                        return ListTile(
                                          leading: IconButton(
                                            onPressed: () {
                                              int newStatus = task['status'] == 0 ? 1 : 0;
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userEmail)
                                                  .collection(selectedTask ?? 'My Tasks')
                                                  .doc(task.id)
                                                  .update({'status': newStatus}).then((_) {
                                                print("Task status updated successfully!");
                                              }).catchError((error) {
                                                print("Failed to update task status: $error");
                                              });
                                            },
                                            icon: Icon(
                                              Icons.check,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          title: Text(
                                            task['title'],
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(150),
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: Colors.white.withAlpha(150),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController ttitle = TextEditingController();
          TextEditingController description = TextEditingController();
          TextEditingController date = TextEditingController();
          date.text = "2000-01-01 00:00:00";
          bool favoriate = false;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // To allow the sheet to resize with the keyboard
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            backgroundColor: Colors.grey[900],
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                      top: 15.0,
                      // Adjust bottom padding for the keyboard
                      bottom: MediaQuery.of(context).viewInsets.bottom + 15.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Set size to minimum required
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: ttitle,
                            decoration: InputDecoration(
                              hintText: 'New task',
                              hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
                              border: InputBorder.none, // Remove the border
                            ),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400), // Set text color to white
                          ),
                          if (description_field_enabler)
                            Container(
                              height: 25,
                              child: TextField(
                                controller: description,
                                decoration: InputDecoration(
                                  hintText: 'Add Details',
                                  hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
                                  border: InputBorder.none, // Remove the border
                                ),
                                style: TextStyle(color: Colors.white, fontSize: 14), // Set text color to white
                              ),
                            ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    description_field_enabler = !description_field_enabler;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(Icons.menu, color: Colors.white.withAlpha(200)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2099),
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.dark().copyWith(
                                          colorScheme: ColorScheme.dark(
                                            primary: Colors.blue,
                                            onPrimary: Colors.white,
                                            surface: Colors.grey.shade900,
                                            onSurface: Colors.white,
                                          ),
                                          dialogBackgroundColor: Colors.grey[900]!.withAlpha(180),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                      final DateTime finalDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                      );
                                      setModalState(() {
                                        date.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(finalDateTime);
                                      });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(Icons.watch_later_outlined, color: Colors.white.withAlpha(200)),
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  favoriate = !favoriate;
                                  setModalState(() {
                                    star_icon_enabler = !star_icon_enabler;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon((star_icon_enabler)?Icons.star:Icons.star_border_outlined, color: Colors.white.withAlpha(200)),
                                ),
                              ),
                              Spacer(), // This will push the following Done to the right
                              GestureDetector(
                                onTap: () async{
                                  Navigator.pop(context);
                                  print(ttitle.text);
                                  print(description.text);
                                  print(favoriate);
                                  print(date.text);
                                  bool task_added = await taskHandler.add_task(selectedTask ?? 'My Tasks', ttitle.text, description.text, favoriate, date.text);
                                  if(task_added==true){
                                    setModalState(() {
                                      star_icon_enabler = false;
                                      description_field_enabler = false;
                                    });
                                  }
                                  else{
                                    print("Error adding task");
                                  }
                                },
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        backgroundColor: Colors.blue.withAlpha(100),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  // Future<bool> delete_completed_task(String taskName) async {
  //   try {
  //     CollectionReference userDoc = FirebaseFirestore.instance.collection('users').doc(userEmail).collection(taskName);
  //     QuerySnapshot querySnapshot = await userDoc.where('status', isEqualTo: 1).get();
  //     for (var doc in querySnapshot.docs) {
  //       await doc.reference.delete();
  //     }
  //     print('deleted all completed tasks');
  //     return true;
  //   } catch (e) {
  //     print('Error deleting task: $e');
  //     return false;
  //   }
  // }
}