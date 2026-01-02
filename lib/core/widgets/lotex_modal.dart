import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/lotex_ui_tokens.dart';

Future<T?> showLotexModal<T>({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierColor: LotexUiColors.slate950.withAlpha((0.80 * 255).round()),
    builder: (context) {
      final width = MediaQuery.sizeOf(context).width;
      final maxW = width >= 420 ? 420.0 : width - 32;

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW, maxHeight: MediaQuery.sizeOf(context).height * 0.90),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: LotexUiColors.slate900.withAlpha((0.90 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.50 * 255).round()),
                        blurRadius: 24,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.05 * 255).round()),
                          border: Border(
                            bottom: BorderSide(color: Colors.white.withAlpha((0.05 * 255).round())),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.close, color: LotexUiColors.slate400),
                              splashRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
