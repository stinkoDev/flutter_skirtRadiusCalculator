import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Color _seedColor = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bool isLight = prefs.getBool('lightMode') ?? true;
      _themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
      String colorScheme = prefs.getString('colorScheme') ?? 'deepPurple';
      _seedColor = _getColorFromName(colorScheme);
    });
  }

  Color _getColorFromName(String name) {
    switch (name) {
      case 'deepPurple':
        return Colors.deepPurple;
      case 'blue':
        return Colors.blue;
      case 'indigo':
        return Colors.indigo;
      case 'teal':
        return Colors.teal;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.deepPurple;
    }
  }

  Future<void> setThemeMode(bool isLight) async {
    setState(() {
      _themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lightMode', isLight);
  }

  Future<void> setColorScheme(String colorName) async {
    setState(() {
      _seedColor = _getColorFromName(colorName);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorScheme', colorName);
  }

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skirt Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: const MyHomePage(title: 'Skirt Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedView = 'Partial View';
  double seamAllowance = 2;

  Future<void> getSeamAllowance() async {
    final prefs = await SharedPreferences.getInstance();
    bool isTrue = prefs.getBool('useSeamAllowance') ?? true;
    if (isTrue) {
      seamAllowance =
          double.tryParse(prefs.getString('seamAllowance') ?? '2') ?? 2;
    } else {
      seamAllowance = 0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSeamAllowance();
  }

  final TextEditingController radiusController = TextEditingController(
    text: '8.66',
  );
  final TextEditingController fabricLengthController = TextEditingController(
    text: '58.66',
  );
  final TextEditingController waistController = TextEditingController(
    text: '67',
  );
  final TextEditingController skirtLengthController = TextEditingController(
    text: '50',
  );

  List<String> skirtTypes = [
    'Full Skirt',
    'Double Skirt',
    '3/4 Skirt',
    '1/2 Skirt',
    '1/3 Skirt',
    '1/4 Skirt',
  ];
  String skirtType = 'Full Skirt';

  String fullSkirtCalculator(double waist, double length) {
    double data = (waist / (2 * pi) - seamAllowance);
    return data.toStringAsFixed(2);
  }

  String doubleSkirtCalculator(double waist, double length) {
    double data = (waist / (4 * pi) - seamAllowance);
    return data.toStringAsFixed(2);
  }

  String threeQuarterSkirtCalculator(double waist, double length) {
    double data = ((4 / 3) * (waist / (2 * pi)) - seamAllowance);
    return data.toStringAsFixed(2);
  }

  String halfSkirtCalculator(double waist, double length) {
    double data = ((waist / pi) - seamAllowance);
    return data.toStringAsFixed(2);
  }

  String thirdSkirtCalculator(double waist, double length) {
    double data = ((waist / (2 * pi) * 3) - seamAllowance);
    return data.toStringAsFixed(2);
  }

  String quarterSkirtCalculator(double waist, double length) {
    double data = ((4 * (waist / (2 * pi))) - seamAllowance);
    return data.toStringAsFixed(2);
  }

  void fabricLengthCalculator() {
    double skirtLength = double.tryParse(skirtLengthController.text) ?? 0.0;
    double radiusLength = double.tryParse(radiusController.text) ?? 0.0;

    fabricLengthController.text = (skirtLength + radiusLength).toString();
  }

  void calculateSkirt() {
    double waistInt = double.tryParse(waistController.text) ?? 0.0;
    double lengthInt = double.tryParse(skirtLengthController.text) ?? 0.0;

    String data = '';
    data = switch (skirtType) {
      'Full Skirt' => fullSkirtCalculator(waistInt, lengthInt),
      'Double Skirt' => doubleSkirtCalculator(waistInt, lengthInt),
      '3/4 Skirt' => threeQuarterSkirtCalculator(waistInt, lengthInt),
      '1/2 Skirt' => halfSkirtCalculator(waistInt, lengthInt),
      '1/3 Skirt' => thirdSkirtCalculator(waistInt, lengthInt),
      '1/4 Skirt' => quarterSkirtCalculator(waistInt, lengthInt),
      _ => 'error, something went wrong',
    };

    setState(() {
      radiusController.text = data;
      fabricLengthCalculator();
    });
  }

  void patternDisplay(String value) {
    if (value == 'Partial View') {
      selectedView = 'Full View';
    } else {
      selectedView = 'Partial View';
    }
  }

  @override
  void dispose() {
    radiusController.dispose();
    fabricLengthController.dispose();
    waistController.dispose();
    skirtLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skirt Calculator')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(title: 'Skirt Calculator'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history_rounded),
              title: Text('History'),
              onTap: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Not that quick!'),
                  content: Text('This is a future feature coming soon'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Close'),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        // compartment for the page
        child: Column(
          children: [
            // 1st row for the app
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: skirtType,
                      isExpanded: true,
                      underline: Container(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      iconEnabledColor: Theme.of(context).colorScheme.onPrimary,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      selectedItemBuilder: (BuildContext context) {
                        return skirtTypes.map((String type) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              type,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ), // White
                            ),
                          );
                        }).toList();
                      },
                      items: skirtTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          skirtType = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            // 2nd row for the app
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'Partial View',
                    label: Text('Partial View'),
                    icon: Icon(
                      selectedView == 'Partial View'
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  ButtonSegment(
                    value: 'Full View',
                    label: Text('Full View'),
                    icon: Icon(
                      selectedView == 'Full View'
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                selected: {selectedView},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedView = newSelection.first;
                  });
                },
                showSelectedIcon: false,
              ),
            ),
            // 3rd row for the app
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    color: Color(0xFFe6e6e6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: PatternPainter(
                            calculatedRadius:
                                double.tryParse(radiusController.text) ?? 0.0,
                            calculatedLength:
                                double.tryParse(fabricLengthController.text) ??
                                0.0,
                            patternType: selectedView,
                            maxSize: constraints.maxWidth,
                            themeColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            selectedSkirt: skirtType,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // 4th row for the app
            SizedBox(
              // width: double.infinity,
              child: Card(
                child: Column(
                  children: [
                    Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Color.fromARGB(180, 255, 0, 0),
                                  size: 12,
                                ),
                                Text('Radius:'),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  tooltip: 'more info',
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('More Info'),
                                      content: Text(
                                        'this is a message about the radius of the pattern',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Close'),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              radiusController.text,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        trailing: Text('cm'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Color.fromARGB(180, 0, 0, 255),
                                  size: 12,
                                ),
                                Text('Fabric Length:'),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  tooltip: 'more info',
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('More Info'),
                                      content: Text(
                                        'this is a message about the fabric length',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Close'),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              fabricLengthController.text,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        trailing: Text('cm'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Color.fromARGB(120, 120, 120, 120),
                                  size: 12,
                                ),
                                Text('Waist:'),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  tooltip: 'more info',
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('More Info'),
                                      content: Text(
                                        'this is a message about the diameter of the waist',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Close'),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: TextField(
                                controller: waistController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  suffixText: 'cm',
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Color.fromARGB(180, 0, 255, 0),
                                  size: 12,
                                ),
                                Text('Skirt Length:'),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  tooltip: 'more info',
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('More Info'),
                                      content: Text(
                                        'this is a message about the skirt length',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Close'),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: TextField(
                                controller: skirtLengthController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  suffixText: 'cm',
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 5th row for the app
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: calculateSkirt,
                    child: Text('Calculate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool lightMode = true;

  String colorScheme = 'deepPurple';
  List<String> colorSchemes = [
    'deepPurple', // Bold, sophisticated
    'blue', // Classic, professional
    'indigo', // Modern, tech-focused
    'teal', // Fresh, calming
    'purple', // Creative, elegant
    'green', // Nature, success
    'orange', // Energetic, warm
    'pink', // Playful, friendly
  ];

  String measurementUnit = 'cm';
  List<String> measurementUnits = ['cm', 'mm', 'm', 'inch'];

  bool useSeamAllowance = true;

  final TextEditingController seamAllowanceController = TextEditingController(
    text: '2',
  );
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lightMode = prefs.getBool('lightMode') ?? true;
      colorScheme = prefs.getString('colorScheme') ?? 'deepPurple';
      measurementUnit = prefs.getString('measurementUnit') ?? 'cm';
      seamAllowanceController.text = prefs.getString('seamAllowance') ?? '2';
      useSeamAllowance = prefs.getBool('useSeamAllowance') ?? true;
    });
  }

  Future<void> _savePreferences(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('lightMode', lightMode);
    await prefs.setString('colorScheme', colorScheme);
    await prefs.setString('measurementUnit', measurementUnit);
    await prefs.setBool('useSeamAllowance', useSeamAllowance);
    await prefs.setString('seamAllowance', seamAllowanceController.text);

    MyApp.of(context).setThemeMode(lightMode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings Saved!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleColorSchemeChange(String? newValue) {
    setState(() {
      colorScheme = newValue!;
    });
    MyApp.of(context).setColorScheme(newValue!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(title: 'Skirt Calculator'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history_rounded),
              title: Text('History'),
              onTap: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Not that quick!'),
                  content: Text('This is a future feature coming soon'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Close'),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              // 1st item
              Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark Mode:'),
                        Switch(
                          value: lightMode,
                          activeThumbColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          onChanged: (bool value) {
                            _savePreferences('lightMode', value);
                            setState(() {
                              lightMode = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 2nd item
              Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Theme Color:'),
                        Flexible(
                          child: CustomDropDown(
                            value: colorScheme,
                            items: colorSchemes,
                            onChanged: _handleColorSchemeChange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 3rd item
              // Padding(
              //   padding: const EdgeInsets.all(5),
              //   child: Card(
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text('Unit Display:'),
              //           Flexible(
              //             child: CustomDropDown(
              //               value: measurementUnit,
              //               items: measurementUnits,
              //               onChanged: _handleUnitChange,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // 4th item
              Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Seam Allowance:'),
                        Switch(
                          value: useSeamAllowance,
                          activeThumbColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          onChanged: (bool value) {
                            setState(() {
                              seamAllowanceController.text = '0';
                              useSeamAllowance = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 5th item
              Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Custom Seam Allowance:'),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: TextField(
                            enabled: useSeamAllowance,
                            controller: seamAllowanceController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              suffixText: measurementUnit,
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 6th item
              Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  child: FilledButton(
                    onPressed: saveSettings,
                    child: Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  final double calculatedRadius;
  final double calculatedLength;
  final String patternType;
  final double maxSize;
  final Color themeColor;
  final String selectedSkirt;

  PatternPainter({
    required this.calculatedRadius,
    required this.calculatedLength,
    required this.patternType,
    required this.maxSize,
    required this.themeColor,
    required this.selectedSkirt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double maxDimention = calculatedRadius + calculatedLength;
    double scaleFactor = size.width / maxDimention;

    double scaledRadius = calculatedRadius * scaleFactor;
    double scaledLength = calculatedLength * scaleFactor;

    var paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var paintFill = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;

    var paintA = Paint()
      ..color = Color.fromARGB(255, 0, 0, 255)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var paintB = Paint()
      ..color = Color.fromARGB(255, 0, 255, 0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var paintC = Paint()
      ..color = Color.fromARGB(255, 255, 0, 0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (patternType == 'Full View') {
      drawFullCircle(
        canvas,
        scaledRadius,
        scaledRadius + scaledLength,
        paint,
        paintFill,
        paintA,
        paintB,
        paintC,
        3 * pi / 2,
        switch (selectedSkirt) {
          'Full Skirt' => 2 * pi,
          'Double Skirt' => 2 * pi,
          '3/4 Skirt' => 3 * pi / 2,
          '1/2 Skirt' => pi,
          '1/3 Skirt' => 2 * pi / 3,
          '1/4 Skirt' => pi / 2,
          _ => 2 * pi,
        },
      );
    } else if (patternType == 'Partial View') {
      drawHalfCircle(
        canvas,
        scaledRadius,
        scaledRadius + scaledLength,
        paint,
        paintFill,
        paintA,
        paintB,
        paintC,
      );
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) {
    return oldDelegate.calculatedRadius != calculatedRadius ||
        oldDelegate.calculatedLength != calculatedLength ||
        oldDelegate.patternType != patternType;
  }

  void drawFullCircle(
    Canvas canvas,
    double radius,
    double length,
    Paint paint,
    Paint paintFill,
    Paint colorA,
    Paint colorB,
    Paint colorC,
    double startAngle,
    double sweepAngle,
  ) {
    // co-ordinates of the lines
    Offset center = Offset(maxSize / 2, maxSize / 2);

    Rect rectangleInside = Rect.fromCircle(center: center, radius: radius / 2);
    Rect rectangleOutside = Rect.fromCircle(center: center, radius: length / 2);

    bool isFullCircle = sweepAngle >= 2 * pi - 0.01;

    if (isFullCircle) {
      Path outerCircle = Path()..addOval(rectangleOutside);
      Path innerCircle = Path()..addOval(rectangleInside);
      Path donutPath = Path.combine(
        PathOperation.difference,
        outerCircle,
        innerCircle,
      );

      canvas.drawPath(donutPath, paintFill);

      canvas.drawCircle(center, radius / 2, paint);
      canvas.drawCircle(center, length / 2, paint);
    } else {
      Path outerShape = Path()
        ..arcTo(rectangleOutside, startAngle, sweepAngle, false)
        ..arcTo(rectangleInside, startAngle + sweepAngle, -sweepAngle, false)
        ..close();

      canvas.drawPath(outerShape, paintFill);

      canvas.drawArc(rectangleInside, startAngle, sweepAngle, false, paint);
      canvas.drawArc(rectangleOutside, startAngle, sweepAngle, false, paint);
    }

    Offset radiusLineA = center;
    Offset radiusLineB = Offset(center.dx + (radius / 2), center.dy);

    Offset skirtLengthLineA = center;
    Offset skirtLengthLineB = Offset(center.dx, 0);

    Offset fabricLengthLineA = Offset(center.dx + (radius / 2), center.dy);
    Offset fabricLengthLineB = Offset(maxSize, center.dy);

    canvas.drawLine(fabricLengthLineA, fabricLengthLineB, colorA);
    canvas.drawLine(skirtLengthLineA, skirtLengthLineB, colorB);
    canvas.drawLine(radiusLineA, radiusLineB, colorC);
  }

  void drawHalfCircle(
    Canvas canvas,
    double radius,
    double length,
    Paint paint,
    Paint paintFill,
    Paint colorA,
    Paint colorB,
    Paint colorC,
  ) {
    // co-ordinates of the lines
    Offset radiusLineA = Offset(maxSize - 5, 5);
    Offset radiusLineB = Offset(maxSize + 5 - radius, 5);

    Offset skirtLengthLineA = Offset(5, 5);
    Offset skirtLengthLineB = Offset(radiusLineA.dx - radius, 5);

    Offset fabricLengthLineA = Offset(maxSize + 5, 0);
    Offset fabricLengthLineB = Offset(maxSize + 5, maxSize);

    Rect rectangleInside = Rect.fromCircle(
      center: Offset(maxSize, 0),
      radius: radius,
    );
    Rect rectangleOutside = Rect.fromCircle(
      center: Offset(maxSize, 0),
      radius: length,
    );

    Path outerArch = Path()
      ..moveTo(maxSize, 0)
      ..arcTo(rectangleOutside, pi / 2, pi / 2, false)
      ..lineTo(maxSize, 0)
      ..close();

    Path innerArch = Path()
      ..moveTo(maxSize, 0)
      ..arcTo(rectangleInside, pi / 2, pi / 2, false)
      ..lineTo(maxSize, 0)
      ..close();

    Path donutArch = Path.combine(
      PathOperation.difference,
      outerArch,
      innerArch,
    );

    canvas.drawPath(donutArch, paintFill);
    canvas.drawArc(rectangleInside, pi / 2, pi / 2, false, paint);
    canvas.drawArc(rectangleOutside, pi / 2, pi / 2, false, paint);
    canvas.drawLine(radiusLineA, radiusLineB, colorC);
    canvas.drawLine(skirtLengthLineA, skirtLengthLineB, colorB);
    canvas.drawLine(fabricLengthLineA, fabricLengthLineB, colorA);
  }
}

class CustomDropDown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropDown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: false,
        underline: Container(),
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        iconEnabledColor: Theme.of(context).colorScheme.onPrimary,
        dropdownColor: Theme.of(context).colorScheme.surface,
        selectedItemBuilder: (BuildContext context) {
          return items.map((String type) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                type,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          }).toList();
        },
        items: items.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              type,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
