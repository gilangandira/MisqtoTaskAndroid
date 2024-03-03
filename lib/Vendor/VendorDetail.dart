import 'package:flutter/material.dart';
import '../Model/AssetsModel.dart';


class VendorDetail extends StatelessWidget {
  final Vendor vendor;
  const VendorDetail({Key? key, required this.vendor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Customer'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40,horizontal: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(vendor.name, style: Theme.of(context).textTheme.headline4),
              Text(vendor.lanSpeed, style: Theme.of(context).textTheme.bodyText2),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// Vendor
              ProfileCustomerWidget(title: vendor.name, icon: Icons.wifi_tethering),
              const Divider(),
              const SizedBox(height: 10),
              ProfileCustomerWidget(title: vendor.cpu, icon: Icons.numbers),
              ProfileCustomerWidget(title: vendor.cpuCore, icon: Icons.numbers),
              ProfileCustomerWidget(title: vendor.lanPorts, icon: Icons.date_range),
              ProfileCustomerWidget(title: vendor.ram, icon: Icons.wallet),
              ProfileCustomerWidget(title: vendor.wirelessStandars, icon: Icons.wallet),
              ProfileCustomerWidget(title: vendor.guestNetwork, icon: Icons.network_cell),
              ProfileCustomerWidget(title: vendor.power, icon: Icons.power)
              ,
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCustomerWidget extends StatelessWidget {
  const ProfileCustomerWidget({
    Key? key,
    required this.title,
    required this.icon,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {

    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyText1?.apply(color: textColor)),
    );
  }
}
