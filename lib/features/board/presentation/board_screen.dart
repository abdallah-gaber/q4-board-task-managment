import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:q4_board/l10n/app_localizations.dart';

import '../../../core/design/app_radii.dart';
import '../../../core/design/app_spacing.dart';
import '../../../domain/entities/note_entity.dart';
import '../../../domain/enums/quadrant_type.dart';
import '../controllers/board_controller.dart';
import 'widgets/mobile_quadrant_tab.dart';
import 'widgets/quadrant_panel.dart';

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _mobileTabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mobileTabController = TabController(
      length: QuadrantType.values.length,
      vsync: this,
    )..addListener(_onMobileTabChanged);
  }

  @override
  void dispose() {
    _mobileTabController
      ..removeListener(_onMobileTabChanged)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(boardControllerProvider);
    final isMobile = MediaQuery.sizeOf(context).width < 900;

    if (_searchController.text != state.query) {
      _searchController.value = _searchController.value.copyWith(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.board),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(
                quadrant: QuadrantType.values[_mobileTabController.index],
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addNote),
            )
          : null,
      body: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          isMobile ? 12 : AppSpacing.md,
          AppSpacing.sm,
          isMobile ? 12 : AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          children: [
            _BoardToolbar(
              isMobile: isMobile,
              searchController: _searchController,
              showDone: state.showDone,
              onQueryChanged: ref
                  .read(boardControllerProvider.notifier)
                  .setQuery,
              onShowDoneChanged: ref
                  .read(boardControllerProvider.notifier)
                  .setShowDone,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: isMobile
                  ? _MobileBoard(
                      tabController: _mobileTabController,
                      state: state,
                      onEdit: _onEdit,
                      onDelete: _onDelete,
                      onToggleDone: _onToggleDone,
                      onMove: _onMove,
                      onReorder: _onReorder,
                    )
                  : _DesktopBoard(
                      state: state,
                      onAdd: _openEditor,
                      onEdit: _onEdit,
                      onDelete: _onDelete,
                      onToggleDone: _onToggleDone,
                      onDrop: _onDrop,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMobileTabChanged() {
    if (!_mobileTabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  void _openEditor({required QuadrantType quadrant, String? noteId}) {
    final query = <String, String>{'quadrant': quadrant.name};
    if (noteId != null) {
      query['noteId'] = noteId;
    }

    final queryString = query.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    context.push('/editor?$queryString');
  }

  void _onEdit(NoteEntity note) {
    _openEditor(quadrant: note.quadrantType, noteId: note.id);
  }

  Future<void> _onToggleDone(NoteEntity note) async {
    await ref
        .read(boardControllerProvider.notifier)
        .toggleDone(note.id, note.isDone);
  }

  Future<void> _onDelete(NoteEntity note) async {
    final controller = ref.read(boardControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final deleted = await controller.deleteNote(note.id);
    if (!mounted || deleted == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.noteDeleted),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => controller.restoreDeletedNote(deleted),
          ),
        ),
      );
  }

  Future<void> _onMove(NoteEntity note, QuadrantType targetQuadrant) async {
    final controller = ref.read(boardControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final undo = await controller.moveNote(
      noteId: note.id,
      toQuadrant: targetQuadrant,
      toIndex: ref
          .read(boardControllerProvider)
          .orderedNotesForQuadrant(targetQuadrant)
          .length,
    );

    if (!mounted || undo == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.noteMoved),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => controller.undoMove(undo),
          ),
        ),
      );
  }

  Future<void> _onDrop(
    NoteDragData dragData,
    QuadrantType quadrant,
    int index,
  ) async {
    final controller = ref.read(boardControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final visibleNotes = ref
        .read(boardControllerProvider)
        .filteredNotesForQuadrant(quadrant);
    var targetIndex = index;
    if (dragData.fromQuadrant == quadrant &&
        dragData.fromVisibleIndex < targetIndex) {
      targetIndex -= 1;
    }

    final undo = await controller.moveNote(
      noteId: dragData.noteId,
      toQuadrant: quadrant,
      toIndex: targetIndex,
      visibleNoteIds: visibleNotes.map((note) => note.id).toList(),
    );
    if (!mounted || undo == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.noteMoved),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => controller.undoMove(undo),
          ),
        ),
      );
  }

  Future<void> _onReorder(
    QuadrantType quadrant,
    int oldIndex,
    int newIndex,
  ) async {
    final visibleNotes = ref
        .read(boardControllerProvider)
        .filteredNotesForQuadrant(quadrant);
    await ref
        .read(boardControllerProvider.notifier)
        .reorderInQuadrant(
          quadrant,
          oldIndex,
          newIndex,
          visibleNotes.map((note) => note.id).toList(),
        );
  }
}

