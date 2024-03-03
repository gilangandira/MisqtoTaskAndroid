import 'package:flutter/material.dart';
import 'package:http/http.dart' as myAPI;

import 'ListProfile.dart';

class AddUsers extends StatefulWidget {
  const AddUsers({super.key});

  @override
  State<AddUsers> createState() => _AddUsersState();

}

class _AddUsersState extends State<AddUsers> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String selectedRole = 'Member';
  Future saveData() async {
    await myAPI.post(Uri.parse("https://misqot.repit.tech/api/register"), body: {
      'name': _name.text,
      'email': _email.text,
      'password': _password.text,
      'role': selectedRole,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Tambah Data User"),
      ),
      body: SingleChildScrollView(
        child: Card(
          elevation: 10,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: "Nama", icon: Icon(Icons.person)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukan Nama User";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                      labelText: "Email", icon: Icon(Icons.email)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukan Email";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(
                      labelText: "Password", icon: Icon(Icons.password)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukan Password";
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  value: selectedRole,
                  onChanged: (newValue) {
                    // Ketika opsi berubah
                    setState(() {
                      selectedRole = newValue.toString();
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: 'Member',
                      child: Text('Member'),
                    ),
                    const DropdownMenuItem(
                      value: 'Admin',
                      child: Text('Admin'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    icon: Icon(Icons.install_desktop_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih Role';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    // _registerUser();
                    if (_formKey.currentState!.validate()) {
                      saveData();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ListProfile()));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Data Berhasil Ditambah")));
                    } else {}
                    saveData();
                  },
                  child: const Text('Save'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
