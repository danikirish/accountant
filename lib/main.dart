import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BudgetModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ================ OLD ==================
    // return ChangeNotifierProvider(
    //   create: (context) => MyAppState(),
    //   child: MaterialApp(
    // title: 'Accountant',
    // theme: ThemeData(
    //   useMaterial3: true,
    //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    // ),
    //     home: MyHomePage(),
    //     // home: BudgetPage(),
    //   ),
    // );
    // ================ OLD ==================

    return MaterialApp(
        title: 'Accountant',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: BudgetPage());
  }
}

class BudgetModel extends ChangeNotifier {
  double _initialBudget = 0;
  double _currentBudget = 0;
  double _spent = 0;
  bool showValueInput = false;
  // bool showTextInput = false;

  double getCurrentBudget() {
    return _currentBudget;
  }

  double getInitialBudget() {
    return _initialBudget;
  }

  double getSpent() {
    return _spent;
  }

  double getRemaining() {
    return _initialBudget - _spent;
  }

  bool isBudgetNotSet() {
    return _initialBudget == 0;
  }

  void setCurrentBudget(double value) {
    _currentBudget = value;
    // notifyListeners();
  }

  void setInitialBudget(double value) {
    _initialBudget = value;
    setCurrentBudget(_initialBudget);
    notifyListeners();
  }

  void addTransaction(double value) {
    _spent += value;
    _currentBudget -= value;
    toggleValueInput();
    notifyListeners();
  }

  void subtractTransaction(double value) {
    // _spent -= value;
    _currentBudget += value;
    notifyListeners();
  }

  void toggleValueInput() {
    showValueInput = !showValueInput;
    print(showValueInput);
    notifyListeners();
  }

  void resetAll() {
    _currentBudget = 0;
    _initialBudget = 0;
    _spent = 0;
    showValueInput = false;
    notifyListeners();
  }
}

class BudgetPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final budgetModel = context.watch<BudgetModel>();
    final theme = Theme.of(context);

    return Scaffold(
        // color: Theme.of(context).colorScheme.primaryContainer,
        body: SingleChildScrollView(
            child: Center(
                child: Container(
      padding: EdgeInsets.all(16.0),
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * 0.8, // 80% of screen height
      ),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (budgetModel.getCurrentBudget() < 0) Text('Oops...'),
            if (budgetModel.isBudgetNotSet())
              Row(children: [
                Text("Please set budget"),
                SizedBox(
                  width: 120,
                  child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) {
                        final parsedValue = double.tryParse(value);
                        if (parsedValue == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Invalid budget value")),
                          );
                        } else {
                          budgetModel.setInitialBudget(parsedValue);
                          _controller.clear();
                        }
                      }),
                )
              ]),
            BigCard(value: budgetModel.getCurrentBudget()),
            SizedBox(height: 20),
            StatLine(
                label: 'Initial budget', value: budgetModel.getInitialBudget()),
            StatLine(label: 'Spent so far', value: budgetModel.getSpent()),
            budgetModel.showValueInput
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter amount",
                            // border: OutlineInputBorder(),
                            errorText: _controller.text.isEmpty
                                ? null
                                : (double.tryParse(_controller.text) == null
                                    ? "Invalid number"
                                    : null),
                          ),
                          onSubmitted: (value) {
                            print("VAL: ${value}");
                            var hasError = false;
                            if (value.isNotEmpty) {
                              final parsedValue = double.tryParse(value);
                              if (parsedValue != null) {
                                budgetModel.addTransaction(parsedValue);
                                _controller.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Transaction added: $parsedValue")),
                                );
                                // _controller.clear();
                              } else {
                                hasError = true;
                              }
                            } else {
                              hasError = true;
                            }
                            if (hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Invalid value")),
                              );
                              budgetModel.toggleValueInput();
                            }
                          },
                          // budgetModel.addTransaction(100),
                          autofocus: true,
                          onTapOutside: (event) =>
                              budgetModel.toggleValueInput(),
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SizedBox(height: 150),
                        // ElevatedButton.icon(
                        //     onPressed: () {
                        //       // budgetModel.addTransaction(100);
                        //       budgetModel.toggleValueInput();
                        //     },
                        //     icon: Icon(Icons.remove_circle, size: 10),
                        //     label: Text('Add 100',
                        //         style: TextStyle(fontSize: 20))),
                        IconButton(
                          onPressed: () {
                            budgetModel.toggleValueInput();
                          },
                          icon: Icon(Icons.remove_circle),
                          iconSize: 100,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 20),
                        IconButton(
                            onPressed: () {
                              budgetModel.subtractTransaction(100);
                            },
                            iconSize: 40,
                            color: theme.colorScheme.secondary,
                            icon: Icon(Icons.add_circle)),
                        // ===============================================
                        // IconButton(
                        //   onPressed: () {
                        //     budgetModel.addTransaction(100);
                        //   },
                        //   icon: Icon(Icons.add_circle),
                        //   iconSize: 100,
                        //   color: theme.colorScheme.primary,
                        // ),
                        //   onPressed: () {
                        //     budgetModel.subtractTransaction(100);
                        //   },
                        // ElevatedButton.icon(
                        //     onPressed: () {
                        //       budgetModel.addTransaction(100);
                        //     },
                        //     icon: Icon(plusIcon),
                        //     label: Text('Add 100')),
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     budgetModel.subtractTransaction(100);
                        //   },
                        //   icon: Icon(minusIcon),
                        //   label: Text('Subtract hundred'),
                        // )
                      ]),
            IconButton(
                onPressed: () => {budgetModel.resetAll()},
                icon: Icon(Icons.replay_outlined))
          ],
        ),
      ),
    ))));
  }
}

