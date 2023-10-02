class MRunningTestInfo {
  final String serial;
  final String line;
  final String holdStatus;
  final String header;
  final String detail;

  MRunningTestInfo({
    required this.serial,
    required this.line,
    required this.holdStatus,
    required this.header,
    required this.detail,
  });

  factory MRunningTestInfo.fromJson(Map<String, dynamic> json) {
    return MRunningTestInfo(
        serial: json['serial'].toString(),
        line: json['line'].toString(),
        holdStatus: json['holdStatus'].toString(),
        header: json['header'].toString(),
        detail: json['detail'].toString());
  }
}
