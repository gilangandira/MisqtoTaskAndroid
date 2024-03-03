import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/AssetsModel.dart';
import 'AddAssetsPage.dart';
import 'ListAssets.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int? _selectedIndex;
  final List<Condition> _choiceChipsList = [
    Condition(id: 1, name: 'Normal'),
    Condition(id: 2, name: 'Rusak'),
    Condition(id: 3, name: 'Hilang'),
  ];
  late Future<String> _role;
  String keyword = '';
  int isSelected = 1;
  @override
  void initState() {
    super.initState();
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        floatingActionButton: FutureBuilder<String>(
          future: _role,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Menampilkan widget loading jika sedang mendapatkan data peran
              return const CircularProgressIndicator(); // Atau tampilan loading yang sesuai
            } else {
              if (snapshot.hasError) {
                // Menampilkan pesan kesalahan jika terjadi kesalahan
                return Text('Error: ${snapshot.error}');
              } else {
                // Menampilkan drawer sesuai dengan peran pengguna
                final userRole = snapshot.data ?? "";
                if (userRole == 'admin') {
                  return DraggableFab(
                    child: FloatingActionButton(
                      backgroundColor: Colors.blueAccent,
                      splashColor: Colors.blue[100],
                      child: const Icon(Icons.add,color: Colors.white,size: 50,),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddDataAssets(),
                          ),
                        );
                      },
                    ),
                  ); // Tampilkan drawer admin jika peran adalah admin
                } else {
                  // Tambahkan pengembalian nilai widget di sini untuk menangani kasus lainnya
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  ); // Atau widget sesuai dengan kondisi yang diinginkan
                }
              }
            }
          },
        ),
        //

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ////////Welcome Name//////////
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 6,
                          ),
                        ],
                      ),
                    ],
                  ),
                  /////////Search Bar/////////
                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                keyword = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search",
                              prefixIcon: const Icon(CupertinoIcons.search_circle),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.blue[600],
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 5),
                              hintStyle: const TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => BottomSheetWidget(
                                choiceChipsList: _choiceChipsList,
                                selectedIndex: _selectedIndex,
                                onSelected: (int index) {
                                  setState(() {
                                    _selectedIndex = index;
                                    keyword = _choiceChipsList[index].name;
                                  });
                                },
                              ),
                            );
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.sort,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                child: Container(
                  color: Colors.white,
                  child: ListAssets(keyword: keyword),
                ),
              ),
            ),
          ],
        )); // Tampilkan drawer member jika peran adalah member
  }
}

class BottomSheetWidget extends StatefulWidget {
  final List<Condition> choiceChipsList;
  final int? selectedIndex;
  final Function(int) onSelected;

  const BottomSheetWidget({super.key,
    required this.choiceChipsList,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  void didUpdateWidget(BottomSheetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Memastikan bahwa perubahan pada selectedIndex direfleksikan setelah widget diperbarui
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() {}); // Memaksa rebuild widget ketika selectedIndex berubah
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: 150,
      width: width,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
              child: Text("Sort By Condition",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                  ))),
          Row(
            children: [
              for (int i = 0; i < widget.choiceChipsList.length; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelected(i);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text(widget.choiceChipsList[i].name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        )),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
