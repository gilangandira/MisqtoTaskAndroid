class Assets {
  final int id;
  final String userId;
  final int categoryId;
  final int conditionId;
  final int vendorId;
  final String image;
  final String namaAset;
  final String description;
  final String location;
  final String serialNumber;
  final String serialAssets;
  final String price;
  final String dateBuyed;
  final Condition condition;
  final User user;
  final Vendor vendor;
  final Customer customer;
  final AssetsCategory category;

  Assets({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.conditionId,
    required this.vendorId,
    required this.image,
    required this.namaAset,
    required this.description,
    required this.location,
    required this.serialNumber,
    required this.serialAssets,
    required this.price,
    required this.dateBuyed,
    required this.condition,
    required this.user,
    required this.vendor,
    required this.customer,
    required this.category,
  });

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      conditionId: json['condition_id'],
      vendorId: json['vendor_id'],
      image: json['image'],
      namaAset: json['nama_aset'],
      description: json['description'],
      location: json['location'],
      serialNumber: json['serial_number'],
      serialAssets: json['serial_assets'],
      price: json['price'],
      dateBuyed: json['date_buyed'],
      condition: Condition.fromJson(json['condition']),
      user: User.fromJson(json['user']),
      vendor: Vendor.fromJson(json['vendor']),
      customer: Customer.fromJson(json['customer']),
      category: AssetsCategory.fromJson(json['category']),
    );
  }
}

class Condition {
  final int id;
  final String name;

  Condition({required this.id, required this.name});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id'],
      name: json['name'],
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String image;
  final String kelamin;
  final String agama;
  final String jabatan;
  final String alamat;
  final String role;

  User({required this.id, required this.name, required this.email ,required this.image,required  this.kelamin,required  this.agama,required  this.jabatan,required  this.alamat,required  this.role});

factory User.fromJson(Map<String, dynamic> json) {
return User(
id: json['id'],
name: json['name'],
email: json['email'],
  image: json['image'],
  kelamin: json['kelamin'],
  agama: json['agama'],
  jabatan: json['jabatan'],
  alamat: json['alamat'],
  role: json['role'],
);
}
}

class Vendor {
  final int id;
  final String name;
  final String brand;
  final String cpu;
  final String cpuCore;
  final String ram;
  final String lanPorts;
  final String lanSpeed;
  final String wirelessStandars;
  final String guestNetwork;
  final String power;


  Vendor( {
    required this.id,
    required this.name,
    required this.cpu,
    required this.cpuCore,
    required this.ram,
    required this.lanPorts,
    required this.lanSpeed,
    required this.wirelessStandars,
    required this.guestNetwork,
    required this.power,
    required this.brand,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    cpu: json['cpu'],
    cpuCore: json['cpu_core'],
    ram: json['ram'],
    lanPorts: json['lan_ports'],
    lanSpeed: json['lan_speed'],
    wirelessStandars: json['wireless_standards'],
    guestNetwork: json['guest_network'],
    power: json['power'],
    );
  }
}

class AssetsCategory{
  final int id;
  final String name;

  AssetsCategory({
    required this.id, required this.name
  });

  factory AssetsCategory.fromJson(Map<String, dynamic> json) {
    return AssetsCategory(id: json['id'], name: json['name']);
  }
}

class Customer {
final int id;
final String customersName;
final String ppoeUsername;
final String ppoePassword;
final String image;
final String ipClient;
final String apSsid;
final int channelFrequensy;
final int bandwith;
final int subscriptionFee;
final String location;
final String startDates;

Customer({
required this.id,
required this.customersName,
required this.ppoeUsername,
required this.ppoePassword,
required this.image,
required this.ipClient,
required this.apSsid,
required this.channelFrequensy,
required this.bandwith,
required this.subscriptionFee,
required this.location,
required this.startDates,
});

factory Customer.fromJson(Map<String, dynamic> json) {
return Customer(
id: json['id'],
customersName: json['customers_name'],
ppoeUsername: json['ppoe_username'],
ppoePassword: json['ppoe_password'],
image: json['image'],
ipClient: json['ip_client'],
apSsid: json['ap_ssid'],
channelFrequensy: json['channel_frequensy'],
bandwith: json['bandwith'],
subscriptionFee: json['subscription_fee'],
location: json['location'],
startDates: json['start_dates'],
);
}
}


////////////////////Task Model//////////////
class Tasks {
  int id;
  String name;
  int statusId;
  int assetsId;
  int slaId;
  int timeTrackId;
  String description;

