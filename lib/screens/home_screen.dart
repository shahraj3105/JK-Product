import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'JK Product',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Available Products',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
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

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No products available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(productData: data),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
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
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₹${data['price']?.toString() ?? '0.0'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

// Product Details Screen
class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  ProductDetailsScreen({required this.productData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          productData['name'] ?? 'Product Details',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    productData['imageUrl'] ?? '',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                productData['name'] ?? 'No Name',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Price: ₹${productData['price']?.toString() ?? '0.0'}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Description: ${productData['description'] ?? 'No description available'}',
                style: TextStyle(fontSize: 16, color: Colors.brown[800]),
              ),
              SizedBox(height: 20),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Cart.addToCart(productData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${productData['name']} added to cart'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... (HomeScreen and ProductDetailsScreen remain unchanged as provided)

// Cart Screen with Quantity Selection
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cart',
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
        child: Cart.cartItems.isEmpty
            ? Center(
                child: Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: Cart.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = Cart.cartItems[index];
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
                            title: Text(item['name'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('₹${item['price']?.toString() ?? '0.0'}'),
                                Row(
                                  children: [
                                    Text('Qty: '),
                                    DropdownButton<int>(
                                      value: item['quantity'] ?? 1,
                                      items: List.generate(10, (i) => i + 1)
                                          .map((qty) => DropdownMenuItem(
                                                value: qty,
                                                child: Text(qty.toString()),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          Cart.updateQuantity(index, value!);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Cart.removeFromCart(index);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item['name']} removed from cart'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: Cart.cartItems.isEmpty
                          ? null
                          : () async {
                              try {
                                String orderId = _generateOrderId();
                                double totalAmount = Cart.cartItems.fold(
                                  0.0,
                                  (sum, item) =>
                                      sum +
                                      (item['price']?.toDouble() ?? 0.0) *
                                          (item['quantity'] ?? 1),
                                );

                                String? userEmail = await _authService.getCurrentUserEmail();
                                if (userEmail == null) {
                                  throw 'User not authenticated. Please log in.';
                                }

                                // Fetch user's address from Firestore
                                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_authService.getCurrentUserId()) // Assuming this method exists
                                    .get();
                                String userAddress = userDoc.exists
                                    ? (userDoc['address'] ?? 'No address provided')
                                    : 'No address provided';

                                // Place order in Firestore
                                await FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(orderId)
                                    .set({
                                  'orderId': orderId,
                                  'items': Cart.cartItems.map((item) => {
                                        'name': item['name'],
                                        'price': item['price'],
                                        'quantity': item['quantity'],
                                        'imageUrl': item['imageUrl'],
                                      }).toList(),
                                  'totalAmount': totalAmount,
                                  'status': 'pending',
                                  'createdAt': Timestamp.now(),
                                  'userEmail': userEmail,
                                  'userAddress': userAddress,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Order placed successfully! Order ID: $orderId'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InvoiceScreen(
                                      orderId: orderId,
                                      items: List<Map<String, dynamic>>.from(Cart.cartItems),
                                      totalAmount: totalAmount,
                                    ),
                                  ),
                                );

                                Cart.cartItems.clear();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error placing order: $e'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                      child: Text('Place Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}-${(1000 + (DateTime.now().microsecond % 9000)).toString()}';
  }
}

// Invoice Screen
class InvoiceScreen extends StatelessWidget {
  final String orderId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;

  InvoiceScreen({
    required this.orderId,
    required this.items,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice',
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
                'Order Summary',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Order ID: $orderId',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
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
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proceed to payment (TODO)'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('Proceed to Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
    productCopy['quantity'] = 1; // Default quantity
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