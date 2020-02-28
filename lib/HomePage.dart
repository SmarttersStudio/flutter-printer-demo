import 'dart:typed_data';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Printer Demo'),
      ),
      body: ListView.builder(
        itemBuilder: (context,position)=>ListTile(
          onTap: () async {
            printerManager.selectPrinter(_devices[position]);
            Ticket ticket=Ticket(PaperSize.mm58);
            ticket.text('Demo text',styles: PosStyles(
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size8,
              align: PosTextAlign.center,
              fontType: PosFontType.fontA,
              reverse: false,
              underline: true,
            ));
            ticket.emptyLines(1);
            ticket.row([
              PosColumn(
                text: 'Item     ',
                width: 9,
                styles: PosStyles(align: PosTextAlign.right, underline: true),
              ),
              PosColumn(
                text: 'Price',
                width: 3,
                styles: PosStyles(align: PosTextAlign.right, underline: true),
              ),
            ]);
            final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
            ticket.barcode(Barcode.upcA(barData));
            final ByteData data = await NetworkAssetBundle(Uri.parse('YOUR URL')).load("");
            final Uint8List bytes = data.buffer.asUint8List();
            final Img.Image image = Img.decodeImage(bytes);
            ticket.image(image);
            ticket.feed(2);
            ticket.cut();
            printerManager.printTicket(ticket).then((result) {
              Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.msg)));
            }).catchError((error){
              Scaffold.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
            });
          },
          title: Text(_devices[position].name),
          subtitle: Text(_devices[position].address),
        ),
        itemCount: _devices.length,
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        printerManager.startScan(Duration(seconds: 4));
        printerManager.scanResults.listen((scannedDevices) {
          setState(() {
            _devices=scannedDevices;
          });
        });
      },child: Icon(Icons.search),),
    );
  }
}
