import 'package:flutter/material.dart';

class PriceText extends StatelessWidget {
  final int price;
  final TextStyle? style;

  const PriceText({super.key, required this.price, this.style});

  @override
  Widget build(BuildContext context) {
    final priceStr = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }

    return Text("Rp ${buffer.toString()}", style: style);
  }
}
