import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CustomNumpad extends StatefulWidget {
  final TextEditingController amountController;
  final VoidCallback onEnterPressed;

  const CustomNumpad({
    super.key,
    required this.amountController,
    required this.onEnterPressed,
  });

  @override
  _CustomNumpadState createState() => _CustomNumpadState();
}

class _CustomNumpadState extends State<CustomNumpad> {
  bool _isOperationActive = false;

  void _onButtonPressed(String text) {
    setState(() {
      if (text == 'C') {
        widget.amountController.clear();
        _isOperationActive = false;
      } else if (text == '<') {
        widget.amountController.text = widget.amountController.text.isNotEmpty
            ? widget.amountController.text
                .substring(0, widget.amountController.text.length - 1)
            : '';
      } else if (text == 'Enter' || text == '=') {
        if (text == '=') {
          _calculateResult();
          _isOperationActive = false;
        } else {
          widget.onEnterPressed(); // Notify parent to hide the numpad
        }
      } else {
        widget.amountController.text += text;
        if (['+', '-', '×', '÷'].contains(text)) {
          _isOperationActive = true;
        }
      }
    });
  }

  void _calculateResult() {
    String expression =
        widget.amountController.text.replaceAll('×', '*').replaceAll('÷', '/');
    Parser parser = Parser();
    Expression exp = parser.parse(expression);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    widget.amountController.text = eval.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['C', '÷', '×', '<'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', _isOperationActive ? '=' : 'Enter'],
      ['0', '000']
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.37,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -2),
              blurRadius: 8.0,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: buttons.map((row) {
            return Expanded(
              child: Row(
                children: row.map((text) {
                  return Expanded(
                    child: _numpadButton(text),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _numpadButton(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(text),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20.0,
            color: _getTextColor(text),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(String text) {
    if (text == 'C' || text == '<') {
      return const Color.fromARGB(255, 237, 128, 95);
    } else if (['+', '-', '×', '÷', '=', 'Enter'].contains(text)) {
      return Colors.blueAccent;
    } else {
      return Colors.grey[200]!;
    }
  }

  Color _getTextColor(String text) {
    if (text == 'C' || text == '<') {
      return Colors.white;
    } else if (['+', '-', '×', '÷', '=', 'Enter'].contains(text)) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
