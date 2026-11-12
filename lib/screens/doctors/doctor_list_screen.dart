import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../app/routes.dart';
import '../../models/doctor_filter.dart';
import '../../models/doctor_list_args.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/review_provider.dart';
import '../../services/doctor_matching_service.dart';
import '../../texts/app_texts.dart';
import '../../utils/favorite_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_chip.dart';
import '../../widgets/glass_doctor_card.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_search_field.dart';
import 'doctor_filter_sheet.dart';

/// Searchable, filterable doctor list. When it is opened from the AI result,
/// doctors are ranked by match score.
class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DoctorMatchingService _matching = DoctorMatchingService();

  String _query = '';
  String? _specialtyId;
  DoctorFilter _filter = DoctorFilter.none;
  DoctorSort _sort = DoctorSort.bestMatch;
  Map<String, int> _percents = {};
  bool _argsHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsHandled) return;
    _argsHandled = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _specialtyId = args;
    } else if (args is DoctorListArgs) {
      _specialtyId =
          args.specialtyId ??
          (args.matches.isEmpty ? null : args.matches.first.specialtyId);
      _percents = {for (final m in args.matches) m.specialtyId: m.percent};
    }
  }

  Future<void> _openFilters() async {
    final result = await DoctorFilterSheet.show(
      context,
      filter: _filter,
      sort: _sort,
    );
    if (result == null) return;
    setState(() {
      _filter = result.filter;
      _sort = result.sort;
    });
  }

  void _clearAll() {
    setState(() {
      _searchController.clear();
      _query = '';
      _specialtyId = null;
      _filter = DoctorFilter.none;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();
    final doctors = context.watch<DoctorProvider>();
    final reviews = context.watch<ReviewProvider>();

    final list = _matching.apply(
      doctors: doctors.doctors,
      query: _query,
      specialtyId: _specialtyId,
      filter: _filter,
      sort: _sort,
      specialtyPercents: _percents,
      ratingOf: reviews.ratingOf,
      specialtyNameOf: doctors.specialtyName,
    );

    // Matched specialties first, the rest in their normal order.
    final specialties = [...doctors.specialties];
    final order = {
      for (var i = 0; i < specialties.length; i++) specialties[i].id: i,
    };
    specialties.sort((a, b) {
      final byMatch = (_percents[b.id] ?? 0).compareTo(_percents[a.id] ?? 0);
      return byMatch != 0 ? byMatch : order[a.id]!.compareTo(order[b.id]!);
    });

    return GlassScaffold(
      title: t('doctors_title'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GlassSearchField(
                    controller: _searchController,
                    hint: t('search_doctors_hint'),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                const SizedBox(width: 10),
                GlassIconButton(
                  icon: Icons.tune_rounded,
                  showBadge: _filter.isActive,
                  onTap: _openFilters,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: specialties.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GlassChip(
                    label: t('all'),
                    selected: _specialtyId == null,
                    onTap: () => setState(() => _specialtyId = null),
                  );
                }
                final specialty = specialties[index - 1];
                return GlassChip(
                  label: specialty.name,
                  selected: _specialtyId == specialty.id,
                  onTap: () => setState(() => _specialtyId = specialty.id),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${list.length} ${t('doctors_found')}',
                    style: const TextStyle(color: AppColors.onGlassMuted),
                  ),
                ),
                Text(
                  '${t('sort_by')}: ${_sort.label}',
                  style: const TextStyle(
                    color: AppColors.onGlassMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildList(context, doctors, reviews, list)),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    DoctorProvider doctors,
    ReviewProvider reviews,
    List<DoctorModel> list,
  ) {
    if (doctors.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.onGlass),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.onGlassMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  t('no_doctors'),
                  style: const TextStyle(
                    color: AppColors.onGlass,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onGlass,
                  ),
                  child: Text(t('clear_filters')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doctor = list[index];
        return GlassDoctorCard(
          doctor: doctor,
          specialtyName: doctors.specialtyName(doctor.specialtyId),
          rating: reviews.ratingOf(doctor),
          reviewCount: reviews.countOf(doctor),
          isFavorite: doctors.isFavorite(doctor.id),
          matchPercent: _percents.isEmpty
              ? null
              : _percents[doctor.specialtyId],
          onTap: () =>
              Navigator.of(context)
                  .pushNamed(AppRoutes.doctorDetails, arguments: doctor.id),
          onFavoriteTap: () =>
              toggleFavoriteWithMessage(context, doctors, doctor.id),
        );
      },
    );
  }
}
