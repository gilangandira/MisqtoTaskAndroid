import 'package:flutter/material.dart';
import '../Model/AssetsModel.dart';

class CustomerAssetsDetail extends StatelessWidget {
  final Assets assets;
  const CustomerAssetsDetail({super.key, required this.assets});

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
                        borderRadius: BorderRadius.circular(100), child: Image(image: NetworkImage("http://10.0.2.2:8000/storage/${assets.customer.image}"),fit: BoxFit.cover,)),
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
              Text(assets.customer.customersName, style: Theme.of(context).textTheme.headlineMedium),
              Text(assets.customer.location, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileCustomerWidget(title: assets.customer.ppoeUsername, icon: Icons.email),
              ProfileCustomerWidget(title: assets.customer.ppoePassword, icon: Icons.password,),
              ProfileCustomerWidget(title: assets.customer.ipClient,icon: Icons.integration_instructions,),
              ProfileCustomerWidget(title: assets.customer.apSsid,icon: Icons.wifi_tethering,),
              ProfileCustomerWidget(title: assets.customer.channelFrequensy.toString(),icon: Icons.wifi_tethering,),
              const Divider(),
              const SizedBox(height: 10),
              ProfileCustomerWidget(title: assets.customer.subscriptionFee.toString(), icon: Icons.wallet,),
              ProfileCustomerWidget(title: assets.customer.bandwith.toString(), icon: Icons.speed,),
              ProfileCustomerWidget(title: assets.customer.startDates, icon: Icons.date_range,),
            ],
          ),
        ),
      ),
    );
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
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
    );
  }
}
