class MAccount {
  final String EmpCode;
  final String EmpName;
  final String EmpRole;

  MAccount({
    required this.EmpCode,
    required this.EmpName,
    required this.EmpRole,
  });

  factory MAccount.fromJson(Map<String, dynamic> json) {
    return MAccount(
        EmpCode: json["empCode"].toString(),
        EmpName: json["empName"].toString(),
        EmpRole: json["empRole"].toString());
  }
}
