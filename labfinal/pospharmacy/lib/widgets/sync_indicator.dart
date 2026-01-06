import 'package:flutter/material.dart';
import '../core/utils/sync_manager.dart';

class SyncIndicator extends StatefulWidget {
  const SyncIndicator({Key? key}) : super(key: key);

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> {
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _checkSync();
  }

  Future<void> _checkSync() async {
    setState(() => _isSyncing = true);
    await SyncManager.syncAll();
    setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _isSyncing
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Icon(Icons.cloud_done, color: Colors.white),
    );
  }
}
