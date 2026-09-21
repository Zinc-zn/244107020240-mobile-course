import 'package:flutter/material.dart';

class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  bool _isChecked = false;
  int _radioValue = 1;
  bool _isSwitched = false;
  double _sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input & Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'TextField Biasa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Checkbox'),
              value: _isChecked,
              onChanged: (val) => setState(() => _isChecked = val ?? false),
            ),
            RadioListTile(
              title: const Text('Radio 1'),
              value: 1,
              groupValue: _radioValue,
              onChanged: (val) => setState(() => _radioValue = val as int),
            ),
            RadioListTile(
              title: const Text('Radio 2'),
              value: 2,
              groupValue: _radioValue,
              onChanged: (val) => setState(() => _radioValue = val as int),
            ),
            SwitchListTile(
              title: const Text('Switch'),
              value: _isSwitched,
              onChanged: (val) => setState(() => _isSwitched = val),
            ),
            const SizedBox(height: 16),
            const Text('Slider:'),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 10,
              label: _sliderValue.round().toString(),
              onChanged: (val) => setState(() => _sliderValue = val),
            ),
          ],
        ),
      ),
    );
  }
}
