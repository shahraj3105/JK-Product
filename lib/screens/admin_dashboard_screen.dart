import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';

// AdminDashboardScreen (Updated)
class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productImageUrlController = TextEditingController();
  bool _isLoading = false;

  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  int _pendingOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();

    int totalOrders = 0;
    double totalRevenue = 0.0;
    int pendingOrders = 0;

    for (var doc in ordersSnapshot.docs) {
      totalOrders++;
      if (doc['status'] == 'pending') {
        pendingOrders++;
      }
      totalRevenue += (doc['totalAmount'] ?? 0.0);
    }

    setState(() {
      _totalOrders = totalOrders;
      _totalRevenue = totalRevenue;
      _pendingOrders = pendingOrders;
    });
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Product'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter product name' : null,
                ),
                TextFormField(
                  controller: _productPriceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter price' : null,
                ),
                TextFormField(
                  controller: _productDescriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter description' : null,
                ),
                TextFormField(
                  controller: _productImageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    helperText: 'Paste any image URL from Google',
                    helperMaxLines: 2,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter image URL' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addProduct,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Add'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _productService.addProduct({
          'name': _productNameController.text,
          'price': double.parse(_productPriceController.text),
          'description': _productDescriptionController.text,
          'imageUrl': _productImageUrlController.text,
          'createdAt': DateTime.now(),
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully')),
        );
        _productNameController.clear();
        _productPriceController.clear();
        _productDescriptionController.clear();
        _productImageUrlController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDE7),
              Color(0xFFFFF9C4),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total Orders', _totalOrders.toString(), Icons.shopping_cart, Colors.blue),
                  _buildStatCard('Revenue', '₹${_totalRevenue.toStringAsFixed(2)}', Icons.money, Colors.green),
                  _buildStatCard('Pending', _pendingOrders.toString(), Icons.pending_actions, Colors.orange),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Pending Orders',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('status', isEqualTo: 'pending')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No pending orders',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final order = snapshot.data!.docs[index];
                        final orderData = order.data() as Map<String, dynamic>;
                        final items = orderData['items'] as List<dynamic>;
                        final totalAmount = orderData['totalAmount']?.toStringAsFixed(2) ?? '0.0';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(orderData: orderData),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text('Order ID: ${orderData['orderId']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total: ₹$totalAmount'),
                                  Text('Items: ${items.length}'),
                                  Text('User: ${orderData['userEmail']}'),
                                ],
                              ),
                              trailing: Icon(Icons.pending, color: Colors.orange),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Recent Products',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  data['imageUrl'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.error, color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(data['name'] ?? ''),
                            subtitle: Text('₹${data['price']?.toString() ?? '0.0'}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(doc.id),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.brown,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    _productImageUrlController.dispose();
    super.dispose();
  }
}

// New OrderDetailsScreen
class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  OrderDetailsScreen({required this.orderData});

  @override
  Widget build(BuildContext context) {
    final items = orderData['items'] as List<dynamic>;
    final totalAmount = orderData['totalAmount']?.toStringAsFixed(2) ?? '0.0';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDE7),
              Color(0xFFFFF9C4),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${orderData['orderId']}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Customer: ${orderData['userEmail']}',
                style: TextStyle(fontSize: 16, color: Colors.brown[800]),
              ),
              SizedBox(height: 10),
              Text(
                'Address: ${orderData['userAddress'] ?? 'No address provided'}',
                style: TextStyle(fontSize: 16, color: Colors.brown[800]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20),
              Text(
                'Products',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map<String, dynamic>;
                    final quantity = item['quantity'] ?? 1;
                    final price = item['price']?.toDouble() ?? 0.0;
                    final subtotal = price * quantity;

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['imageUrl'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: Icon(Icons.error, color: Colors.red),
                              );
                            },
                          ),
                        ),
                        title: Text(item['name'] ?? 'No Name'),
                        subtitle: Text(
                          'Qty: $quantity\nPrice: ₹${price.toStringAsFixed(2)}\nSubtotal: ₹${subtotal.toStringAsFixed(2)}',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                    Text(
                      '₹$totalAmount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cart Management Class
class Cart {
  static List<Map<String, dynamic>> cartItems = [];

  static void addToCart(Map<String, dynamic> product) {
    final productCopy = Map<String, dynamic>.from(product);
    productCopy['quantity'] = 1;
    cartItems.add(productCopy);
  }

  static void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  static void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index]['quantity'] = quantity;
    }
  }
}