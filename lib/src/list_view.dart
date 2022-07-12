import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'index_path.dart';
import 'list_item.dart';
import 'list_item_type.dart';

/// Signature for a function that creates a widget for a given [IndexPath], in a
/// list.
///
/// Used by [GroupListView].
typedef ItemWidgetBuilder = Widget Function(
  BuildContext context,
  IndexPath index,
);

/// Signature for a function that returns the  the number of items(rows)
/// in a given section
///
/// Used by [GroupListView].
typedef SectionWidgetBuilder = Widget Function(
  BuildContext context,
  int section,
);

class GroupListView extends StatelessWidget {
  ///The number of sections in the ListView.
  final int sectionsCount;

  ///Function which returns an Widget which defines the item at the specified IndexPath.
  ///
  ///[itemBuilder] provides the current section and index.
  final ItemWidgetBuilder itemBuilder;

  ///Function which returns an Widget which defines the section header for each group.
  final SectionWidgetBuilder groupHeaderBuilder;

  ///Function which returns the number of items(rows) in a specified section.
  final int Function(int section) countOfItemInSection;

  ///Function which returns an Widget which defines the separator at the specified IndexPath.
  ///
  /// Separators only appear between list items: separator 0 appears after item
  /// 0 and the last separator appears after the last item.
  ///
  ///[separatorBuilder] provides the current section and index.
  final ItemWidgetBuilder? separatorBuilder;

  ///Function which returns an Widget which defines the separator at the specified section.
  ///
  /// Separators only appear between sections: separator 0 appears after section
  /// 0 and the last separator appears after the last section.
  ///
  ///[sectionSeparatorBuilder] provides the current section.
  final SectionWidgetBuilder? sectionSeparatorBuilder;

