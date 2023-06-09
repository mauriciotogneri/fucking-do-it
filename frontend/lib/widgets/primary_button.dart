import 'package:dafluta/dafluta.dart';
import 'package:flutter/material.dart';
import 'package:fucking_do_it/utils/palette.dart';
import 'package:fucking_do_it/widgets/label.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onSubmit;
  final Color color;
  final IconData icon;

  const PrimaryButton({
    required this.text,
    required this.onSubmit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Palette.unselected,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          shape: const StadiumBorder(),
        ),
        onPressed: onSubmit,
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(
                  icon,
                  size: 20,
                  color: (onSubmit != null)
                      ? Palette.white
                      : Palette.secondaryText,
                ),
              ),
              const HBox(5),
              Label(
                text: text.toUpperCase(),
                color:
                    (onSubmit != null) ? Palette.white : Palette.secondaryText,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
