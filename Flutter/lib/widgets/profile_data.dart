import 'package:flutter/material.dart';

class ProfileData extends StatelessWidget {
  /// The name of the data to show
  final String dataName;

  /// The data to show
  final String data;

  /// Creates a widget that shows a data name and the data.
  ///
  /// It's use to show the profile data (name,address,tel)
  const ProfileData({
    Key? key,
    required this.dataName,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        dataName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 16,
      ),
      Text(
        data,
        style: const TextStyle(fontSize: 20, height: 1.4),
      ),
    ]);
  }
}
