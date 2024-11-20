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
          final encodedLink = Uri.encodeFull(
            '${linkController.text}${inAppParam.value ? '&inapp=1' : ''}',
          );
          dynamicLinkController.text =
              'https://glintsapp.page.link/?apn=com.glints.candidate&isi=1613169954&ibi=com.glints.candidate&link=$encodedLink';
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
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Decide layout based on available width
          final isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Flex(
                direction: isWideScreen ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextField(
                      autofocus: true,
                      maxLines: null,
                      controller: linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link',
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 16),
                  Flexible(
                    child: HookBuilder(
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
                  ),
                  const SizedBox(height: 8),
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
          );
        },
      ),
    );
  }
}
