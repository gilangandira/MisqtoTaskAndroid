import 'package:flutter/material.dart';


import 'CustomerAssetsDetail.dart';
import '../Model/AssetsModel.dart';


class VendorAssetsDetail extends StatelessWidget {
  final Assets assets;
  const VendorAssetsDetail({Key? key, required this.assets}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Customer'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40,horizontal: 10),
          child: Column(
            children: [
              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100), child: const Image(image: NetworkImage("http://10.0.2.2:8000/storage/asset-image/ss.png"),fit: BoxFit.cover,)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),color: Colors.blue),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )],
              ),
              const SizedBox(height: 10),
              Text(assets.vendor.name, style: Theme.of(context).textTheme.headlineMedium),
              Text(assets.vendor.lanSpeed, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// Vendor
              ProfileCustomerWidget(title: assets.vendor.name, icon: Icons.wifi_tethering),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerAssetsDetail(assets: assets),
                      ),
                    );
                  },
                  child: ProfileCustomerWidget(title: assets.customer.customersName, icon: Icons.people)),
              const Divider(),
              const SizedBox(height: 10),
              ProfileCustomerWidget(title: assets.vendor.cpu, icon: Icons.numbers),
              ProfileCustomerWidget(title: assets.vendor.cpuCore, icon: Icons.numbers),
              ProfileCustomerWidget(title: assets.vendor.lanPorts, icon: Icons.date_range),
              ProfileCustomerWidget(title: assets.vendor.ram, icon: Icons.wallet),
              ProfileCustomerWidget(title: assets.vendor.wirelessStandars, icon: Icons.wallet),
              ProfileCustomerWidget(title: assets.vendor.guestNetwork, icon: Icons.network_cell),
              ProfileCustomerWidget(title: assets.vendor.power, icon: Icons.power)
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


    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
    );
  }
}
