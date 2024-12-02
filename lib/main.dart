import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const Home(),
    );
  }
}

class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final inAppParam = useState(true);
    final linkController = useTextEditingController(text: 'https://glints.com');
    final dynamicLinkController = useTextEditingController();

    useEffect(
      () {
        void listener() {
          final uri = Uri.tryParse(linkController.text);
          if (uri == null) return;
          final url = uri.replace(
            queryParameters: {
              ...uri.queryParameters,
              if (inAppParam.value) 'inapp': '1',
            },
          ).toString();
          final encoded = Uri.encodeComponent(url);
          dynamicLinkController.text =
              'https://dynamic-link.glints.com/page/?apn=com.glints.candidate&isi=1613169954&ibi=com.glints.candidate&link=$encoded';
        }

        listener.call();
        inAppParam.addListener(listener);
        linkController.addListener(listener);
        return () {
          inAppParam.removeListener(listener);
          linkController.removeListener(listener);
        };
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glints Dynamic Links'),
        actions: [
          TextButton(
            onPressed: () {
              launchUrl(
                Uri.parse(
                  'https://github.com/LuckUVeryX/glints_dynamic_links',
                ),
              );
            },
            child: const Text('GitHub'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  autofocus: true,
                  maxLines: null,
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Link',
                  ),
                ),
                const SizedBox.square(dimension: 16),
                HookBuilder(
                  builder: (context) {
                    final uri = Uri.tryParse(
                      useValueListenable(dynamicLinkController).text,
                    );

                    return TextField(
                      maxLines: null,
                      readOnly: true,
                      controller: dynamicLinkController,
                      decoration: InputDecoration(
                        labelText: 'Dynamic Link',
                        suffix: IconButton(
                          onPressed: uri == null
                              ? null
                              : () {
                                  launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                          icon: const Icon(Icons.launch),
                        ),
                      ),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(
                          ClipboardData(
                            text: dynamicLinkController.text,
                          ),
                        );
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox.square(dimension: 16),
                Column(
                  children: [
                    Switch(
                      value: inAppParam.value,
                      onChanged: (value) {
                        inAppParam.value = value;
                      },
                    ),
                    const Text('inapp'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
