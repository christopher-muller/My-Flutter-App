import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/constants/colors.dart';
import 'package:myapp/widgets/todo_item.dart';
import 'package:myapp/model/todo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/screens/success.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = Todo.todoList();
  List<Todo> _foundToDo = [];
  final Stream<QuerySnapshot> todos =
      FirebaseFirestore.instance.collection('todos').snapshots();
  final collection = FirebaseFirestore.instance.collection('todos');
  final _todoController = TextEditingController();

  @override
  void initState() {
    print(todos);
    // TODO: implement initState
    _foundToDo = todosList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: toRed,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              children: [
                SearchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 30, bottom: 20),
                        child: Text('All ToDos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      /*
                      for (Todo todo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                      */
                      Container(
                          height: 250,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: todos,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot,
                            ) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong.');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading...');
                              }

                              final data = snapshot.requireData;

                              return ListView.builder(
                                itemCount: data.size,
                                itemBuilder: (context, index) {
                                  Todo test = new Todo(
                                      id: data.docs[index].reference.id,
                                      todoText: data.docs[index]['text'],
                                      isDone: data.docs[index]['isDone']);
                                  if (!todosList.contains(test)) {
                                    todosList.add(test);
                                  }
                                  return ToDoItem(
                                    todo: test,
                                    onToDoChanged: _handleToDoChange,
                                    onDeleteItem: _deleteToDoItem,
                                  );
                                },
                              );
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 15,
                    left: 15,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none,
                      )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SuccessRoute()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  ),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.menu,
              color: toRed,
              size: 30,
            ),
          ],
        ));
  }

  void _handleToDoChange(Todo todo) {
    setState(() {
      collection
          .doc(todo.id)
          .update({'isDone': !todo.isDone})
          .then((_) => print('Success'))
          .catchError((error) => print("failed"));
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      collection
          .doc(id)
          .delete()
          .then((value) => print('success'))
          .then((erorr) => print('failed'));
    });
  }

  void _addToDoItem(String todo) {
    setState(() {
      collection
          .add({'text': todo, 'isDone': false})
          .then((_) => print('Success'))
          .catchError((error) => print("failed"));
    });
    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<Todo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget SearchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
