fun() {
  int index = 0;
  list.reduce((combined, data) {
    print('${index++}: ${combined} ${data}');
    return (combined as List).addAll(null);
  });
}

List list = [
  /// 1

  [],

  /// 2
  1,

  ///
  2,

  /// 3
  "3",

  "4",

  /// 4
  ["40", "50", "44,55"],

  /// 5
  "45,60,90",

  ///6
  [45, 89, 67],

  ///7
  null
];

splitc(String string, RegExp reg, [RegExp joined]) {
  if (!reg.hasMatch(string)) return [string];
  int index = 0;
  var ret = []
    ..insert(0, [])
    ..addAll(reg.allMatches(string));
  ret = ret.reduce((combine, regMatch) {
    int start = (regMatch as RegExpMatch).start;
    int end = (regMatch as RegExpMatch).end;
    var splitter = string.substring(start, end);
    if (joined != null && joined.hasMatch(splitter)) {
      combine.add(string.substring(index, end));
    } else {
      combine.add(string.substring(index, start));
    }
    index = end;
    return combine;
  });
  if (index != string.length) {
    ret.add(string.substring(index));
  }
  return ret;
}

splitb(string, splitter) {
  var ret = []..addAll(string.split(splitter));
  return ret.reduce((initOrCombine, value) {
    if (initOrCombine is List) {
      (initOrCombine as List).addAll([value, splitter].toList());
    } else {
      return [initOrCombine, splitter, value, splitter].toList();
    }
    return initOrCombine;
  });
}

splita(data) {
  print('splita ${data}');

  /// 针对1、7进行干扰排除
  if (data == [] || data == null) return [];

  /// 针对2、3、5进行格式对齐 非List -> List<dynamic>
  if (!(data is List)) {
    data = [data];
  }

  var ret = []

    /// 针对运行时类型检查进行类型化归
    /// 化归目标List<String> -> List<dynamic>
    /// 化归目标List<num> -> List<dynamic>
    ..addAll((data as List).sublist(0))
    ..insert(0, []);
  return ret.reduce((combined, item) {
    if (data == [] || data == null) return combined;

    /// 针对3、5采用处理对齐
    if (item is String) {
      (combined as List).addAll(item.split(','));
    } else

    /// 针对2、6进行数字转字符
    if (item is num) {
      (combined as List).add("${item}");
    } else if (item is List && item != []) {
      print('split reduce ${item} is List');
      (combined as List).addAll(splita(item));
    }
    return combined;
  });
}

main() {
  // print(splita("44,45"));
  // print(splita(["40", "50", "44,55"]));
  // print(splita(null));
  // print(splita([
  //   [],
  //   null,
  //   [
  //     [],
  //     null,
  //     [null]
  //   ]
  // ]));
  // print(splita("40,50,90,110,21"));
  // print(splita(list));
  // var forTestB = splitb("40,50:90,110:21", ",");
  // print('len:${forTestB.length} $forTestB');
  // print(splitc(
  //     "40,50+90,110+21,112+33:31+12!", RegExp(r"[,:!\+]+"), RegExp(r"[:\+]+")));
  // print(splitc("40,50+90,110+21,112+33:31+12!", RegExp(r"[,:!\+]+"),
  //     RegExp(r"[,:!\+]+")));
  // print("40,50+90,110+21,112+33:31+12!".split("!"));
  print(splitc(",40,50+90。,。110+21,", RegExp(r"[,。]+"), RegExp(r"[。]+")));
  // print(splitc("果酱V 视播口袋书，你的果酱～你的口袋～你的书～", RegExp(r"[~, ，]")));
}
