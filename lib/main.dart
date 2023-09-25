import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

var factory = databaseFactoryFfiWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'my_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
      'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT, userType TEXT, address TEXT)', // Add 'address TEXT' to the table definition
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final Database db = await instance.database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final Database db = await instance.database;
    return await db.query('users');
  }
}

class User {
  final int id;
  final String username;
  final String password;
  final String userType;
  final String address;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.userType,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'userType': userType,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, password: $password, userType: $userType}';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactoryFfiWeb; // Set databaseFactory

  runApp(const MyApp());
}

class MyDB {
  MyDB._();

  static final MyDB instance = MyDB._();
  Database? db;

  Future<Database> get database async {
    if (db != null) return db!;
    db = await _initDatabase();
    createDB();
    return db!;
  }

  Future<Database> _initDatabase() async {
    return await factory.openDatabase("assets/sample.db");
  }

  Future<List<Map>> rawQuery(sql) async {
    Database db = await instance.database;
    return db.rawQuery(sql);
  }

  void createDB() {
    db?.rawQuery("drop table userinfo"); // DBがゴミで残ることがあるので消去する
    db?.rawQuery("drop table product_info");
    db?.rawQuery("drop table transportation_info");
    db?.rawQuery("drop table reason");
    db?.rawQuery("drop table transport_history");

    db?.rawQuery(
        "create table userinfo ( username varchar(16), password varchar(16),usertype varchar(16) ,address varchar(30))");

    db?.rawQuery(
        "create table product_info ( product_name varchar(16), product_description varchar(50), product_image varchar(16)) ");

    db?.rawQuery(
        "create table transportation_info ( product_name varchar(16), provider_address varchar(100), receiver_address varchar(100)) ");
    db?.rawQuery(
        "insert into transportation_info ( product_name, provider_address, receiver_address) values ( 'ベッド', '福岡県福岡市東区和白東３丁目２９', '福岡県福岡市博多区吉塚本町１３−２８')");
    db?.rawQuery(
        "insert into transportation_info ( product_name, provider_address, receiver_address) values ( 'ノートパソコン', '福岡県福岡市東区和白東３丁目２９', '福岡県福岡市博多区吉塚本町１３−２８')");
    db?.rawQuery(
        "insert into transportation_info ( product_name, provider_address, receiver_address) values ( '腕時計', '福岡県福岡市東区和白東３丁目２９', '福岡県福岡市博多区吉塚本町１３−２８')");

    db?.rawQuery(
        "create table reason ( id INTEGER PRIMARY KEY, product_name varchar(16), reason_info varchar(50))");

    db?.rawQuery("create table transport_history(transport_date datetime)");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'フリー物',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フリー物'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Username',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  final String username = usernameController.text;
                  final String password = passwordController.text;
                  loginUser(context, username, password);
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16.0),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16.0),
              Text('Don\'t have an account?'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser(BuildContext context, String username, String password) async {
// Validate the input fields
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both username and password.';
      });
      return;
    } // Retrieve user from the database based on the provided username and password
    final List<Map<String, dynamic>> users =
        await DatabaseHelper.instance.getUsers();
    final List<User> matchedUsers = users
        .map((user) => User(
            id: user['id'],
            username: user['username'],
            password: user['password'],
            userType: user['userType'],
            address: user['address']))
        .toList();

    final matchingUser = matchedUsers.firstWhere(
      (user) => user.username == username && user.password == password,
      orElse: () => User(
        id: -1,
        username: '',
        password: '',
        userType: '',
        address: '',
      ),
    );

    if (matchingUser != null) {
      if (matchingUser.userType == 'provider') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderPage(username: username),
          ),
        );
      } else if (matchingUser.userType == 'receiver') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiverPage(),
          ),
        );
      } else if (matchingUser.userType == 'transporter') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransporterPage(),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Invalid username or password.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Invalid credentials, show error message
      setState(() {
        errorMessage = 'Invalid username or password.';
      });
    }
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userTypeController = TextEditingController();
  final TextEditingController addressController =
      TextEditingController(); // New controller
  String errorMessage = '';

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    userTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Username',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Address',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 330, // Increase the width to display the hint text fully
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: userTypeController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'User Type (provider/receiver/transporter)',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  final String username = usernameController.text;
                  final String password = passwordController.text;
                  final String userType = userTypeController.text;
                  final String address = addressController.text;
                  registerUser(context, username, password, userType, address);
                },
                child: Text('Sign Up'),
              ),
              SizedBox(height: 16.0),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void registerUser(BuildContext context, String username, String password,
      String userType, String address) async {
// Validate the input fields
    if (username.isEmpty || password.isEmpty || userType.isEmpty) {
      setState(() {
        errorMessage = 'Please enter all the required fields.';
      });
      return;
    }
    // Check if the username is already taken
    final List<Map<String, dynamic>> users =
        await DatabaseHelper.instance.getUsers();
    final List<User> matchedUsers = users
        .map((user) => User(
              id: user['id'],
              username: user['username'],
              password: user['password'],
              userType: user['userType'],
              address: user['address'],
            ))
        .toList();

    final isUsernameTaken =
        matchedUsers.any((user) => user.username == username);
    if (isUsernameTaken) {
      setState(() {
        errorMessage = 'Username is already taken.';
      });
      return;
    }

// Insert the new user into the database with the provided details
    final newUser = User(
      id: users.length + 1,
      // Generate unique ID for each user
      username: username,
      password: password,
      userType: userType,
      address: address,
    );

    await DatabaseHelper.instance.insertUser(newUser.toMap());

// Provide feedback to the user (e.g., show a success message)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('User registration successful!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to the login page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final User user;

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Welcome, ${user.username}!'),
      ),
    );
  }
}

