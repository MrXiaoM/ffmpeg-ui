import 'dart:io';

bool get usesSystemWindowButtons => Platform.isMacOS;

bool get usesCustomCaptionButtons => !usesSystemWindowButtons;

double get titleBarLeadingInset => Platform.isMacOS ? 78 : 12;
