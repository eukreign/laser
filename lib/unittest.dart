library laser.unittest;

import 'dart:html';
import 'package:unittest/unittest.dart';
export 'package:unittest/unittest.dart';

class LaserConfiguration extends SimpleConfiguration {

    bool get autoStart => false;

    void onTestResult(TestCase test) {
        super.onTestResult(test);
        print("sending message: "+test.result);
        window.postMessage({
  "greeting": test.result,
  "source": "my-devtools-extension"}, "*");
    }
}