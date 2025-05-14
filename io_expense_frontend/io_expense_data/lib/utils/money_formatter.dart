//this method will take a double value and return a string
//if the value have a decimal point,
//it will return the value with 2 decimal points,
//else it will return the value as an integer
//the value will be formatted with a comma separator

String formatMoney(double value) {
  if (value % 1 == 0) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  } else {
    return value.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
