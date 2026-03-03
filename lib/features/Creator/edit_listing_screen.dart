import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/Creator_listing.dart';
import '../../core/providers/Creator_listings_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';

class EditReelsCreatorScreen extends ConsumerStatefulWidget {
  final CreatorListing? existing;
  const EditReelsCreatorScreen({super.key, this.existing});

  @override
  ConsumerState<EditReelsCreatorScreen> createState() =>
      _EditReelsCreatorScreenState();
}

class _EditReelsCreatorScreenState
    extends ConsumerState<EditReelsCreatorScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _nicheCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _priceCtrl;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    _nameCtrl = TextEditingController(text: e?.title ?? '');
    _bioCtrl = TextEditingController(text: e?.description ?? '');
    _nicheCtrl = TextEditingController(text: e?.locationText ?? '');
    _instagramCtrl = TextEditingController();
    _priceCtrl = TextEditingController(
        text: (e?.pricePerHour ?? 2000.0).toStringAsFixed(0));

    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _nicheCtrl.dispose();
    _instagramCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null
              ? 'Create Reels Profile'
              : 'Edit Reels Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: session.user == null
          ? const Center(child: Text('Please sign in first.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Creator Name / Brand'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Rahul Edits / Priya Lifestyle',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Bio / About You'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Tell brands about your content style, audience, and strengths...',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Content Niche'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nicheCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Fashion, Tech, Food, Travel',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Instagram Handle'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instagramCtrl,
                    decoration: const InputDecoration(
                      hintText: '@yourusername',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Price per Reel (₹)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Ex: 3000',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        thumbColor:
                            const WidgetStatePropertyAll(AppColors.primary),
                        trackColor: WidgetStatePropertyAll(
                          AppColors.primary.withAlpha(128),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isActive ? 'Active (Visible to Brands)' : 'Inactive',
                        style: const TextStyle(color: AppColors.grey2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = _nameCtrl.text.trim();
                        final bio = _bioCtrl.text.trim();
                        final niche = _nicheCtrl.text.trim();
                        final price =
                            double.tryParse(_priceCtrl.text.trim()) ?? 2000.0;

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your creator name.'),
                            ),
                          );
                          return;
                        }

                        final listing = CreatorListing(
                          id: widget.existing?.id ??
                              'reels_${DateTime.now().millisecondsSinceEpoch}',
                          ownerUserId: session.user!.id,
                          type: 'reels_creator',
                          title: name,
                          description: bio,
                          locationText: niche, // reused field
                          latitude: null,
                          longitude: null,
                          pricePerHour: price, // reused as price per reel
                          images: widget.existing?.images ?? const [],
                          instagram:
                              _instagramCtrl.text.trim(), // <-- SAVE HERE
                          isActive: _isActive,
                          createdAt:
                              widget.existing?.createdAt ?? DateTime.now(),
                        );

                        await ref
                            .read(CreatorListingsProvider.notifier)
                            .upsert(listing);

                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.existing == null ? 'CREATE' : 'SAVE'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.grey2,
      ),
    );
  }
}
