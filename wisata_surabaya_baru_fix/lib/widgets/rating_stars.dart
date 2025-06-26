import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  
  RatingStars({required this.rating});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}