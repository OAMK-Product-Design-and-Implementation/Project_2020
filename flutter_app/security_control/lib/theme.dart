import 'package:flutter/material.dart';

// Current colors gotten from: https://material.io/resources/color/#!/?view.left=0&view.right=1&secondary.color=fca311&primary.color=14213D&secondary.text.color=000000
// Colors for light mode maybe:
const Color _primaryColor = Color(0xFF14213D);
const Color _primaryColorLight = Color(0xFF3E4868);
const Color _primaryColorDark = Color(0xFF000018);
const Color _onPrimaryColor = Color(0xFFFFFFFF);
const Color _accentColor = Color(0xFFFCA311);
const Color _accentColorLight = Color(0xFFFFD34F);
const Color _accentColorDark = Color(0xFFC37300);
const Color _onAccentColor = Color(0xFF000000);
const Color _backgroundColor = Color(0xFFE5E5E5);
const Color _onBackgroundColor = Color(0xFF000000);
const Color _surfaceColor = Color(0xFFFFFFFF);
const Color _onSurfaceColor = Color(0xFF000000);
const Color _errorColor = Color(0xFFE5E5E5); // May be subject to change
const Color _onErrorColor = Color(0xFFC20000); // May be subject to change
const Brightness _brightness = Brightness.light; // May be subject to change

// Colors specific for dark mode (will have to modify and add more colors):
const Color _onBackgroundColorDarkMode = Color(0xFFFFFFFF);
const Color _onSurfaceColorDarkMode = Color(0xFFFFFFFF);
const Color _hintColorDarkMode = Color(0xFFE5E5E5);
const Brightness _brightnessDarkMode = Brightness.dark;

// Create ThemeData:
ThemeData getAppTheme(BuildContext context, bool isDark) {
  ThemeData themeD;
  ColorScheme colors;
  TextTheme texts;

  // Add styles, colors etc. as global variables here and assign them in the if
  //  structures below (for both, dark and light modes.
  Color hintCol;

  // Light mode properties:
  if (isDark == false) {
    colors = ColorScheme(
        primary: _primaryColor,
        primaryVariant: _primaryColorDark,
        secondary: _accentColor,
        secondaryVariant: _accentColorDark,
        surface: _surfaceColor,
        background: _backgroundColor,
        error: _errorColor,
        onPrimary: _onPrimaryColor,
        onSecondary: _onAccentColor,
        onSurface: _onSurfaceColor,
        onBackground: _onBackgroundColor,
        onError: _onErrorColor,
        brightness: _brightness);

    texts = TextTheme(
        overline: TextStyle(
          color: _onBackgroundColor,
        ),
        button: TextStyle(
          color: _onBackgroundColor,
        ),
        headline1: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: Colors.grey,
        ),
        headline2: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: _accentColor,
        ),
        headline3: TextStyle(
          color: _onBackgroundColor,
        ),
        headline4: TextStyle(
          color: _onBackgroundColor,
        ),
        headline5: TextStyle(
          color: _onBackgroundColor,
        ),
        headline6: TextStyle(
          color: _onBackgroundColor,
        ),
        subtitle1: TextStyle(
          color: _onBackgroundColor,
        ),
        subtitle2: TextStyle(
          color: _onBackgroundColor,
        ),
        bodyText1: TextStyle(
          color: _onBackgroundColor,
        ),
        bodyText2: TextStyle(
          color: _onBackgroundColor,
        ),
        caption: TextStyle(
          color: _onBackgroundColor,
        ));

    hintCol = _onBackgroundColor;
  }
  // Dark mode properties:
  else {
    colors = ColorScheme(
        primary: _primaryColorLight,
        primaryVariant: _primaryColorDark,
        secondary: _accentColor,
        secondaryVariant: _accentColorDark,
        surface: _primaryColor,
        background: _primaryColorDark,
        error: _errorColor,
        onPrimary: _onPrimaryColor,
        onSecondary: _onAccentColor,
        onSurface: _onSurfaceColorDarkMode,
        onBackground: _onBackgroundColorDarkMode,
        onError: _onErrorColor,
        brightness: _brightness);

    texts = TextTheme(
      overline: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      button: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      headline1: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25.0,
        color: Colors.grey,
      ),
      headline2: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25.0,
        color: _accentColorDark,
      ),
      headline3: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      headline4: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      headline5: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      headline6: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      subtitle1: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      subtitle2: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      bodyText1: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      bodyText2: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
      caption: TextStyle(
        color: _onBackgroundColorDarkMode,
      ),
    );

    hintCol = _onBackgroundColorDarkMode;
  }

  // Construct the initial ThemeData:
  themeD = ThemeData.from(colorScheme: colors, textTheme: texts);

  // Define any global styles etc. here
  // Check parameters from: https://api.flutter.dev/flutter/material/ThemeData/copyWith.html
  themeD = themeD.copyWith(
    hintColor: hintCol,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        color: hintCol,
      ),
      border: UnderlineInputBorder(),
    ),
    iconTheme: IconThemeData(color: Colors.grey),
  );

  return themeD;
}
