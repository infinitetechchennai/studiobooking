import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/discover_event.dart';
import '../../core/providers/bookings_provider.dart';
import '../../core/theme/app_colors.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  ConsumerState<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '';
  String _clientType = 'individual'; // or 'corporate'
  int _selectedDuration = 1;
  String _bookingType = 'studio';
  // 'studio' = rate bucket
// 'rental' = shop bucket
  DiscoverEvent? _event;
  bool _isChecking = false;

  final List<String> _morningSlots = ['09:00 AM', '10:00 AM', '11:00 AM'];
  final List<String> _afternoonSlots = [
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM'
  ];
  final List<String> _eveningSlots = ['05:00 PM', '06:00 PM', '07:00 PM'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve event pass arguments if available
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DiscoverEvent) {
      _event = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default price if not passed (fallback logic)
    double hourlyRate = 50.0;

    if (_event != null) {
      // If vendor (not nearby event)
      if (_event!.isCreator == false) {
        if (_bookingType == 'studio') {
          hourlyRate = _event!.studioPrice ?? 0.0;
        } else {
          hourlyRate = _event!.rentalPrice ?? 0.0;
        }
      } else {
        // Nearby event / creator service
        hourlyRate = _event!.pricePerHour;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Slot',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 16),
                  _buildDateSelector(),
                  const SizedBox(height: 32),
                  // Only for Vendors
                  if (_event != null &&
                      _event!.isCreator == false &&
                      (_event!.studioPrice != null ||
                          _event!.rentalPrice != null)) ...[
                    _buildSectionTitle('Booking Type'),
                    const SizedBox(height: 16),
                    _buildBookingTypeSelector(),
                    const SizedBox(height: 32),
                  ],
                  _buildSectionTitle('Select Duration'),
                  const SizedBox(height: 16),
                  _buildDurationSelector(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Available Slots'),
                  const SizedBox(height: 16),
                  _buildTimeSlots('Morning', _morningSlots),
                  const SizedBox(height: 16),
                  _buildTimeSlots('Afternoon', _afternoonSlots),
                  const SizedBox(height: 16),
                  _buildTimeSlots('Evening', _eveningSlots),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Client Type'),
                  const SizedBox(height: 16),
                  _buildClientTypeSelector(),
                  const SizedBox(height: 32),
                  _buildPriceBreakdown(hourlyRate),
                ],
              ),
            ),
          ),
          _buildBottomBar(hourlyRate),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.grey1,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBookingTypeSelector() {
    return Row(
      children: [
        if (_event?.studioPrice != null)
          ChoiceChip(
            label: const Text('Studio'),
            selected: _bookingType == 'studio',
            onSelected: (_) => setState(() => _bookingType = 'studio'),
          ),
        const SizedBox(width: 12),
        if (_event?.rentalPrice != null)
          ChoiceChip(
            label: const Text('Rental'),
            selected: _bookingType == 'rental',
            onSelected: (_) => setState(() => _bookingType = 'rental'),
          ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getMonth(date.month),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.grey2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Row(
      children: [1, 2, 3, 4, 8].map((hours) {
        final isSelected = _selectedDuration == hours;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selectedDuration = hours),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey3,
                ),
              ),
              child: Text(
                '${hours}h',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.grey3,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlots(String label, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.grey2, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((time) {
            final isSelected = _selectedTimeSlot == time;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = time),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey3,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClientTypeSelector() {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Individual (25%)'),
          selected: _clientType == 'individual',
          onSelected: (_) => setState(() => _clientType = 'individual'),
        ),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('Corporate (15%)'),
          selected: _clientType == 'corporate',
          onSelected: (_) => setState(() => _clientType = 'corporate'),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(double hourlyRate) {
    final subtotal = hourlyRate * _selectedDuration;
    final serviceFee = subtotal * 0.10;
    final total = subtotal + serviceFee;

    final gstPercent = _clientType == 'individual' ? 0.25 : 0.15;
    final advance = total * gstPercent;
    final remaining = total - advance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Rate', '\$$hourlyRate / hr'),
          const SizedBox(height: 8),
          _buildPriceRow('Duration', '$_selectedDuration hours'),
          const Divider(),
          _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildPriceRow(
              'Service Fee (10%)', '\$${serviceFee.toStringAsFixed(2)}'),
          const Divider(),
          _buildPriceRow('Total Amount', '\$${total.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Advance (${(gstPercent * 100).toInt()}%)',
            '\$${advance.toStringAsFixed(2)}',
          ),
          _buildPriceRow(
            'Pay at Venue',
            '\$${remaining.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey1)),
        Text(value,
            style: const TextStyle(
                color: AppColors.grey1, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomBar(double hourlyRate) {
    final subtotal = hourlyRate * _selectedDuration;
    final total = subtotal * 1.10;

    final gstPercent = _clientType == 'individual' ? 0.25 : 0.15;
    final advance = total * gstPercent;
    // Including service fee

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'Total Price',
                  style: TextStyle(color: AppColors.grey2, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (_event?.isCreator == true
                      ? _isChecking
                      : _selectedTimeSlot.isEmpty || _isChecking)
                  ? null
                  : () async {
                      setState(() => _isChecking = true);
                      try {
                        final isAvailable = await ref
                            .read(bookingsProvider.notifier)
                            .checkAvailability(
                                _event!.id, _selectedDate, _selectedTimeSlot);

                        if (!mounted) return;

                        if (isAvailable) {
                          Navigator.of(context)
                              .pushNamed('/payment', arguments: {
                            'event': _event,
                            'date': _selectedDate,
                            'timeSlot': _selectedTimeSlot,
                            'duration': _selectedDuration,
                            'total': total,
                            'advance': advance,
                            'clientType': _clientType,
                          });
                        } else {
                          // Reconstruct ID for debug purposes
                          final cleanTimeSlot = _selectedTimeSlot.replaceAll(
                              RegExp(r'[^a-zA-Z0-9]'), '');
                          final dateStr =
                              "${_selectedDate.year}${_selectedDate.month.toString().padLeft(2, '0')}${_selectedDate.day.toString().padLeft(2, '0')}";
                          final debugId =
                              'BID-${_event!.id}-$dateStr-$cleanTimeSlot';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'This slot is already booked. (ID: $debugId)'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error checking availability: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _isChecking = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.grey3,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isChecking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'CONFIRM BOOKING',
                      style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