class ProviderPage extends StatefulWidget {
  final String username;

  const ProviderPage({super.key, required this.username});

  @override
  _ProviderPageState createState() => _ProviderPageState();
}

class _ProviderPageState extends State<ProviderPage> {
  List<Product> products = [];

  void uploadProduct(String name, String description, String imageUrl) async {
    // Perform product upload logic
    Database database = await MyDB.instance.database;

    // Insert product into the database
    int productId = await database.insert('product_info', {
      'product_name': name,
      'product_description': description,
      'product_image': imageUrl,
    });

    // Create a new product object with the generated product ID
    Product newProduct = Product(productId, name, description, imageUrl);

    setState(() {
      products.add(newProduct);
    });
  }

  void manageProduct(String name, String reason) {
    // Perform product management logic
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  void getProducts() async {
    Database database = await MyDB.instance.database;

    List<Map<String, dynamic>> results = await database.query('product_info');
    setState(() {
      products = results
          .map((map) => Product(
                map['id'],
                map['product_name'],
                map['product_description'],
                map['product_image'],
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider'),
      ),
      body: Container(
        alignment: Alignment.center, // Center the contents of the container
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Show dialog to upload product
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Upload Product'),
                          content: ProductForm(
                            onSubmit: uploadProduct,
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 100), // Adjust the size here
                  ),
                  child: const Text('Upload Product'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showProductList(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 100), // Adjust the size here
                  ),
                  child: const Text('Manage Products'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(products[index].name),
                    subtitle: Text(products[index].description),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(products[index].imageUrl),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showProductList(BuildContext context) async {
  Database database = await MyDB.instance.database;
  List<Map<String, dynamic>> productList = await database.query('product_info');
  List<Map<String, dynamic>> reasonList = await database.query('reason');

  List<ProductWithReason> productsWithReasons = [];

  for (Map<String, dynamic> product in productList) {
    String productName = product['product_name'];
    String productDescription = product['product_description'];

    List<String> productReasons = [];
    for (Map<String, dynamic> reason in reasonList) {
      if (reason['product_name'] == productName) {
        productReasons.add(reason['reason_info']);
      }
    }

    productsWithReasons.add(ProductWithReason(
      productName: productName,
      productDescription: productDescription,
      productReasons: productReasons,
    ));
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Manage Products'),
        content: Column(
          children: productsWithReasons
              .map(
                (product) => ListTile(
                  title: Text(product.productName),
                  onTap: () {
                    _showProductReasonsDialog(context, product);
                  },
                ),
              )
              .toList(),
        ),
      );
    },
  );
}

void _showProductReasonsDialog(
  BuildContext context,
  ProductWithReason product,
) {
  String? selectedReason;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(product.productName),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: product.productReasons
                  .map(
                    (reason) => RadioListTile<String>(
                      value: reason,
                      groupValue: selectedReason,
                      onChanged: (String? value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                      title: Text(reason),
                    ),
                  )
                  .toList(),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Handle the selected reason as needed
                  if (selectedReason != null) {
                    print('Selected Reason: $selectedReason');
                  }

                  Navigator.of(context).pop();
                },
                child: const Text('Select'),
              ),
            ],
          );
        },
      );
    },
  );
}