  DateTime dates;
  String location;
  DateTime updatedAt;
  DateTime createdAt;
  final AssetsTasks assetsTasks;
  final Status status;
  final SLA sla;
  final TimeTrack timeTrack;
  final List<String>? userIds;
  final List<User> users;

  Tasks({
    required this.id,
    required this.name,
    required this.statusId,
    required this.assetsId,
    required this.slaId,
    required this.timeTrackId,
    required this.description,

    required this.dates,
    required this.location,
    required this.updatedAt,
    required this.createdAt,
    required this.assetsTasks,
    required this.status,
    required this.sla,
    required this.timeTrack,
    this.userIds,
    required this.users,
  });

  factory Tasks.fromJson(Map<String, dynamic> json) {
    List<User> userList = (json['users'] as List)
        .map((userData) => User.fromJson(userData))
        .toList();
    return Tasks(
      // Deklarasi variabel userList
      id: json["id"],
      name: json["name"],
      statusId: json["status_id"],
      assetsId: json["assets_id"],
      slaId: json["assets_id"],
      timeTrackId: json["timetracker_id"],
      description: json["description"],
      dates: DateTime.parse(json["dates"]),
      location: json["location"],
      updatedAt: DateTime.parse(json["updated_at"]),
      createdAt: DateTime.parse(json["created_at"]),
      assetsTasks: AssetsTasks.fromJson(json['assets']),
      status: Status.fromJson(json['status']),
      sla: SLA.fromJson(json['sla']),
     timeTrack: TimeTrack.fromJson(json['timetracker']),
      userIds: (json['users'] as List).map((user) => user['id'].toString()).toList(),
      users: userList,
    );
  }
}

class SLA {
  final int id;
  final String name;
  final String waktu;
  SLA({required this.id, required this.name, required this.waktu});
  factory SLA.fromJson(Map<String, dynamic> json) {
    return SLA(
      id: json['id'],
      name: json['name'],
      waktu: json['waktu'],
    );
  }
}

class TimeTrack {
  final int id;
  final DateTime start_time;
  DateTime dueDates;
  final bool runningTime;
  final DateTime end_time;
  final int time_track;
  final int timer;

  TimeTrack({
    required this.id,
    required this.start_time,
    required this.runningTime,
    required this.dueDates,
    required this.end_time,
    required this.time_track,
    required this.timer,
  });

  factory TimeTrack.fromJson(Map<String, dynamic> json) {
    return TimeTrack(
      id: json['id'],
      start_time: DateTime.parse(json['start_time']),
      end_time: DateTime.parse(json['end_time']),
      dueDates: DateTime.parse(json["due_dates"]),
      runningTime: json['runing_time?'] is bool
          ? json['runing_time?']
          : json['runing_time?'] == 1,
      time_track: json['time_track'],
      timer: json['timer'],
    );
  }
}

class Status {
  final int id;
  final String name;
  Status({required this.id, required this.name});
  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'],
      name: json['name'],
    );
  }
}

class JobUser {
  final int id;
  final String userId;
  final int taskId;
  final User user;
  final Tasks tasks;

  JobUser({required this.id, required this.userId, required this.taskId, required this.user, required this.tasks});

  factory JobUser.fromJson(Map<String, dynamic> json) {
    return JobUser(
      id: json['id'],
      taskId: json['task_id'],
      userId: json['user_id'],
      user : User.fromJson(json['user']),
      tasks: Tasks.fromJson(json['task'])
    );
  }
}

class AssetsTasks {
  final int id;
  final String userId;
  final int categoryId;
  final int conditionId;
  final String image;
  final String namaAset;
  final String description;
  final String location;
  final String serialNumber;
  final String serialAssets;
  final String price;
  final String dateBuyed;

  AssetsTasks({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.conditionId,
    required this.image,
    required this.namaAset,
    required this.description,
    required this.location,
    required this.serialNumber,
    required this.serialAssets,
    required this.price,
    required this.dateBuyed,
  });

  factory AssetsTasks.fromJson(Map<String, dynamic> json) {
    return AssetsTasks(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      conditionId: json['condition_id'],
      image: json['image'],
      namaAset: json['nama_aset'],
      description: json['description'],
      location: json['location'],
      serialNumber: json['serial_number'],
      serialAssets: json['serial_assets'],
      price: json['price'],
      dateBuyed: json['date_buyed'],
    );
  }
}


