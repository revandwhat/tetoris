import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const TetorisApp());
}

class TetorisApp extends StatelessWidget {
  const TetorisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TETORIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  WebViewController? _controller;

  // Safety net: game never crashes even if WebView storage is blocked.
  static const String _storageShim = '''
<script>
(function(){
  try { window.localStorage.getItem('__t'); }
  catch (e) {
    var m = {};
    Object.defineProperty(window, 'localStorage', {
      configurable: true,
      value: {
        getItem: function (k) { return Object.prototype.hasOwnProperty.call(m, k) ? m[k] : null; },
        setItem: function (k, v) { m[k] = String(v); },
        removeItem: function (k) { delete m[k]; },
        clear: function () { m = {}; },
        key: function (i) { return Object.keys(m)[i] || null; },
        get length() { return Object.keys(m).length; }
      }
    });
  }
})();
</script>
''';

  @override
  void initState() {
    super.initState();
    _openGame();
  }

  Future<void> _openGame() async {
    final String html = await rootBundle.loadString('assets/game.html');

    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101522))
      ..loadHtmlString(_storageShim + html, baseUrl: 'https://tetoris.local/');

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101522),
      body: _controller == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5865F2)),
            )
          : WebViewWidget(controller: _controller!),
    );
  }
}
