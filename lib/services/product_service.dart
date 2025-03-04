import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _productsCollection.add(productData);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  Stream<QuerySnapshot> getProducts() {
    return _productsCollection.orderBy('createdAt', descending: true).snapshots();
  }
} 