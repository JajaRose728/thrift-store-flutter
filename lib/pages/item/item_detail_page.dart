// lib/pages/item_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';
import '../../models/item.dart';
import '../../widgets/info_chip.dart';
import 'full_screen_image_page.dart';

// --- Define the new color palette for easy reference ---
// Beige: Color(0xFFFAD9C1) - End of gradient
const Color beigeAccent = Color(0xFFFAD9C1);
// Pink: Color(0xFFFF8FAB) - Start of gradient
const Color softPink = Color(0xFFFF8FAB);
// NEW: Slightly darker pink for the button
const Color darkerPink = Color(0xFFE0778C);
// A darker, muted pink for labels/icons on light backgrounds
const Color mutedPink = Color(0xFFE57A8B);
// A dark color for text on white surfaces (like the description box)
const Color darkText = Colors.black87;
// White for text on the dark gradient
const Color whiteText = Colors.white;

class ItemDetailPage extends StatelessWidget {
  final int itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<SupabaseService>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              softPink,    // Pink starts at top-left
              beigeAccent, // Beige ends at bottom-right
            ],
            stops: [0.2, 0.8],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Item?>(
            future: svc.fetchItemDetail(itemId),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: whiteText),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snap.error}',
                    style: GoogleFonts.montserrat(color: Colors.redAccent),
                  ),
                );
              }
              final item = snap.data;
              if (item == null) {
                return Center(
                  child: Text(
                    'Item not found 🤷',
                    style: GoogleFonts.montserrat(color: whiteText),
                  ),
                );
              }

              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    children: [
                      // Back + title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child:
                            const Icon(Icons.arrow_back_ios, color: whiteText),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Details',
                            style: GoogleFonts.pacifico(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: whiteText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tappable image with Hero
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FullScreenImagePage(itemId: item.id, imageUrl: item.imageUrl),
                          ),
                        ),
                        child: Hero(
                          tag: 'item-image-${item.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              item.imageUrl,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title & price
                      Text(
                        item.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: whiteText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₱ ${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: beigeAccent,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description Box
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: mutedPink,
                              ),
                            ),
                            const Divider(color: beigeAccent, height: 16),
                            Text(
                              item.description,
                              style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  color: darkText
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info chips
                      SizedBox(
                        height: 40,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              InfoChip(icon: Icons.person, text: item.uploadedBy),
                              const SizedBox(width: 12),
                              InfoChip(icon: Icons.contact_mail, text: item.contactInfo),
                              const SizedBox(width: 12),
                              InfoChip(
                                icon: Icons.calendar_today,
                                text: '${item.createdAt.month}/${item.createdAt.day}/${item.createdAt.year}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Contact Owner button
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // KEY CHANGE: Use the darkerPink color here
                        backgroundColor: darkerPink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        final contact = snap.data!.contactInfo.trim();
                        final subject =
                        Uri.encodeComponent('Inquiry about "${item.title}"');
                        final uri = Uri.parse('mailto:$contact?subject=$subject');

                        // Check if the contact is an email (simplified check)
                        if (contact.contains('@')) {
                          try {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } catch (_) {
                            // Fallback to dialog if mail app fails
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Contact Owner (Email)',
                                    style: GoogleFonts.montserrat(color: mutedPink)),
                                content: SelectableText(contact,
                                    style: GoogleFonts.montserrat()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close',
                                        style: GoogleFonts.montserrat(color: darkerPink)),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          // If it looks like a phone number, attempt to call or show dialog
                          final phoneUri = Uri.parse('tel:$contact');
                          try {
                            await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
                          } catch (_) {
                            // Fallback to dialog if calling fails
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Contact Owner (Phone)',
                                    style: GoogleFonts.montserrat(color: mutedPink)),
                                content: SelectableText(contact,
                                    style: GoogleFonts.montserrat()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close',
                                        style: GoogleFonts.montserrat(color: darkerPink)),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Contact Owner',
                        style: GoogleFonts.pacifico(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: whiteText,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}