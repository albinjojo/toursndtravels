import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/list_providers.dart';
import '../../../providers/school_providers.dart';
import '../../../routing/app_router.dart';
import '../../widgets/lists/list_card.dart';

class ListsHubScreen extends ConsumerWidget {
  const ListsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final school = ref.watch(selectedSchoolProvider);
    if (school == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final listsAsync = ref.watch(savedListsProvider(school.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Lists',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        listsAsync.when(
                          data: (lists) => Text(
                            '${lists.length} list${lists.length == 1 ? '' : 's'} saved',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Create button
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.listCreate, extra: school),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create New List'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // List body
            Expanded(
              child: listsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => _ErrorBody(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(savedListsProvider(school.id)),
                ),
                data: (lists) {
                  if (lists.isEmpty) {
                    return _EmptyBody(
                      onCreateTap: () => context.push(
                        AppRoutes.listCreate,
                        extra: school,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 100),
                    itemCount: lists.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return ListCard(
                        list: list,
                        onTap: () => context.push(
                          '/lists/${list.id}',
                          extra: list,
                        ),
                        onDelete: () async {
                          await ref
                              .read(listRepositoryProvider)
                              .deleteList(school.id, list.id);
                          ref.invalidate(savedListsProvider(school.id));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list_alt_rounded,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'No lists yet',
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create First List'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(message,
                style: GoogleFonts.roboto(
                    fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
