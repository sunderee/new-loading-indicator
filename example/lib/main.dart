import 'package:flutter/material.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loading Indicators Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const LoadingGallery(),
    );
  }
}

class LoadingGallery extends StatefulWidget {
  const LoadingGallery({super.key});

  @override
  State<LoadingGallery> createState() => _LoadingGalleryState();
}

class _LoadingGalleryState extends State<LoadingGallery> {
  Indicator _selectedIndicator = Indicator.ballPulse;
  bool _isPaused = false;
  final List<Color> _colors = [Colors.blue];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Indicators')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600.0) {
            return _buildWideLayout();
          }

          return _buildNarrowLayout();
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildIndicatorList()),
        const VerticalDivider(),
        Expanded(flex: 3, child: _buildPreviewArea()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        Expanded(flex: 2, child: _buildPreviewArea()),
        const Divider(),
        Expanded(flex: 3, child: _buildIndicatorList()),
      ],
    );
  }

  Widget _buildPreviewArea() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150.0,
            height: 150.0,
            child: LoadingIndicator(
              indicatorType: _selectedIndicator,
              colors: _colors,
              pause: _isPaused,
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            _selectedIndicator.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: _isPaused,
                onChanged: (value) => setState(() => _isPaused = value),
              ),
              const SizedBox(width: 8),
              Text(_isPaused ? 'Paused' : 'Running'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorList() {
    return ListView.builder(
      itemCount: Indicator.values.length,
      itemBuilder: (context, index) {
        final indicator = Indicator.values[index];
        return ListTile(
          leading: SizedBox(
            width: 30.0,
            height: 30.0,
            child: LoadingIndicator(indicatorType: indicator, colors: _colors),
          ),
          title: Text(indicator.name),
          selected: _selectedIndicator == indicator,
          onTap: () => setState(() => _selectedIndicator = indicator),
        );
      },
    );
  }
}
