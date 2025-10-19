import 'package:button_group/button_group.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ButtonGroupExampleApp());
}

/// A simple demo of the [ButtonGroup] widget.
class ButtonGroupExampleApp extends StatelessWidget {
  const ButtonGroupExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Group Demo',
      theme: ThemeData(useMaterial3: true),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  void _onCreate() => debugPrint('Create pressed');
  void _onEdit() => debugPrint('Edit pressed');
  void _onExport() => debugPrint('Export pressed');
  void _onExportCsv() => debugPrint('Export as CSV');
  void _onExportXlsx() => debugPrint('Export as XLSX');
  void _onExportPdf() => debugPrint('Export as PDF');
  void _onShare() => debugPrint('Share pressed');
  void _onDuplicate() => debugPrint('Duplicate pressed');
  void _onDelete() => debugPrint('Delete pressed');
  void _onIcon() => debugPrint('Icon button pressed');

  List<Widget> _demoChildren() => [
        FilledButton.icon(
          onPressed: _onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Create'),
        ),
        FilledButton.icon(
          onPressed: _onEdit,
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
        SplitButton(
          primaryChild: FilledButton.icon(
            onPressed: _onExport,
            icon: const Icon(Icons.file_upload),
            label: const Text('Export'),
          ),
          menuEntries: [
            MenuEntry('CSV', onSelected: _onExportCsv),
            MenuEntry('XLSX', onSelected: _onExportXlsx),
            MenuEntry('PDF', onSelected: _onExportPdf),
          ],
          onPrimaryPressed: _onExport,
        ),
        FilledButton.icon(
          onPressed: _onShare,
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
        FilledButton.icon(
          onPressed: _onDuplicate,
          icon: const Icon(Icons.copy),
          label: const Text('Duplicate'),
        ),
        FilledButton.icon(
          onPressed: _onDelete,
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
        ),
      ];

  List<Widget> _iconChildren() => [
        GroupIconButton.filled(
            onPressed: _onIcon, icon: const Icon(Icons.format_bold)),
        GroupIconButton.filled(
            onPressed: _onIcon, icon: const Icon(Icons.format_italic)),
        GroupIconButton.filled(
            onPressed: _onIcon, icon: const Icon(Icons.format_underline)),
        GroupIconButton.filled(
            onPressed: _onIcon, icon: const Icon(Icons.format_strikethrough)),
        GroupIconButton.filled(
            onPressed: _onIcon, icon: const Icon(Icons.link)),
      ];

  Widget _shapeSection(GroupShape shape) {
    final label = shape == GroupShape.round ? 'round' : 'square';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shape: $label'),
        const SizedBox(height: 8),
        ButtonGroup(
          type: ButtonGroupType.connected,
          shape: shape,
          overflowStrategy: OverflowStrategy.menu,
          children: _demoChildren(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sizeSection(GroupSize size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size: $size'),
        const SizedBox(height: 8),
        ButtonGroup(
          type: ButtonGroupType.connected,
          size: size,
          shape: GroupShape.round,
          overflowStrategy: OverflowStrategy.menu,
          children: _demoChildren(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Button Group Demo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Section(
                title: 'Connected vs Standard',
                subtitle:
                    'A quick comparison of ButtonGroupType.connected and .standard',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Connected'),
                    const SizedBox(height: 8),
                    ButtonGroup(
                      type: ButtonGroupType.connected,
                      shape: GroupShape.round,
                      overflowStrategy: OverflowStrategy.menu,
                      children: _demoChildren().take(4).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Standard'),
                    const SizedBox(height: 8),
                    ButtonGroup(
                      type: ButtonGroupType.standard,
                      shape: GroupShape.round,
                      overflowStrategy: OverflowStrategy.menu,
                      children: _demoChildren().take(4).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Section(
                title: 'Overflow strategies',
                subtitle:
                    'Use the slider to resize and observe how overflow is handled',
                child: _OverflowWidthSliderDemo(
                  children: _demoChildren(),
                ),
              ),
              const SizedBox(height: 16),
              Section(
                title: 'Icon buttons by size — connected',
                subtitle:
                    'Icon-only groups across the size ramp using a connected group',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final s in GroupSize.values) ...[
                      ButtonGroup(
                        type: ButtonGroupType.connected,
                        size: s,
                        shape: GroupShape.round,
                        overflowStrategy: OverflowStrategy.wrap,
                        children: _iconChildren(),
                      ),
                      const SizedBox(height: 12),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Section(
                title: 'Icon buttons by size — standard',
                subtitle: 'Icon-only groups using the standard group style',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final s in GroupSize.values) ...[
                      ButtonGroup(
                        type: ButtonGroupType.standard,
                        size: s,
                        shape: GroupShape.round,
                        overflowStrategy: OverflowStrategy.wrap,
                        children: _iconChildren(),
                      ),
                      const SizedBox(height: 12),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Section(
                title: 'Group shape',
                subtitle: 'Compare round and square outer shapes',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _shapeSection(GroupShape.round),
                    _shapeSection(GroupShape.square),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Section(
                title: 'Group size ramp',
                subtitle: 'Text + icon groups across xs → xl',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sizeSection(GroupSize.xs),
                    _sizeSection(GroupSize.s),
                    _sizeSection(GroupSize.m),
                    _sizeSection(GroupSize.l),
                    _sizeSection(GroupSize.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  const Section(
      {super.key, required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OverflowResizableRow extends StatelessWidget {
  const _OverflowResizableRow({
    required this.title,
    required this.strategy,
    required this.children,
  });

  final String title;
  final OverflowStrategy strategy;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _ResizableWidth(
          initialWidth: 320,
          minWidth: 160,
          maxWidth: 720,
          builder: (width) => Container(
            width: width,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ButtonGroup(
              type: ButtonGroupType.connected,
              shape: GroupShape.round,
              overflowStrategy: strategy,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResizableWidth extends StatefulWidget {
  const _ResizableWidth({
    required this.builder,
    this.initialWidth = 380,
    this.minWidth = 160,
    this.maxWidth = 800,
  });

  final Widget Function(double width) builder;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;

  @override
  State<_ResizableWidth> createState() => _ResizableWidthState();
}

class _ResizableWidthState extends State<_ResizableWidth> {
  late double _width = widget.initialWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.builder(_width),
        MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              setState(() {
                _width = (_width + details.delta.dx)
                    .clamp(widget.minWidth, widget.maxWidth);
              });
            },
            child: Container(
              width: 12,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: const Center(
                child: Icon(Icons.drag_indicator, size: 12),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text('${_width.toStringAsFixed(0)} px',
              style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _OverflowWidthSliderDemo extends StatefulWidget {
  const _OverflowWidthSliderDemo({
    super.key,
    required this.children,
    this.initialWidth = 320,
    this.minWidth = 160,
    this.maxWidth = 720,
  });

  final List<Widget> children;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;

  @override
  State<_OverflowWidthSliderDemo> createState() =>
      _OverflowWidthSliderDemoState();
}

class _OverflowWidthSliderDemoState extends State<_OverflowWidthSliderDemo> {
  late double _width = widget.initialWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                min: widget.minWidth,
                max: widget.maxWidth,
                value: _width.clamp(widget.minWidth, widget.maxWidth),
                onChanged: (v) => setState(() => _width = v),
              ),
            ),
            const SizedBox(width: 8),
            Text('${_width.toStringAsFixed(0)} px',
                style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Text('OverflowStrategy.menu', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: _width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ButtonGroup(
            type: ButtonGroupType.connected,
            shape: GroupShape.round,
            overflowStrategy: OverflowStrategy.menu,
            children: widget.children,
          ),
        ),
        const SizedBox(height: 12),
        Text('OverflowStrategy.wrap', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: _width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ButtonGroup(
            type: ButtonGroupType.connected,
            shape: GroupShape.round,
            overflowStrategy: OverflowStrategy.wrap,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
