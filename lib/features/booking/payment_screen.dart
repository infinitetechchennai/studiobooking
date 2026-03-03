import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/models/booking.dart';
import '../../core/models/discover_event.dart';
import '../../core/models/transaction_model.dart';
import '../../core/providers/bookings_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_colors.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'card';
  late Razorpay _razorpay;
  double? _pendingTotal;
  String? _pendingClientType;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _processBooking(
      _pendingAmount!,
      _pendingTotal!,
      _pendingClientType!,
      _pendingEvent!,
      _pendingDate!,
      _pendingTimeSlot!,
      _pendingDuration!,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  double? _pendingAmount;
  DiscoverEvent? _pendingEvent;
  DateTime? _pendingDate;
  String? _pendingTimeSlot;
  int? _pendingDuration;

  void _startPayment(
    double advance,
    double total,
    String clientType,
    DiscoverEvent? event,
    DateTime date,
    String timeSlot,
    int duration,
  ) {
    _pendingAmount = advance;
    _pendingTotal = total;
    _pendingClientType = clientType;
    _pendingEvent = event;
    _pendingDate = date;
    _pendingTimeSlot = timeSlot;
    _pendingDuration = duration;

    var options = {
      'key': 'rzp_test_SCRZe0CQMiLsrE',
      'amount': (advance * 100).toInt(),
      'name': 'Eventra Booking',
      'description': event?.title ?? 'Event Booking',
    };

    _razorpay.open(options);
  }

  Future<void> _processBooking(
    double advancePaid,
    double totalAmount,
    String clientType,
    DiscoverEvent? event,
    DateTime date,
    String timeSlot,
    int duration,
  ) async {
    final currentUser = ref.read(sessionProvider).user;
    if (currentUser == null || event == null) return;

    // 🔹 Generate Deterministic ID: BID-{listingId}-{yyyyMMdd}-{TimeSlot}
    // Remove spaces and special chars from timeSlot for cleaner ID
    final cleanTimeSlot = timeSlot.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final dateStr =
        "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    final bookingId = 'BID-${event.id}-$dateStr-$cleanTimeSlot';

    final booking = Booking(
      id: bookingId,
      clientId: currentUser.id,
      creatorId: event.ownerId,
      event: event,
      date: date,
      timeSlot: timeSlot.isEmpty ? '04:00 PM' : timeSlot,
      totalAmount: totalAmount,
      advancePaid: advancePaid,
      remainingAmount: totalAmount - advancePaid,
      clientType: clientType,
      duration: duration,
      listingId: event.id, // ✅ Correctly passing listingId
    );

    try {
      await ref.read(bookingsProvider.notifier).addBooking(booking);

      // ✅ Log Transaction only if booking succeeds
      final transaction = TransactionModel(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        advancePaid: advancePaid,
        totalAmount: totalAmount,
        remainingAmount: totalAmount - advancePaid,
        status: 'Success',
        clientId: currentUser.id,
        userEmail: currentUser.email,
        vendorId: event.ownerId ?? '',
        createdAt: DateTime.now(),
        type: 'Booking',
        paymentGateway: 'Razorpay',
        bookingId: booking.id,
      );

      ref.read(firebaseServiceProvider).saveTransaction(transaction);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Booking Confirmed!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('You have successfully booked your slot.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey2)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                  arguments: {'index': 2},
                );
              },
              child: const Text('GO TO MY BOOKINGS'),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Show Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booking Failed: ${e.toString().replaceAll("Exception:", "")}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments (Booking details)
    final args = ModalRoute.of(context)?.settings.arguments;

    DiscoverEvent? event;
    DateTime date = DateTime.now();
    String timeSlot = '';
    int duration = 1;
    double amount = 0.0;

    double total = 0.0;
    double advance = 0.0;
    String clientType = 'individual';

    if (args is Map<String, dynamic>) {
      event = args['event'] as DiscoverEvent?;
      date = args['date'] as DateTime? ?? DateTime.now();
      timeSlot = args['timeSlot'] as String? ?? '';
      duration = args['duration'] as int? ?? 1;

      total = args['total'] as double? ?? 0.0;
      advance = args['advance'] as double? ?? 0.0;
      clientType = args['clientType'] as String? ?? 'individual';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 16),
                  _buildPaymentOption(
                    id: 'card',
                    title: 'Credit / Debit Card',
                    icon: Icons.credit_card,
                    subtitle: 'Visa, Mastercard, Amex',
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    id: 'upi',
                    title: 'UPI / Net Banking',
                    icon: Icons.account_balance_wallet,
                    subtitle: 'Google Pay, PhonePe, Paytm',
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    id: 'cash',
                    title: 'Pay at Venue',
                    icon: Icons.money,
                    subtitle: 'Pay directly to the host',
                  ),
                  const SizedBox(height: 32),
                  _buildSummary(total, advance),
                ],
              ),
            ),
          ),
          _buildPayButton(
            total,
            advance,
            clientType,
            event,
            date,
            timeSlot,
            duration,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required IconData icon,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey3,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.grey3.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.grey2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey2,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary)
            else
              const Icon(Icons.circle_outlined, color: AppColors.grey3),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(double total, double advance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _summaryRow("Total Amount", total),
          const SizedBox(height: 8),
          _summaryRow("Advance Paying Now", advance),
          const Divider(height: 24),
          _summaryRow("Remaining After Payment", total - advance),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.grey1)),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildPayButton(
    double total,
    double advance,
    String clientType,
    DiscoverEvent? event,
    DateTime date,
    String timeSlot,
    int duration,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _startPayment(
            advance,
            total,
            clientType,
            event,
            date,
            timeSlot,
            duration,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PAY NOW',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
