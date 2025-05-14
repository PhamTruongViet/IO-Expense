import 'package:flutter/material.dart';

class TimePickerButton extends StatefulWidget {
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const TimePickerButton({super.key, required this.onTimeSelected});

  @override
  _TimePickerButtonState createState() => _TimePickerButtonState();
}

class _TimePickerButtonState extends State<TimePickerButton> {
  TimeOfDay? _selectedTime = TimeOfDay.now(); // Initialize with current time

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime!,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      widget.onTimeSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _pickTime,
      child: Text(_selectedTime != null
          ? 'Selected time: ${_selectedTime!.format(context)}'
          : 'Pick Time'),
    );
  }
}