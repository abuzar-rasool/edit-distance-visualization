import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
            child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Text('Edit Distance Visualization', style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 10),
                const EditDistanceTable('spartan', 'part'),
              ],
            ),
          ),
        )),
      ),
    );
  }
}

class EditDistanceTable extends StatefulWidget {
  final String s1;
  final String s2;
  const EditDistanceTable(this.s1, this.s2, {Key? key}) : super(key: key);

  @override
  State<EditDistanceTable> createState() => _EditDistanceTableState();
}

class _EditDistanceTableState extends State<EditDistanceTable> {
  late String s1;
  late String s2;
  late EditDistanceCalculator calculator;
  //form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<TableRow> rows = [];

  @override
  void initState() {
    super.initState();
    s1 = widget.s1;
    s2 = widget.s2;
    editDistance(s1, s2);
    generateTable();
  }

  editDistance(String s1, String s2) {
    calculator = EditDistanceCalculator(s1, s2);
    calculator.calculate();
  }

  degreesToRand(deg) {
    return (deg * pi / 180);
  }

  Widget getIcon(Direction d) {
    if (d == Direction.up) {
      return Transform.rotate(angle: degreesToRand(90), child: const Icon(Icons.arrow_back));
    } else if (d == Direction.left) {
      return const Icon(Icons.arrow_back);
    } else {
      return Transform.rotate(angle: degreesToRand(45), child: const Icon(Icons.arrow_back));
    }
  }

  String directionToString(Direction d) {
    if (d == Direction.up) {
      return 'up';
    } else if (d == Direction.left) {
      return 'left';
    } else {
      return 'diag';
    }
  }

  void generateTable() {
    rows = [];
    for (List<CellData> row in calculator.table) {
      TableRow tableRow = TableRow(
        children: row.map((cellData) {
          return TableCell(
            child: Container(
              color: cellData.highlighted ? Colors.grey : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (cellData.direction != null)
                          getIcon(cellData.direction!)
                        else
                          const SizedBox(
                            height: 16,
                            width: 16,
                          ),
                        //text of direction
                        // Text(
                        //   cellData.direction != null ? directionToString(cellData.direction!) : '',
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(cellData.value.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
      rows.add(tableRow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
          width: 500,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'String S1',
                      ),
                      initialValue: s1,
                      onChanged: (value) {
                        s1 = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a string';
                        }
                        if (value.length > 9) {
                          return 'String is too long';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'String S1',
                      ),
                      initialValue: s2,
                      onChanged: (value) {
                        s2 = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a string';
                        }
                        if (value.length > 9) {
                          return 'String is too long';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  //button
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          editDistance(s1, s2);
                          generateTable();
                          setState(() {});
                        }
                      },
                      child: const Text('Visualize'))
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Table(border: TableBorder.all(color: Colors.black), children: rows),
            ],
          )),
    );
  }
}

enum Direction {
  left,
  up,
  diagonal,
}

class CellData {
  Direction? direction;
  String value;
  bool highlighted;
  CellData({this.direction, this.value = '0', this.highlighted = false});
}

class EditDistanceCalculator {
  final String s1;
  final String s2;
  final List<List<CellData>> table;
  EditDistanceCalculator(this.s1, this.s2) : table = List.generate(s1.length + 2, (_) => List.generate(s2.length + 2, (_) => CellData()));
  calculate() {
    table[0][0].value = '';
    table[0][1].value = '-';
    table[1][0].value = '-';
    for (int i = 2; i < s1.length + 2; i++) {
      table[i][0].value = s1[i - 2];
    }
    for (int i = 2; i < s2.length + 2; i++) {
      table[0][i].value = s2[i - 2];
    }
    for (int i = 1; i < s2.length + 2; i++) {
      table[1][i].value = (i - 1).toString();
    }
    for (int i = 1; i < s1.length + 2; i++) {
      table[i][1].value = (i - 1).toString();
    }
    for (int i = 2; i < s1.length + 2; i++) {
      for (int j = 2; j < s2.length + 2; j++) {
        if (s1[i - 2] == s2[j - 2]) {
          table[i][j].value = table[i - 1][j - 1].value;
          table[i][j].direction = Direction.diagonal;
        } else {
          final int up = int.parse(table[i - 1][j].value) + 1;
          final int left = int.parse(table[i][j - 1].value) + 1;
          final int diagonal = int.parse(table[i - 1][j - 1].value) + 1;
          table[i][j].value = minOf(left, up, diagonal).toString();
          if (left == int.parse(table[i][j].value)) {
            table[i][j].direction = Direction.left;
          } else if (up == int.parse(table[i][j].value)) {
            table[i][j].direction = Direction.up;
          } else {
            table[i][j].direction = Direction.diagonal;
          }
        }
      }
    }
    //mark the highlighted cells by backtracking from last cell
    int currI = s1.length + 1;
    int currJ = s2.length + 1;
    while (currI >= 1 && currJ >= 1) {
      table[currI][currJ].highlighted = true;

      if (table[currI][currJ].direction == Direction.diagonal) {
        currI--;
        currJ--;
      } else if (table[currI][currJ].direction == Direction.up) {
        currI--;
      } else {
        currJ--;
      }
    }
  }

  int minOf(int a, int b, int c) {
    return min(a, min(b, c));
  }
}
