import 'package:flutter/material.dart';
import 'package:tiatia/utils/colors.dart';

ButtonStyle borderedButtonStyle = ButtonStyle(
  elevation: MaterialStateProperty.all(0),
  backgroundColor: MaterialStateProperty.all(Colors.white),
  shape: MaterialStateProperty.all(RoundedRectangleBorder(
    side: BorderSide(color: AppColors.primary),
    borderRadius: BorderRadius.circular(10)
  )));