import 'package:flutter/material.dart';

class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    Key? key,
    required this.index,
    required this.children,
  }) : super(key: key);

  final int index;
  final List<Widget> children;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _activatedList;

  @override
  void initState() {
    super.initState();
    _activatedList = List.generate(
      widget.children.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activatedList.length != widget.children.length) {
      _activatedList = List.generate(
        widget.children.length,
        (i) => i == widget.index,
      );
    } else if (!_activatedList[widget.index]) {
      _activatedList[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        if (!_activatedList[i]) return const SizedBox.shrink();
        return widget.children[i];
      }),
    );
  }
}