class StatLine extends StatelessWidget {
  const StatLine({super.key, required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var f = NumberFormat.currency(locale: "ja", symbol: "¥");
    final labelStyle = theme.textTheme.displaySmall!.copyWith(
      // color: theme.colorScheme.onPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSecondary,
      // backgroundColor: Colors.,
    );
    // final valueStyle = theme.textTheme.displaySmall!.copyWith(
    //   color: theme.colorScheme.onPrimary,
    //   // backgroundColor: theme.cardColor,
    //   fontWeight: FontWeight.bold,
    // );

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              // Expanded(
              SizedBox(width: 15),
              Card(
                color: theme.colorScheme.secondary,
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Text(
                      '$label: ${f.format(value)}',
                      style: labelStyle,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(width: 40),
                  ],
                ),
                // ),
              ),
            ]
            //   Card(
            //       color: valueStyle.backgroundColor,
            //       child: Text('${label} ${value.toStringAsPrecision(2)}')),
            // ]),
            ));
  }
}

class MyAppState extends ChangeNotifier {
  // ======= OLD ===============
  var currentWord = WordPair.random();

  var favorites = <WordPair>[];

  void getNext() {
    currentWord = WordPair.random();
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(currentWord)) {
      favorites.remove(currentWord);
    } else {
      favorites.add(currentWord);
    }
    notifyListeners();
  }
  // ======= OLD ===============

  var budget;
  var current;
  var spent;
  var earned;
  var records = [];
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = Placeholder();
        // page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
            SafeArea(
              child: BottomNavigationBar(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerLow,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Favorites',
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                ],
                currentIndex: selectedIndex,
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

// =================== OLD =======================================
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.currentWord;
    final theme = Theme.of(context);

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BigCard(pair: pair),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavorite();
                    },
                    icon: Icon(icon),
                    label: Text('Like')),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                  // style: ButtonStyle(
                  //     backgroundColor:
                  //         WidgetStateProperty.all(theme.colorScheme.secondary))
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    final theme = Theme.of(context);

    if (favorites.isEmpty) {
      return Center(
        child: Text("No favorites yet."),
      );
    }

    var favText = favorites.length > 1 ? 'favorites.' : 'favorite.';

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${favorites.length} ${favText}'),
        ),
        for (var pair in favorites)
          ListTile(
            leading: ElevatedButton.icon(
              onPressed: () {
                appState.removeFavorite(pair);
              },
              icon: Icon(Icons.favorite),
              label: Text(pair.asPascalCase),
            ),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.value,
  });

  // final WordPair pair;
  final double value;

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat.currency(locale: "ja", symbol: "¥");
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          f.format(value),
          // "HELLO",
          style: style,
          semanticsLabel: "${value.toStringAsFixed(0)}",
        ),
      ),
    );
  }
}
// =================== OLD =======================================
