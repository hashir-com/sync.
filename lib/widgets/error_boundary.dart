import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $_error'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null); // Retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _error = null; // Reset on update
  }
}
