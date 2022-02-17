import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ExtractArgumentsScreen.routeName: (context) =>
            const ExtractArgumentsScreen(),
      },
      // Provide a function to handle named routes.
      // Use this function to identify the named
      // route being pushed, and create the correct
      // Screen.
      onGenerateRoute: (settings) {
        // If you push the PassArguments route
        if (settings.name == PassArgumentsScreen.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final args = settings.arguments as ScreenArguments;

          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return PassArgumentsScreen(
                title: args.title,
                message: args.message,
              );
            },
          );
        }
        // The code only supports
        // PassArgumentsScreen.routeName right now.
        // Other values need to be implemented if we
        // add them. The assertion here will help remind
        // us of that higher up in the call stack, since
        // this assertion would otherwise fire somewhere
        // in the framework.
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      title: 'Cryto Reminder',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A button that navigates to a named route.
            // The named route extracts the arguments
            // by itself.
            ElevatedButton(
              onPressed: () {
                // When the user taps the button,
                // navigate to a named route and
                // provide the arguments as an optional
                // parameter.
                Navigator.pushNamed(
                  context,
                  PassArgumentsScreen.routeName,
                  arguments: ScreenArguments(
                    'BTC/USD',
                    'btc',
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('btc-icon.png'),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 100.0,
                    child: const Text(
                      'BTC/USD',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Century Gothic', fontSize: 20.0),
                    ),
                  ),
                  Container(
                    height: 100.0,
                    width: 400.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('btc.jpg'),
                        fit: BoxFit.fitHeight,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Container(
                    width: 100.0,
                    child: const Text(
                      '\$38,681.25\n+4%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontFamily: 'Century Gothic', fontSize: 17.0),
                    ),
                  ),
                ],
              ),
            ),
            // A button that navigates to a named route.
            // For this route, extract the arguments in
            // the onGenerateRoute function and pass them
            // to the screen.
            ElevatedButton(
              onPressed: () {
                // When the user taps the button, navigate
                // to a named route and provide the arguments
                // as an optional parameter.
                Navigator.pushNamed(
                  context,
                  PassArgumentsScreen.routeName,
                  arguments: ScreenArguments(
                    'ETH/USD',
                    'eth',
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('eth-icon.png'),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 100.0,
                    child: const Text(
                      'ETH/USD',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Century Gothic', fontSize: 20.0),
                    ),
                  ),
                  Container(
                    height: 100.0,
                    width: 400.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('eth.jpg'),
                        fit: BoxFit.fitHeight,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Container(
                    width: 100.0,
                    child: const Text(
                      '\$3,024.12\n+8.36%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontFamily: 'Century Gothic', fontSize: 17.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A Widget that extracts the necessary arguments from
// the ModalRoute.
class ExtractArgumentsScreen extends StatelessWidget {
  const ExtractArgumentsScreen({Key? key}) : super(key: key);

  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
      ),
      body: Center(
        child: Text(args.message),
      ),
    );
  }
}

// A Widget that accepts the necessary arguments via the
// constructor.
class PassArgumentsScreen extends StatelessWidget {
  static const routeName = '/passArguments';

  final String title;
  final String message;

  const PassArgumentsScreen({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final msg = message;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: 500,
              width: 500,
              decoration: BoxDecoration(
                image: DecorationImage(
                  // use message to open the image, which can be use with API in future implementation
                  image: AssetImage('assets/$msg.jpg'),
                ),
                shape: BoxShape.rectangle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}