enum _DoneFilterMode { all, hideDone }

class _BoardToolbar extends StatelessWidget {
  const _BoardToolbar({
    required this.isMobile,
    required this.searchController,
    required this.showDone,
    required this.onQueryChanged,
    required this.onShowDoneChanged,
  });

  final bool isMobile;
  final TextEditingController searchController;
  final bool showDone;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<bool> onShowDoneChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final searchField = TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
      onChanged: onQueryChanged,
    );

    final selectedMode = showDone
        ? _DoneFilterMode.all
        : _DoneFilterMode.hideDone;
    final doneFilterControl = SegmentedButton<_DoneFilterMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment<_DoneFilterMode>(
          value: _DoneFilterMode.all,
          icon: const Icon(Icons.checklist_rounded, size: 18),
          label: Text(l10n.filterAll),
        ),
        ButtonSegment<_DoneFilterMode>(
          value: _DoneFilterMode.hideDone,
          icon: const Icon(Icons.visibility_off_outlined, size: 18),
          label: Text(l10n.filterHideDone),
        ),
      ],
      selected: {selectedMode},
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onSelectionChanged: (selection) {
        final nextMode = selection.first;
        onShowDoneChanged(nextMode == _DoneFilterMode.all);
      },
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Semantics(
              label: l10n.doneFilterControl,
              child: doneFilterControl,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 250, maxWidth: 340),
          child: Semantics(
            label: l10n.doneFilterControl,
            child: doneFilterControl,
          ),
        ),
      ],
    );
  }
}

class _DesktopBoard extends StatelessWidget {
  const _DesktopBoard({
    required this.state,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
    required this.onDrop,
  });

  final BoardState state;
  final void Function({required QuadrantType quadrant, String? noteId}) onAdd;
  final ValueChanged<NoteEntity> onEdit;
  final ValueChanged<NoteEntity> onDelete;
  final ValueChanged<NoteEntity> onToggleDone;
  final void Function(NoteDragData dragData, QuadrantType quadrant, int index)
  onDrop;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.22,
      children: [
        for (final quadrant in QuadrantType.values)
          QuadrantPanel(
            key: ValueKey<String>('desktop-quadrant-${quadrant.name}'),
            quadrantType: quadrant,
            notes: state.filteredNotesForQuadrant(quadrant),
            onAdd: () => onAdd(quadrant: quadrant),
            onEdit: onEdit,
            onDelete: onDelete,
            onToggleDone: onToggleDone,
            onDrop: (dragData, toIndex) => onDrop(dragData, quadrant, toIndex),
          ),
      ],
    );
  }
}

class _MobileBoard extends StatelessWidget {
  const _MobileBoard({
    required this.tabController,
    required this.state,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
    required this.onMove,
    required this.onReorder,
  });

  final TabController tabController;
  final BoardState state;
  final ValueChanged<NoteEntity> onEdit;
  final ValueChanged<NoteEntity> onDelete;
  final ValueChanged<NoteEntity> onToggleDone;
  final void Function(NoteEntity note, QuadrantType targetQuadrant) onMove;
  final void Function(QuadrantType quadrant, int oldIndex, int newIndex)
  onReorder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: TabBar(
            controller: tabController,
            labelPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.md - 2),
            ),
            tabs: [
              _iconTab(
                icon: Icons.bolt_rounded,
                semantics: l10n.q1TabSemantics,
              ),
              _iconTab(
                icon: Icons.event_available_rounded,
                semantics: l10n.q2TabSemantics,
              ),
              _iconTab(
                icon: Icons.person_outline_rounded,
                semantics: l10n.q3TabSemantics,
              ),
              _iconTab(
                icon: Icons.block_rounded,
                semantics: l10n.q4TabSemantics,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              for (final quadrant in QuadrantType.values)
                MobileQuadrantTab(
                  key: ValueKey<String>('mobile-tab-${quadrant.name}'),
                  quadrant: quadrant,
                  notes: state.filteredNotesForQuadrant(quadrant),
                  searchActive: state.query.trim().isNotEmpty,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onToggleDone: onToggleDone,
                  onMove: onMove,
                  onReorder: (oldIndex, newIndex) =>
                      onReorder(quadrant, oldIndex, newIndex),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconTab({required IconData icon, required String semantics}) {
    return Tab(
      icon: Tooltip(
        message: semantics,
        child: Semantics(label: semantics, child: Icon(icon)),
      ),
    );
  }
}
