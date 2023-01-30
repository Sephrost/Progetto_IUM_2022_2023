import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/login_controller.dart';

class ProfileWidget extends StatelessWidget {
  /// Url of the image to display
  final String imagePath;

  /// Callback function when the image is clicked
  final VoidCallback onClicked;

  /// Status of the profile page:
  /// static: the user is the profile page
  /// edit: the user is editing the profile page
  final String status;

  /// This widget displays the profile image of the user.
  ///
  /// If the user is logged in and is in the profile,
  /// the image can be clicked to edit the profile image.
  ///
  /// If the user is a guest or is in the editing view of the profile, the image cannot be clicked.
  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;

    /// clickable version of the profile image
    if (status == "Static" &&
        LoginController().status == AutehticationStatus.authenticated) {
      return Center(
        child: Stack(
          children: [
            buildImage(),
            Positioned(
              bottom: 0,
              right: 4,
              child: GestureDetector(
                onTap: onClicked,
                child: buildEditIcon(context, color),
              ),
            ),
          ],
        ),
      );

      /// non-clickable version of the profile image
    } else {
      return Center(
        child: Stack(
          children: [
            buildImage(),
          ],
        ),
      );
    }
  }

  /// Widget that actually creates the image from the url
  Widget buildImage() {
    final image = NetworkImage(imagePath);
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(
              onTap:
                  LoginController().status == AutehticationStatus.authenticated
                      ? onClicked
                      : null),
        ),
      ),
    );
  }

  /// Widget that creates the edit icon
  Widget buildEditIcon(BuildContext context, Color color) => buildCircle(
        color: color,
        all: 8,
        child: Icon(
          color: Theme.of(context).colorScheme.primary,
          Icons.edit,
          size: 20,
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
