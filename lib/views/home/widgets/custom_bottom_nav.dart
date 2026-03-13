import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'extra_menu_sheet.dart';
import 'budget_list_sheet.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  void _showExtraMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ExtraMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const WavyBottomAppBarShape(),
      clipBehavior: Clip.antiAlias,
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      color: AppColors.sagePrimary, // Warna ombak sage
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 80, // Diperbesar untuk menampung gelombang
        child: Padding(
          padding: const EdgeInsets.only(top: 24), // Hapus padding horizontal rekat layar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Buat jarak simetris antar elemen
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Kiri: Tombol Budget (Diganjal dengan Expanded agar posisinya mantap di tengah bukit kiri)
              Expanded(
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => const BudgetListSheet(),
                      );
                    },
                  ),
                ),
              ),
              // Ruang kosong untuk memberi sekat seukuran FAB
              const SizedBox(width: 80), 
              // Kanan: Tombol Menu Ekstra (Diganjal dengan Expanded di tengah bukit kanan)
              Expanded(
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
                    onPressed: () => _showExtraMenu(context),
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

class WavyBottomAppBarShape extends NotchedShape {
  const WavyBottomAppBarShape();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final double notchRadius = guest.width / 2.0;
    const double notchMargin = 12.0;
    const double waveHeight = 25.0; // Ketinggian bukit
    
    Path path = Path();
    
    // Mulai agak ke bawah (waveHeight)
    path.moveTo(host.left, host.top + waveHeight);
    
    // Kurva ke atas (bukit kiri), lalu turun sebelum notch
    path.quadraticBezierTo(
      host.width * 0.25, host.top - 15, // Puncak bukit kiri
      host.width * 0.5 - notchRadius - notchMargin, host.top + waveHeight, // Dasar sebelum notch
    );

    // Notch melengkung dalam
    path.quadraticBezierTo(
      host.width * 0.5, host.top + waveHeight + notchRadius * 1.5, // Titik terdalam notch
      host.width * 0.5 + notchRadius + notchMargin, host.top + waveHeight, // Naik dari notch
    );

    // Kurva dari dasar notch ke bukit kanan lalu ke tepi kanan
    path.quadraticBezierTo(
      host.width * 0.75, host.top - 15, // Puncak bukit kanan
      host.right, host.top + waveHeight, // Tepi kanan
    );

    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}
