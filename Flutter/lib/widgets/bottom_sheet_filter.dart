import 'package:flutter/material.dart';

class BottomSheetFilter extends StatefulWidget {
  final String _label;
  final List<String> _options;
  final List<String>? _selectedOptions;
  final Icon? _icon;
  final Function _updateProvider;

  const BottomSheetFilter(
      {Key? key,
      required String label,
      required List<String> options,
      List<String>? selectedOptions,
      Icon? icon,
      required Function updateProvider})
      : _label = label,
        _options = options,
        _selectedOptions = selectedOptions,
        _icon = icon,
        _updateProvider = updateProvider,
        super(key: key);

  @override
  State<BottomSheetFilter> createState() => _BottomSheetFilterState();
}

class _BottomSheetFilterState extends State<BottomSheetFilter> {
  late List<String> _selectedOptions;
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selectedOptions = widget._selectedOptions ?? [];
    _selected = _selectedOptions.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
        label: Row(children: [
          Text(_selectedOptions.isNotEmpty
              ? _selectedOptions.length > 1
                  ? "${_selectedOptions[0]} + ${_selectedOptions.length - 1}"
                  : _selectedOptions[0]
              : widget._label),
          Icon(
            Icons.arrow_drop_down,
            size: Theme.of(context).textTheme.bodyText1!.fontSize,
          )
        ]),
        avatar: _selected ? null : widget._icon,
        backgroundColor: _selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : Colors.transparent,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (context) => _BottomSheetFilterExpanded(
                    label: widget._label,
                    options: widget._options,
                    selectedOptions: _selectedOptions,
                  )).then((value) {
            setState(() {
              if (value != null) {
                _selectedOptions = value;
                widget._updateProvider(_selectedOptions);
              }
              _selected = _selectedOptions.isNotEmpty;
            });
          });
        });
  }
}

class _BottomSheetFilterExpanded extends StatefulWidget {
  final String _label;
  final List<String> _selectedOptions;
  final List<String> _options;

  const _BottomSheetFilterExpanded(
      {Key? key,
      required String label,
      required List<String> options,
      required List<String> selectedOptions})
      : _selectedOptions = selectedOptions,
        _label = label,
        _options = options,
        super(key: key);

  @override
  State<_BottomSheetFilterExpanded> createState() =>
      _BottomSheetFilterExpandedState();
}

class _BottomSheetFilterExpandedState
    extends State<_BottomSheetFilterExpanded> {
  late Map<String, bool> _optionsMap;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _optionsMap = {
      for (var e in widget._options) e: widget._selectedOptions.contains(e)
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        // MediaQuery.of(context).viewPadding.top is set to zero by the
        // safearea, so we use the padding in physical pixels divided by the
        // pixel ratio to get the height in logical pixels that should have been
        // returned
        height: MediaQuery.of(context).size.height -
            WidgetsBinding.instance.window.padding.top /
                WidgetsBinding.instance.window.devicePixelRatio,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              padding:
                  const EdgeInsets.only(top: 16.0, left: 16.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget._label,
                      style: Theme.of(context).textTheme.headline6),
                  IconButton(
                      onPressed: () => Navigator.pop(
                          context,
                          _optionsMap.keys
                              .where((element) => _optionsMap[element]!)
                              .toList()),
                      icon: const Icon(Icons.close))
                ],
              )),
          const Divider(
            thickness: 1.5,
          ),
          TextField(
            decoration: InputDecoration(
                hintText: 'Filtra ${widget._label.toLowerCase()}',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 16.0)),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          Divider(
            thickness: 1.5,
            color: Theme.of(context).colorScheme.outline,
          ),
          Expanded(
              child: ListView.builder(
                  primary: false,
                  itemCount: _optionsMap.keys
                      .where((element) =>
                          element.toLowerCase().contains(_query.toLowerCase()))
                      .length,
                  itemBuilder: (context, index) {
                    final option = _optionsMap.keys
                        .where((element) => element
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                        .toList()[index];
                    return CheckboxListTile(
                        title: Text(option),
                        value: _optionsMap[option],
                        onChanged: (value) {
                          setState(() {
                            _optionsMap.update(option, (value) => !value);
                            Navigator.pop(
                                context,
                                _optionsMap.keys
                                    .where((element) => _optionsMap[element]!)
                                    .toList());
                          });
                        });
                  }))
        ]));
  }
}
