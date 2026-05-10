import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Commitment ritual: user signs to "commit" before continuing.
class SignatureStep extends StatefulWidget {
  final VoidCallback onContinue;

  const SignatureStep({super.key, required this.onContinue});

  @override
  State<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends State<SignatureStep> {
  late final SignatureController _controller;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
    );
    _controller.addListener(() {
      final has = _controller.isNotEmpty;
      if (has != _hasSignature) {
        setState(() => _hasSignature = has);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            l10n.onboardingSignatureTitle,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.onboardingSignatureBody,
            style:
                TextStyle(fontSize: 16.sp, color: c.textSecondary, height: 1.5),
          ),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: c.separator),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Signature(
                controller: _controller,
                height: 220.h,
                backgroundColor: c.card,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: withHaptic(() => _controller.clear()),
              child: Text(
                l10n.onboardingSignatureClear,
                style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _hasSignature ? withHaptic(widget.onContinue) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: c.textSecondary.withAlpha(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(l10n.onboardingSignatureCommit,
                  style: TextStyle(fontSize: 16.sp)),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
