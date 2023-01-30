import 'package:flutter/material.dart';

/// This widget is a toggle chip that can be used to filter items.
class FilterToggleChip extends StatefulWidget {
  final String label;

  final Function(bool) onSelected;

  const FilterToggleChip(
      {Key? key, required this.label, required this.onSelected})
      : super(key: key);

  @override
  State<FilterToggleChip> createState() => _FilterToggleChipState();
}

class _FilterToggleChipState extends State<FilterToggleChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(widget.label),
      onPressed: () {
        setState(() {
          _selected = !_selected;
          widget.onSelected(_selected);
        });
      },
      backgroundColor: _selected
          ? Theme.of(context).colorScheme.secondaryContainer
          : Colors.transparent,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      pressElevation: 1.0,
    );
  }
}
