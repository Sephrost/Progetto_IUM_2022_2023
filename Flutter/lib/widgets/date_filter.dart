import 'package:flutter/material.dart';

// Filter chip with date selector

class DateFilter extends StatefulWidget {
  final String _label;
  final Function _updateProvider;

  const DateFilter(this._label, {Key? key, required Function updateProvider})
      : _updateProvider = updateProvider,
        super(key: key);
  @override
  State<DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  String _date = "";
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text("${widget._label} $_date"),
      avatar: _selected
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _selected = false;
                  _date = "";
                  widget._updateProvider(_date);
                });
              },
              child: Icon(
                Icons.close,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
            )
          : const Icon(Icons.calendar_today),
      backgroundColor: _selected
          ? Theme.of(context).colorScheme.secondaryContainer
          : Colors.transparent,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      onPressed: () async {
        final date = await showDatePicker(
          locale: const Locale("it"),
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101),
        );
        if (date != null) {
          setState(() {
            _date =
                "${date.day}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(2, '0')}";
            _selected = true;
            widget._updateProvider(
                '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
          });
        }
      },
    );
  }
}
