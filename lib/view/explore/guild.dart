import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/services/api/xenforo_node_api.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Guild extends StatefulWidget {
  final int nodeId;
  

  const Guild({super.key, required this.nodeId});

  @override
  State<Guild> createState() => _GuildState();
}

class _GuildState extends State<Guild> {
  late final WebViewController _controller;
  final NodeServices nodeService = NodeServices();
  Map<String, dynamic>? _nodeDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
     StatusBarUtil.setLightStatusBar();
    getNodeById();

   _controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onHttpError: (HttpResponseError error) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  )
  ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  Future<void> getNodeById() async {
    try {
      final node = await nodeService.getNodeById(widget.nodeId);
      setState(() {
        _nodeDetails = node;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching node: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _prepareHtmlContent(String content) {
    const String baseUrl = "https://pgi.org/"; // Replace with your actual base URL
    return content.replaceAll('/data/', '$baseUrl/data/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
       child: Column(
        children: [
          CustomAppBarBody(
            title: _nodeDetails?['node']?['title'] ?? 'Loading...',
          ),
          Expanded(
             child:  _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nodeDetails == null
              ? const Center(child: Text('No data available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: HtmlWidget(
                      _prepareHtmlContent(_nodeDetails!['node']['type_data']['content'] ?? '<p>No content available.</p>'),
                      customWidgetBuilder: (element) {
                        if (element.localName == 'iframe') {
                          final src = element.attributes['src'];
                          if (src != null) {
                            return SizedBox(
                              height: 300,
                              child: WebViewWidget(
                               controller: 
                               WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..setNavigationDelegate(
                                  NavigationDelegate(
                                    onNavigationRequest: (NavigationRequest request) {
                                      if (request.url.startsWith('https://www.youtube.com/')) {
                                        return NavigationDecision.prevent;
                                      }
                                      return NavigationDecision.navigate;
                                    },
                                  ),
                                )
                                ..loadRequest(Uri.parse(src))
                              ),
                            );
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
          )
        ],
       ), 
       
                )
    );
  }
}
