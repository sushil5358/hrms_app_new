import 'package:flutter/material.dart';

import '../../../../utils/colers.dart';

class Workflow extends StatefulWidget {
  const Workflow({super.key});

  @override
  State<Workflow> createState() => _WorkflowState();
}

class _WorkflowState extends State<Workflow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approval WorkFlow"),
        backgroundColor: primary_color,
          foregroundColor: Colors.white,
      ),
    );
  }
}
