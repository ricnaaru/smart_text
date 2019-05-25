# Smart Text

Text to render emoji well by decreasing its height, and draw hyperlink as well (Inspired by [Flutter Linkify](https://pub.dartlang.org/packages/flutter_linkify))

*Note*: This plugin is still under development, and some Components might not be available yet or still has so many bugs.
- We are using [URL Launcher](https://pub.dartlang.org/packages/url_launcher) library too to support this Text to launch URL right away

## Installation

First, add `smart_text` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```
smart_text: ^0.0.1+2
```

## Example
```
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    String content =
        "The Avengers are a fictional team of superheroes appearing in American comic books published by Marvel Comics. The team made its debut in The Avengers #1 (cover-dated Sept. 1963), created by writer-editor Stan Lee and artist/co-plotter Jack Kirby. The Avengers is Lee and Kirby's renovation of a previous superhero team, All-Winners Squad, who appeared in comic books series published by Marvel Comics' predecessor Timely Comics.\n\nLabeled \"Earth's Mightiest Heroes\", the Avengers originally consisted of Ant-Man, the Hulk, Iron Man, Thor, and the Wasp. Ant-Man had become Giant-Man by issue #2. The original Captain America was discovered trapped in ice in issue #4, and joined the group after they revived him. A rotating roster became a hallmark of the series, although one theme remained consistent: the Avengers fight \"the foes no single superhero can withstand.\" The team, famous for its battle cry of \"Avengers Assemble!\", has featured humans, mutants, Inhumans, androids, aliens, supernatural beings, and even former villains. 💫🤩🌟\n\n\nSource: https://en.wikipedia.org/wiki/Avengers_(comics)";

    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light, primaryColorBrightness: Brightness.light),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Smart Text Demo'),
          ),
          body: SingleChildScrollView(
            child: SmartText(content, maxLines: 5),
          )),
    );
  }
}
```
