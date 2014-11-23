part of laser.server;


class TestSession {

  String _test_file;
  List<int> _limit = [];

  TestRunModel _test_model;
  List<Map> get model => _test_model.root;

  TestRunnerInstance _runner;

  final _controller = new StreamController<Map>.broadcast();
  Stream<Map> get stream => _controller.stream;

  TestSession(this._test_file);

  void init(TestRunnerInstance runner) {
    _test_model = new TestRunModel();
    _runner = runner;
    _runner.add({"limit": _limit});
  }

  void onData(Map data) {
    switch (data['type']) {
      case 'start':
        (data['tests'] as List).forEach((tc) => _test_model.add_test(tc['group'], tc));
        _controller.add({"updated": "update"});
        break;
      case 'test_start':
        //add_test(event['group'], event);
        break;
      case 'test_result':
      case 'test_result_changed':
        _test_model.add_result(data);
        _controller.add({"updated": "update"});
        break;
      case 'done':
        break;
      case 'summary':
        _test_model.record_summary(data);
        break;
      default:
        throw "Unsupported Event";
    }
  }
}


class TestRunModel {
  
  List<Map> root = [];

  void add_test(Iterable<String> groupcrumbs, Map event, {List<Map> groups: null}) {

    groups = groups!=null ? groups: root;

    var currentGroup = groups.
        firstWhere(
          (node)=> node['group']==groupcrumbs.first,
          orElse: () {
            var newGroup = {'group': groupcrumbs.first, 'groups': [], 'tests': []};
            groups.add(newGroup);
            return newGroup;
          }
    );

    var remainingGroups = groupcrumbs.skip(1);
    if (remainingGroups.length == 0) {
      event.remove('type');
      event.remove('group');
      currentGroup['tests'].add(event);
    } else {
      add_test(remainingGroups, event, groups: currentGroup['groups']);
    }

  }

  void add_result(Map event) {
    var group = root;
    event['group'].forEach((g) {
      group = group.firstWhere((node) => node["group"]==g);
    });
    Map test = group['tests'].firstWhere((test) => test["test"]==event["test"]);
    test.addAll(event);
  }

  void record_summary(Map event) {
    
  }
}