import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRStockUpdateWidget extends StatefulWidget {
  final Function(String) onQRDetected;
  final VoidCallback onCancelPressed;

  const QRStockUpdateWidget({
    super.key,
    required this.onQRDetected,
    required this.onCancelPressed,
  });

  @override
  State<QRStockUpdateWidget> createState() => _QRStockUpdateWidgetState();
}

class _QRStockUpdateWidgetState extends State<QRStockUpdateWidget> {
  final MobileScannerController controller = MobileScannerController();
  bool _procesando = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (!_procesando &&
                barcodes.isNotEmpty &&
                barcodes.first.rawValue != null) {
              setState(() {
                _procesando = true;
              });
              widget.onQRDetected(barcodes.first.rawValue!);
            }
          },
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (_procesando) ...[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/app_icon.png',
                                width: 100,
                                height: 100,
                              ),
                              SizedBox(height: 24),
                              CircularProgressIndicator(),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Procesando código QR...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Apunta la cámara al código QR del producto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  onPressed: widget.onCancelPressed,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Cancelar'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
