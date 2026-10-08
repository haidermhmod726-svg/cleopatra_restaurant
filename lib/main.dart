import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const CleopatraRestaurantApp());
}

class MenuItem {
  final int id;
  final String name;
  final double price;

  MenuItem({required this.id, required this.name, required this.price});
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get total => item.price * quantity;
}

class CleopatraRestaurantApp extends StatefulWidget {
  const CleopatraRestaurantApp({super.key});

  @override
  State<CleopatraRestaurantApp> createState() => _CleopatraRestaurantAppState();
}

class _CleopatraRestaurantAppState extends State<CleopatraRestaurantApp> {
  final List<MenuItem> menu = [
    MenuItem(id: 1, name: 'فتة كليوباترا', price: 7.50),
    MenuItem(id: 2, name: 'شاورما لحم', price: 5.00),
    MenuItem(id: 3, name: 'شاورما دجاج', price: 4.50),
    MenuItem(id: 4, name: 'أرز بالشعيرية', price: 2.00),
    MenuItem(id: 5, name: 'مشروب غازي', price: 1.25),
    MenuItem(id: 6, name: 'سلطة', price: 1.75),
  ];

  final Map<int, CartItem> cart = {};

  void addToCart(MenuItem item) {
    setState(() {
      if (cart.containsKey(item.id)) {
        cart[item.id]!.quantity += 1;
      } else {
        cart[item.id] = CartItem(item: item);
      }
    });
  }

  void removeFromCart(int id) {
    setState(() {
      cart.remove(id);
    });
  }

  void changeQuantity(int id, int delta) {
    setState(() {
      final current = cart[id];
      if (current == null) return;
      current.quantity += delta;
      if (current.quantity <= 0) {
        cart.remove(id);
      }
    });
  }

  int get totalItems => cart.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => cart.values.fold(0.0, (sum, item) => sum + item.total);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleopatra Restaurant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('مطعم كليوباترا'),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(
                          cart: cart,
                          changeQuantity: changeQuantity,
                          removeFromCart: removeFromCart,
                          totalPrice: totalPrice,
                        ),
                      ),
                    );
                  },
                ),
                if (totalItems > 0)
                  Positioned(
                    right: 7,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$totalItems',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: menu.length,
          itemBuilder: (context, index) {
            final item = menu[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('السعر: \$${item.price.toStringAsFixed(2)}'),
                trailing: ElevatedButton(
                  onPressed: () => addToCart(item),
                  child: const Text('أضف إلى السلة'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Map<int, CartItem> cart;
  final void Function(int id, int delta) changeQuantity;
  final void Function(int id) removeFromCart;
  final double totalPrice;

  const CartPage({
    super.key,
    required this.cart,
    required this.changeQuantity,
    required this.removeFromCart,
    required this.totalPrice,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    final items = widget.cart.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة الطلب'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ملاحظات / عنوان التوصيل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('السلة فارغة'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final cartItem = items[index];
                        return Card(
                          child: ListTile(
                            title: Text(cartItem.item.name),
                            subtitle: Text(
                              'السعر: \$${cartItem.item.price.toStringAsFixed(2)} × ${cartItem.quantity} = \$${cartItem.total.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => widget.changeQuantity(cartItem.item.id, -1),
                                ),
                                Text('${cartItem.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => widget.changeQuantity(cartItem.item.id, 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموع: \$${widget.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: items.isEmpty || isSending ? null : _sendOrderViaWhatsApp,
                  icon: const Icon(Icons.send),
                  label: const Text('إرسال الطلب'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOrderViaWhatsApp() async {
    setState(() => isSending = true);

    final phoneNumber = '963932526170';
    final orderText = _buildOrderMessage();
    final encodedText = Uri.encodeComponent(orderText);
    final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber?text=$encodedText');

    try {
      final launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('تعذر فتح واتساب');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم فتح واتساب لإرسال الطلب')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  String _buildOrderMessage() {
    final buffer = StringBuffer();
    buffer.writeln('طلب جديد من مطعم كليوباترا');
    buffer.writeln('');

    final customerName = nameController.text.trim();
    if (customerName.isNotEmpty) {
      buffer.writeln('الاسم: $customerName');
    }

    final notes = notesController.text.trim();
    if (notes.isNotEmpty) {
      buffer.writeln('ملاحظات: $notes');
    }

    buffer.writeln('');
    buffer.writeln('المنتجات:');

    for (final cartItem in widget.cart.values) {
      buffer.writeln('- ${cartItem.item.name} x${cartItem.quantity} = \$${cartItem.total.toStringAsFixed(2)}');
    }

    buffer.writeln('');
    buffer.writeln('المجموع الكلي: \$${widget.totalPrice.toStringAsFixed(2)}');
    return buffer.toString();
  }
}
