library laser.utils;

class TestBuilder {
  List<Map> root = [];
  
  void add(Iterable<String> groupcrumbs, String test, {List<Map> nodes: null}) {
    nodes = nodes!=null ? nodes: root;
    var group = nodes.
        firstWhere((node)=> node['group']==groupcrumbs.first,
        orElse: () {
          var newGroup = {'group': groupcrumbs.first, 'groups': [], 'tests': []};
          nodes.add(newGroup);
          return newGroup;
        }
    );
    var rest = groupcrumbs.skip(1);
    if (rest.length == 0) {
      group['tests'].add({'label': test});
    } else {
      add(rest, test, nodes: group['groups']);
    }
  }
  
}