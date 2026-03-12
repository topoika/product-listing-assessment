import 'package:flutter_test/flutter_test.dart';
import 'package:winp_flux_assessment/services/html_content_service.dart';

void main() {
  late HtmlContentService service;

  setUp(() {
    service = HtmlContentService();
  });

  group('HtmlContentService', () {
    test('stripTags removes simple HTML tags', () {
      const input = '<h1>Heading</h1>';
      expect(service.stripTags(input), 'Heading');
    });

    test('stripTags removes nested and multiple HTML tags', () {
      const input = '<div><p>Hello <b>World</b>!</p></div>';
      expect(service.stripTags(input), 'Hello World!');
    });

    test('stripTags handles tags with attributes', () {
      const input =
          '<a href="https://david-topoika.com" class="link-style">Portfolio</a>';
      expect(service.stripTags(input), 'Portfolio');
    });

    test('stripTags returns original string if no tags', () {
      const input = 'Simple plain text.';
      expect(service.stripTags(input), 'Simple plain text.');
    });

    test('stripTags handles empty strings', () {
      expect(service.stripTags(''), '');
    });

    test('hasBlockContent for block-level tags', () {
      expect(service.hasBlockContent('<p>Paragraph</p>'), isTrue);
      expect(service.hasBlockContent('<div>Section</div>'), isTrue);
      expect(service.hasBlockContent('<ul><li>List Item</li></ul>'), isTrue);
      expect(service.hasBlockContent('<h1>Title</h1>'), isTrue);
    });

    test('hasBlockContent returns false for purely inline tags', () {
      expect(service.hasBlockContent('<b>Bold text</b>'), isFalse);
      expect(service.hasBlockContent('<i>Italic text</i>'), isFalse);
      expect(service.hasBlockContent('<span>Inline text</span>'), isFalse);
      expect(service.hasBlockContent('Click <a href="link">here</a>'), isFalse);
    });

    test('hasBlockContent returns false for plain text or empty strings', () {
      expect(service.hasBlockContent('Simple string with no HTML'), isFalse);
      expect(service.hasBlockContent(''), isFalse);
    });
  });
}
