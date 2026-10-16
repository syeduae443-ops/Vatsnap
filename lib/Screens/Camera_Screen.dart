import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/ocr_service.dart';
import '../services/export_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  Map<String, String> _invoiceData = {};
  final OCRService _ocr = OCRService();
  final ExportService _export = ExportService();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureAndScan() async {
    if (_controller == null ||!_controller!.value.isInitialized) return;
    setState(() => _isProcessing = true);
    try {
      final file = await _controller!.takePicture();
      final data = await _ocr.extractVatData(file.path);
      setState(() => _invoiceData = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VatSnap - Dubai VAT Scanner'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _controller!= null && _controller!.value.isInitialized
               ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          if (_invoiceData.isNotEmpty)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  children: [
                    Text('TRN: ${_invoiceData['trn']?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Invoice No: ${_invoiceData['invoiceNo']?? ''}'),
                    Text('Date: ${_invoiceData['date']?? ''}'),
                    Text('VAT Amount: ${_invoiceData['vat']?? ''} AED'),
                    Text('Total: ${_invoiceData['total']?? ''} AED'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: () => _export.exportToTally(_invoiceData), child: const Text('Tally'))),
                        const SizedBox(width: 8),
                        Expanded(child: ElevatedButton(onPressed: () => _export.exportToOdoo(_invoiceData), child: const Text('Odoo'))),
                        const SizedBox(width: 8),
                        Expanded(child: ElevatedButton(onPressed: () => _export.exportToCSV(_invoiceData), child: const Text('CSV'))),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing? null : _captureAndScan,
        label: Text(_isProcessing? 'Scanning...' : 'Scan Invoice'),
        icon: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