  //Fields from ListView.builder constructor

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// When this is true, the scroll view is scrollable even if it does not have
  /// sufficient content to actually scroll. Otherwise, by default the user can
  /// only scroll the view if it has sufficient content. See [physics].
  ///
  /// On iOS, this also identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions. Furthermore, if [primary] is
  /// false, then the user cannot scroll if there is insufficient content to
  /// scroll, while if [primary] is true, they can always attempt to scroll.
  ///
  /// To force the scroll view to always be scrollable even if there is
  /// insufficient content, as if [primary] was true but without necessarily
  /// setting it to true, provide an [AlwaysScrollableScrollPhysics] physics
  /// object, as in:
  ///
  /// ```dart
  ///   physics: const AlwaysScrollableScrollPhysics(),
  /// ```
  ///
  /// To force the scroll view to use the default platform conventions and not
  /// be scrollable if there is insufficient content, regardless of the value of
  /// [primary], provide an explicit [ScrollPhysics] object, as in:
  ///
  /// ```dart
  ///   physics: const ScrollPhysics(),
  /// ```
  ///
  /// The physics can be changed dynamically (by providing a new object in a
  /// subsequent build), but new physics will only take effect if the _class_ of
  /// the provided object changes. Merely constructing a new instance with a
  /// different configuration is insufficient to cause the physics to be
  /// reapplied. (This is because the final object used is generated
  /// dynamically, which can be relatively expensive, and it would be
  /// inefficient to speculatively create this object each frame to see if the
  /// physics should be updated.)
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// If non-null, forces the children to have the given extent in the scroll
  /// direction.
  ///
  /// Specifying an [itemExtent] is more efficient than letting the children
  /// determine their own extent because the scrolling machinery can make use of
  /// the foreknowledge of the children's extent to save work, for example when
  /// the scroll position changes drastically.
  final double? itemExtent;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  ///
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAlive]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAlive] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// Whether to wrap each child in an [IndexedSemantics].
  ///
  /// Typically, children in a scrolling container must be annotated with a
  /// semantic index in order to generate the correct accessibility
  /// announcements. This should only be set to false if the indexes have
  /// already been provided by an [IndexedChildSemantics]
  ///
  /// Defaults to true.
  ///
  /// See also:
  ///
  ///  * [IndexedChildSemantics], for an explanation of how to manually
  ///    provide semantic indexes.
  final bool addSemanticIndexes;

  /// {@macro flutter.rendering.viewport.cacheExtent}
  final double? cacheExtent;

  /// The number of children that will contribute semantic information.
  ///
  /// Some subtypes of [ScrollView] can infer this value automatically. For
  /// example [ListView] will use the number of widgets in the child list,
  /// while the [new ListView.separated] constructor will use half that amount.
  ///
  /// For [CustomScrollView] and other types which do not receive a builder
  /// or list of widgets, the child count must be explicitly provided. If the
  /// number is unknown or unbounded this should be left unset or set to null.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.scrollChildCount], the corresponding semantics property.
  final int? semanticChildCount;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior? dragStartBehavior;

  /// {@macro flutter.material.Material.clipBehavior}
  final Clip? clipBehavior;

  /// {@macro flutter.widgets.scrollable.findChildIndexCallback}
  final int? Function(Key)? findChildIndexCallback;

  /// {@macro flutter.widgets.scrollable.keyboardDismissBehavior}
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  final bool _positioned;

  final ItemPositionsListener? itemPositionsListener;
  final int? initialScrollIndex;
  final ItemScrollController? itemScrollController;
  final double? minCacheExtent;

  const GroupListView({
    Key? key,
    required this.itemBuilder,
    required this.sectionsCount,
    required this.groupHeaderBuilder,
    required this.countOfItemInSection,
    this.separatorBuilder,
    this.sectionSeparatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    DragStartBehavior this.dragStartBehavior = DragStartBehavior.start,
    this.findChildIndexCallback,
    Clip this.clipBehavior = Clip.hardEdge,
    ScrollViewKeyboardDismissBehavior this.keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
  })  : _positioned = false,
        itemPositionsListener = null,
        initialScrollIndex = null,
        itemScrollController = null,
        minCacheExtent = null,
        super(key: key);

  const GroupListView.positioned({
    Key? key,
    required this.itemBuilder,
    required this.sectionsCount,
    required this.groupHeaderBuilder,
    required this.countOfItemInSection,
    this.separatorBuilder,
    this.sectionSeparatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticChildCount,
    this.itemPositionsListener,
    this.initialScrollIndex,
    this.itemScrollController,
    this.minCacheExtent,
  })  : _positioned = true,
        controller = null,
        primary = null,
        itemExtent = null,
        cacheExtent = null,
        dragStartBehavior = null,
        clipBehavior = null,
        findChildIndexCallback = null,
        keyboardDismissBehavior = null,
        restorationId = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final _indexToIndexPathList = <ListItem>[
      for (int section = 0; section < sectionsCount; section++) ...[
        ListItem(
          indexPath: IndexPath(section: section, index: 0),
          type: ListItemType.section,
        ),
        for (int index = 0; index < countOfItemInSection(section); index++) ...[
          ListItem(
            indexPath: IndexPath(section: section, index: index),
            type: ListItemType.item,
          ),
          if (separatorBuilder != null)
            ListItem(
              indexPath: IndexPath(section: section, index: index),
              type: ListItemType.itemSeparator,
            ),
          if (sectionSeparatorBuilder != null)
            ListItem(
              indexPath: IndexPath(section: section, index: 0),
              type: ListItemType.sectionSeparator,
            ),
        ]
      ]
    ];

    Widget _itemBuilder(BuildContext context, int index) {
      final ListItem listItem = _indexToIndexPathList[index];
      final IndexPath indexPath = listItem.indexPath;

      if (listItem.type.isSection) {
        return groupHeaderBuilder(context, indexPath.section);
      } else if (listItem.type.isSectionSeparator) {
        return sectionSeparatorBuilder!(context, indexPath.section);
      } else if (listItem.type.isItemSeparator) {
        return separatorBuilder!(context, indexPath);
      }
      return itemBuilder(context, indexPath);
    }

    if (_positioned) {
      return ScrollablePositionedList.builder(
        scrollDirection: scrollDirection,
        reverse: reverse,
        itemPositionsListener: itemPositionsListener,
        initialScrollIndex: initialScrollIndex ?? 0,
        itemScrollController: itemScrollController,
        minCacheExtent: minCacheExtent,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        semanticChildCount: semanticChildCount,
        itemCount: _indexToIndexPathList.length,
        itemBuilder: _itemBuilder,
      );
    }

    return ListView.builder(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior!,
      clipBehavior: clipBehavior!,
      findChildIndexCallback: findChildIndexCallback,
      keyboardDismissBehavior: keyboardDismissBehavior!,
      restorationId: restorationId,
      itemCount: _indexToIndexPathList.length,
      itemBuilder: _itemBuilder,
    );
  }
}
