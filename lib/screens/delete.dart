import 'package:flutter/material.dart';

class DeleteRoute extends StatelessWidget {
  const DeleteRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Todo'),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 50, bottom: 20, left: 10, right: 10),
            child: Text('Successfully deleted a todo item!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 300, horizontal: 145),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ),
        ],
      ),
    );
  }
}
