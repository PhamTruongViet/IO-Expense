import 'package:flutter/material.dart';

class DatePickerButton extends StatefulWidget {
  final ValueChanged<DateTime?> onDateSelected;

  const DatePickerButton({super.key, required this.onDateSelected});

  @override
  _DatePickerButtonState createState() => _DatePickerButtonState();
}

class _DatePickerButtonState extends State<DatePickerButton> {
  DateTime? _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: _pickDate,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today),
            Text(_selectedDate != null
                ? ' ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : 'Pick Date'),
          ],
        ));
  }
}
