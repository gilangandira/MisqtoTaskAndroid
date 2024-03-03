
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';


class ViewProfile extends StatefulWidget {
  final Map user;
  const ViewProfile({super.key, required this.user});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Customer'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            child: Column(
                children: [
              /// -- IMAGE
              SizedBox(
                width: 120,
                height: 120,
                child: InstaImageViewer(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image(
                        image: NetworkImage(
                            "https://misqot.repit.tech/storage/profile-image/${widget.user['image']}"),
                        fit: BoxFit.fitWidth,
                      )),
                ),
              ),

              const SizedBox(height: 10),
              Text(widget.user['name'],
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(widget.user['email'],
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
                  ProfileCustomerWidget(
                      title: widget.user['jabatan'], icon: Bootstrap.person_workspace),
                  ProfileCustomerWidget(
                      title: widget.user['kelamin'], icon: Bootstrap.gender_ambiguous),
              const Divider(),
              const SizedBox(height: 10),
              ProfileCustomerWidget(
                  title: widget.user['agama'], icon: Bootstrap.moon_stars_fill),
              ProfileCustomerWidget(
                  title: widget.user['role'], icon: Bootstrap.gender_ambiguous),
              ProfileCustomerWidget(
                  title: widget.user['alamat'], icon: Bootstrap.house),
            ]),
          ),
        ));
  }
}

class ProfileCustomerWidget extends StatelessWidget {
  const ProfileCustomerWidget({
    super.key,
    required this.title,
    required this.icon,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon),
      ),
      title: Text(title,
          style:
              Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
    );
  }
}
