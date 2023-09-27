import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qcrunningtest/main.dart';

class QCHoldScreen extends StatefulWidget {
  const QCHoldScreen({super.key});

  @override
  State<QCHoldScreen> createState() => _QCHoldScreenState();
}

class _QCHoldScreenState extends State<QCHoldScreen> {
  int _selectedIndex = 0;
  String serialNo = "";
  String LineNo = "1";
  List<DropdownMenuItem<String>> oLines = [
    const DropdownMenuItem<String>(value: '1', child: Text('Line 1')),
    const DropdownMenuItem<String>(value: '2', child: Text('Line 2')),
    const DropdownMenuItem<String>(value: '3', child: Text('Line 3')),
    const DropdownMenuItem<String>(value: '4', child: Text('Line 4')),
    const DropdownMenuItem<String>(value: '5', child: Text('Line 5')),
    const DropdownMenuItem<String>(value: '6', child: Text('Line 6')),
    const DropdownMenuItem<String>(value: '7', child: Text('Line 7')),
    const DropdownMenuItem<String>(value: '8', child: Text('Line 8')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inverseSurface,
        foregroundColor: theme.colorScheme.inversePrimary,
        title: Text('RUNNING TEST'),
        centerTitle: tr,
      ),
      body: Column(
        children: [
          TextFormField(
            maxLength: 15,
            decoration: InputDecoration(
              hintText: 'SCAN COMPRESSOR',
              counterText: '',
              labelText: 'SCAN COMPRESSOR',
              fillColor: Colors.lime[50],
              filled: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(FontAwesomeIcons.qrcode),
              ),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(left: 0, right: 25),
                child: Icon(
                  FontAwesomeIcons.qrcode,
                  // size: 10,
                ),
              ),
            ),
            onFieldSubmitted: (value) {
              setState(() {
                serialNo = value;
              });
            },
          ),
          Row(
            children: [
              const Text('Serial No :'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  ' $serialNo ',
                  style: const TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('LINE : '),
              DropdownButton(
                // isExpanded: true,
                items: oLines,
                value: LineNo,
                onChanged: (val) {
                  setState(() {
                    LineNo = val!;
                  });
                },
              ),
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.lockOpen),
            label: 'ALLOW HOLD',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.circleCheck),
            label: 'BY-PASS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'ออกระบบ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          switch (index) {
            case 0:
            // only scroll to top when current index is selected.
            // if (_selectedIndex == index) {
            //   _homeController.animateTo(
            //     0.0,
            //     duration: const Duration(milliseconds: 500),
            //     curve: Curves.easeOut,
            //   );
            // }
            case 1:
            //showModal(context);
          }
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }
}
