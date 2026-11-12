import 'package:flutter/material.dart';

import '../../app/color.dart';
import '../../app/constants.dart';
import '../../models/doctor_filter.dart';
import '../../texts/app_texts.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_chip.dart';
import '../../widgets/glass_sheet.dart';

/// What the user chose in the filter sheet.
class FilterSheetResult {
  const FilterSheetResult(this.filter, this.sort);

  final DoctorFilter filter;
  final DoctorSort sort;
}

/// Bottom sheet with sort and filter options.
class DoctorFilterSheet extends StatefulWidget {
  const DoctorFilterSheet({
    super.key,
    required this.filter,
    required this.sort,
  });

  final DoctorFilter filter;
  final DoctorSort sort;

  static Future<FilterSheetResult?> show(
    BuildContext context, {
    required DoctorFilter filter,
    required DoctorSort sort,
  }) {
    return GlassSheet.show<FilterSheetResult>(
      context,
      builder: (_) => DoctorFilterSheet(filter: filter, sort: sort),
    );
  }

  @override
  State<DoctorFilterSheet> createState() => _DoctorFilterSheetState();
}

class _DoctorFilterSheetState extends State<DoctorFilterSheet> {
  static const List<double> _ratingOptions = [0, 4.0, 4.5];
  static const List<int> _feeOptions = [500, 800, 1000];

  late DoctorFilter _filter = widget.filter;
  late DoctorSort _sort = widget.sort;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('filters'),
          style: const TextStyle(
            color: AppColors.onGlass,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _Label(t('sort_by')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in DoctorSort.values)
              GlassChip(
                label: option.label,
                selected: _sort == option,
                onTap: () => setState(() => _sort = option),
              ),
          ],
        ),
        const SizedBox(height: 18),
        GlassChip(
          label: t('filter_available_today'),
          icon: _filter.availableToday
              ? Icons.check_circle_rounded
              : Icons.circle_outlined,
          selected: _filter.availableToday,
          onTap: () => setState(() {
            _filter = _filter.copyWith(availableToday: !_filter.availableToday);
          }),
        ),
        const SizedBox(height: 18),
        _Label(t('filter_gender')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            GlassChip(
              label: t('gender_any'),
              selected: _filter.gender == null,
              onTap: () =>
                  setState(() => _filter = _filter.copyWith(gender: null)),
            ),
            GlassChip(
              label: t('gender_male'),
              selected: _filter.gender == 'male',
              onTap: () =>
                  setState(() => _filter = _filter.copyWith(gender: 'male')),
            ),
            GlassChip(
              label: t('gender_female'),
              selected: _filter.gender == 'female',
              onTap: () =>
                  setState(() => _filter = _filter.copyWith(gender: 'female')),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _Label(t('filter_rating')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in _ratingOptions)
              GlassChip(
                label: value == 0
                    ? t('rating_any')
                    : '${value.toStringAsFixed(1)}+',
                icon: value == 0 ? null : Icons.star_rounded,
                selected: _filter.minRating == value,
                onTap: () => setState(
                  () => _filter = _filter.copyWith(minRating: value),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _Label(t('filter_fee')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            GlassChip(
              label: t('fee_any'),
              selected: _filter.maxFee == null,
              onTap: () =>
                  setState(() => _filter = _filter.copyWith(maxFee: null)),
            ),
            for (final fee in _feeOptions)
              GlassChip(
                label: '${AppConstants.currencySymbol}$fee',
                selected: _filter.maxFee == fee,
                onTap: () =>
                    setState(() => _filter = _filter.copyWith(maxFee: fee)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() {
                _filter = DoctorFilter.none;
                _sort = DoctorSort.bestMatch;
              }),
              style: TextButton.styleFrom(foregroundColor: AppColors.onGlass),
              child: Text(t('reset')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                label: t('apply'),
                onPressed: () =>
                    Navigator.of(context)
                        .pop(FilterSheetResult(_filter, _sort)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onGlassMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
