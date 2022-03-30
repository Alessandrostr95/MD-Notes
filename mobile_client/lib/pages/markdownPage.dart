import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MarkDownPage extends StatelessWidget {
  const MarkDownPage({ Key? key}) : super(key: key);
  static String PATH = "/notes";

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final path = args["path"];
    final data = args["data"];
    
    return Scaffold(
      appBar: AppBar(
        title: Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(path)
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Markdown(
          data: data,
          // builders: {"sub": SubscriptBuilder()},
          // extensionSet: md.ExtensionSet(
          //   <md.BlockSyntax>[], <md.InlineSyntax>[SubscriptSyntax()]
          // ),
        ),
      ),
    );
  }
}

class SubscriptSyntax extends md.InlineSyntax {
  SubscriptSyntax() : super(_pattern);
  static const _pattern = r'_([0-9]+)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]!));
    return true;
  }
}

class SubscriptBuilder extends MarkdownElementBuilder {
    static const List<String> _subscripts = <String>[
    '₀',
    '₁',
    '₂',
    '₃',
    '₄',
    '₅',
    '₆',
    '₇',
    '₈',
    '₉'
  ];

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;
    String text = '';
    for (int i = 0; i < textContent.length; i++) {
      text += _subscripts[int.parse(textContent[i])];
    }
    return SelectableText.rich(TextSpan(text: text));
  }
}