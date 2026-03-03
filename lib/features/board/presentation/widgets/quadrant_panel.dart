import 'package:flutter/material.dart';
import 'package:q4_board/l10n/app_localizations.dart';

import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../domain/entities/note_entity.dart';
import '../../../../domain/enums/quadrant_type.dart';
import '../quadrant_ui.dart';
import 'sticky_note_card.dart';

class NoteDragData {
  const NoteDragData({
    required this.noteId,
    required this.fromQuadrant,
    required this.fromVisibleIndex,
  });

  final String noteId;
  final QuadrantType fromQuadrant;
  final int fromVisibleIndex;
}

class QuadrantPanel extends StatefulWidget {
  const QuadrantPanel({
    super.key,
    required this.quadrantType,
    required this.notes,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
    required this.onDrop,
  });

  final QuadrantType quadrantType;
  final List<NoteEntity> notes;
  final VoidCallback onAdd;
  final ValueChanged<NoteEntity> onEdit;
  final ValueChanged<NoteEntity> onDelete;
  final ValueChanged<NoteEntity> onToggleDone;
  final void Function(NoteDragData dragData, int toIndex) onDrop;

  @override
  State<QuadrantPanel> createState() => _QuadrantPanelState();
}

class _QuadrantPanelState extends State<QuadrantPanel> {
  String? _draggingNoteId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visual = quadrantVisualFor(widget.quadrantType);

    return DragTarget<NoteDragData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) =>
          widget.onDrop(details.data, widget.notes.length),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: visual.panelTint(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isHovered
                  ? visual.accentColor.withValues(alpha: 0.9)
                  : visual.accentColor.withValues(alpha: 0.36),
              width: isHovered ? 2 : 1.2,
            ),
            boxShadow: isHovered
                ? AppShadows.soft(visual.accentColor)
                : const <BoxShadow>[],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: visual.accentColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(visual.icon, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visual.actionLabel(l10n),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w700,
                                color: visual.accentColor,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          visual.title(l10n),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onAdd,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    tooltip: l10n.addNote,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: widget.notes.isEmpty
                    ? _EmptyQuadrantState(
                        quadrantType: widget.quadrantType,
                        onDrop: widget.onDrop,
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final feedbackWidth = constraints.maxWidth;

                          return ListView.builder(
                            key: PageStorageKey<String>(
                              'quadrant-${widget.quadrantType.name}',
                            ),
                            itemCount: widget.notes.length * 2 + 1,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              if (index.isEven) {
                                final toIndex = index ~/ 2;
                                return _DropSlot(
                                  onAccept: (dragData) =>
                                      widget.onDrop(dragData, toIndex),
                                );
                              }

                              final noteIndex = (index - 1) ~/ 2;
                              final note = widget.notes[noteIndex];

                              final feedbackCard = StickyNoteCard(
                                note: note,
                                visual: visual,
                                onToggleDone: (_) {},
                                onEdit: () {},
                                onDelete: () {},
                                disableActions: true,
                              );

                              final card = StickyNoteCard(
                                key: ValueKey<String>('desktop-${note.id}'),
                                note: note,
                                visual: visual,
                                onToggleDone: (value) => widget.onToggleDone(
                                  note.copyWith(isDone: value),
                                ),
                                onEdit: () => widget.onEdit(note),
                                onDelete: () => widget.onDelete(note),
                                trailing: Tooltip(
                                  message: l10n.dragToReorder,
                                  child: _DragHandleVisual(
                                    isDragging: _draggingNoteId == note.id,
                                  ),
                                ),
                              );

                              return RepaintBoundary(
                                child: LongPressDraggable<NoteDragData>(
                                  data: NoteDragData(
                                    noteId: note.id,
                                    fromQuadrant: note.quadrantType,
                                    fromVisibleIndex: noteIndex,
                                  ),
                                  dragAnchorStrategy: pointerDragAnchorStrategy,
                                  onDragStarted: () => _setDragging(note.id),
                                  onDragCompleted: _clearDragging,
                                  onDragEnd: (_) => _clearDragging(),
                                  onDraggableCanceled: (_, __) =>
                                      _clearDragging(),
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: SizedBox(
                                      width: feedbackWidth,
                                      child: feedbackCard,
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.24,
                                    child: IgnorePointer(child: card),
                                  ),
                                  child: card,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _setDragging(String noteId) {
    if (!mounted) {
      return;
    }
    setState(() {
      _draggingNoteId = noteId;
    });
  }

  void _clearDragging() {
    if (!mounted) {
      return;
    }
    setState(() {
      _draggingNoteId = null;
    });
  }
}

class _DragHandleVisual extends StatelessWidget {
  const _DragHandleVisual({required this.isDragging});

  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: isDragging ? 0.42 : 0.68),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          Icons.drag_indicator_rounded,
          size: 16,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _DropSlot extends StatelessWidget {
  const _DropSlot({required this.onAccept});

  final ValueChanged<NoteDragData> onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<NoteDragData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: candidateData.isNotEmpty ? 14 : 8,
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.24)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class _EmptyQuadrantState extends StatelessWidget {
  const _EmptyQuadrantState({required this.quadrantType, required this.onDrop});

  final QuadrantType quadrantType;
  final void Function(NoteDragData dragData, int toIndex) onDrop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visual = quadrantVisualFor(quadrantType);

    return DragTarget<NoteDragData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onDrop(details.data, 0),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? visual.accentColor
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(visual.icon, size: 30),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.emptyQuadrant,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
