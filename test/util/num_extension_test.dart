import 'package:flutter_test/flutter_test.dart';
import 'package:silgam/util/num_extension.dart';

void main() {
  group('NumExtension', () {
    group('toCompactString', () {
      test('returns integer string for whole numbers', () {
        expect(5.toCompactString(), '5');
        expect(10.toCompactString(), '10');
        expect(100.toCompactString(), '100');
        expect((-5).toCompactString(), '-5');
      });

      test('returns integer string for double whole numbers', () {
        expect(5.0.toCompactString(), '5');
        expect(10.0.toCompactString(), '10');
        expect(100.0.toCompactString(), '100');
        expect((-5.0).toCompactString(), '-5');
      });

      test('returns decimal string for fractional numbers', () {
        expect(5.5.toCompactString(), '5.5');
        expect(3.14.toCompactString(), '3.14');
        expect(10.75.toCompactString(), '10.75');
        expect((-3.14).toCompactString(), '-3.14');
      });

      test('handles trailing zeros correctly', () {
        expect(5.50.toCompactString(), '5.5');
        expect(10.10.toCompactString(), '10.1');
        expect(3.140.toCompactString(), '3.14');
      });

      test('handles zero correctly', () {
        expect(0.toCompactString(), '0');
        expect(0.0.toCompactString(), '0');
        expect((-0).toCompactString(), '0');
        expect((-0.0).toCompactString(), '0');
      });

      test('handles very small numbers', () {
        expect(0.1.toCompactString(), '0.1');
        expect(0.01.toCompactString(), '0.01');
        expect(0.001.toCompactString(), '0.001');
      });

      test('handles large numbers', () {
        expect(1000000.toCompactString(), '1000000');
        expect(1000000.0.toCompactString(), '1000000');
        expect(1000000.5.toCompactString(), '1000000.5');
      });

      test('handles edge cases with scientific notation', () {
        expect(1e6.toCompactString(), '1000000');
        expect(1e-6.toCompactString(), '0.000001');
      });

      test('works with different numeric types', () {
        // int
        int intValue = 42;
        expect(intValue.toCompactString(), '42');

        // double
        double doubleValue = 42.5;
        expect(doubleValue.toCompactString(), '42.5');

        // num as int
        num numAsInt = 42;
        expect(numAsInt.toCompactString(), '42');

        // num as double
        num numAsDouble = 42.5;
        expect(numAsDouble.toCompactString(), '42.5');
      });
    });
  });
}