class ProductWithReason {
  final String productName;
  final String productDescription;
  final List<String> productReasons;
  String? selectedReason; // Added selectedReason parameter

  ProductWithReason({
    required this.productName,
    required this.productDescription,
    required this.productReasons,
    this.selectedReason, // Updated constructor
  });
}

class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final ImageProvider imageProvider;

  Product(this.id, this.name, this.description, this.imageUrl)
      : imageProvider =
            AssetImage(imageUrl); // Use AssetImage to load from assets
}

class ProductForm extends StatefulWidget {
  final Function(String, String, String) onSubmit;

  const ProductForm({super.key, required this.onSubmit});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '商品名',
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '商品情報',
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: '写真URL',
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              String name = _nameController.text;
              String description = _descriptionController.text;
              String imageUrl = _imageUrlController.text;
              widget.onSubmit(name, description, imageUrl);
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class ReceiverPage extends StatefulWidget {
  const ReceiverPage({super.key});

  @override
  _ReceiverPageState createState() => _ReceiverPageState();
}

class _ReceiverPageState extends State<ReceiverPage> {
  final db = MyDB.instance;
  List<Product1> products = [];

  void getProduct() async {
    List<Map<dynamic, dynamic>> results =
        await db.rawQuery("SELECT * FROM product_info");
    List<Map<String, dynamic>> typedResults =
        results.cast<Map<String, dynamic>>();
    setState(() {
      products = typedResults
          .map((map) => Product1(
                map["product_name"],
                map["product_description"],
                map["product_image"],
              ))
          .toList();
    });
  }

  @override
  void initState() {
    getProduct();
    super.initState();
  }

  void _applyForProduct(BuildContext context, Product1 product) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController reasonController = TextEditingController();
        return AlertDialog(
          title: Text('Apply for ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: '理由',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String reason = reasonController.text;
                await MyDB.instance.db?.rawQuery(
                  "INSERT INTO reason (product_name, reason_info) VALUES (?, ?)",
                  [product.name, reason],
                );

                Navigator.of(context).pop();
              },
              child: const Text('申し込む'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getProduct();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receiver'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          Product1 product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(product.description),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(product.imageUrl),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _applyForProduct(context, product);
              },
              child: const Text('申し込む'),
            ),
          );
        },
      ),
    );
  }
}

class Product1 {
  final String name;
  final String description;
  final String imageUrl;

  Product1(this.name, this.description, this.imageUrl);
}

class TransporterPage extends StatefulWidget {
  const TransporterPage({super.key});

  @override
  _TransporterPageState createState() => _TransporterPageState();
}

class _TransporterPageState extends State<TransporterPage> {
  final db = MyDB.instance;
  List<Transportation> transportations = [];
  int selectedIndex = -1;

  @override
  void initState() {
    getTransportations();
    super.initState();
  }

  void getTransportations() async {
    List<Map<dynamic, dynamic>> results =
        await db.rawQuery("SELECT * FROM transportation_info");
    List<Map<String, dynamic>> typedResults =
        results.cast<Map<String, dynamic>>();
    setState(() {
      transportations = typedResults
          .map((map) => Transportation(
                map["product_name"],
                map["provider_address"],
                map["receiver_address"],
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transporter'),
      ),
      body: ListView.builder(
        itemCount: transportations.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('商品: ${transportations[index].productName}'),
                  const SizedBox(height: 10.0),
                  Text(
                      'Provider 住所: ${transportations[index].providerAddress}'),
                  const SizedBox(height: 10.0),
                  Text(
                      'Receiver 住所: ${transportations[index].receiverAddress}'),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: const Text('受け取る'),
                  ),
                  if (selectedIndex == index)
                    Column(
                      children: [
                        const SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: () {
                            launchMap(transportations[index].providerAddress);
                          },
                          child: const Text('Provider 地図'),
                        ),
                        const SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: () {
                            launchMap(transportations[index].receiverAddress);
                          },
                          child: const Text('Receiver 地図'),
                        ),
                        const SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('宅配終了'),
                                  content: const Text('宅配は終了しましたか'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Perform completion logic
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('はい'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('いいえ'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('終了'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void launchMap(String address) async {
    String mapUrl = 'https://www.google.com/maps/search/?api=1&query=$address';
    if (await canLaunch(mapUrl)) {
      await launch(mapUrl);
    } else {
      throw 'Could not launch map.';
    }
  }
}

class Transportation {
  final String productName;
  final String providerAddress;
  final String receiverAddress;

  Transportation(this.productName, this.providerAddress, this.receiverAddress);
}
