import 'package:app_bet/controller/calculadora_bet.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GeradorPDF {
  static List<(String, String)> _listaDeCompras(
    CalculosBET calc,
    double distanciaCasa,
  ) {
    final barrasPVC100 = calc.tuboEsgoto100Barras(distanciaCasa);
    return [
      ('Tijolos 6 furos', '${calc.tijolos6Furos} unid.'),
      ('Cimento', '${calc.cimentoSacosTotal} sacos de 50 kg'),
      ('Areia média', '${calc.areiaMediaTotal.ceil()} m³'),
      ('Pedra brita ou seixo', '${calc.pedraBritaOuSeixo.ceil()} m³'),
      (
        'Aditivo impermeabilizante',
        '${calc.aditivoImpermeabilizante.ceil()} L',
      ),
      ('Pneus inservíveis', '${calc.pneuInservivel} unid.'),
      ('Entulho/Pedras (limpo)', '${calc.entulhoPedras.ceil()} m³'),
      ('Terra preta/Substrato', '${calc.terraPretaSolo.ceil()} m³'),
      ('Mudas de bananeira', '${calc.mudaBananeira} unid.'),
      ('Adubo diverso', '${calc.aduboDiverso.ceil()} L'),
      ('Tubo PVC 100 mm (barra de 6 m)', '$barrasPVC100 unid.'),
      ('Tubo PVC 75 mm', '${calc.tuboEsgoto75} m'),
      ('Tubo PVC 40 mm', '${calc.tuboEsgoto40} m'),
      ('Tampão PVC 100 mm', '${calc.tampaoPVC100} unid.'),
      ('Tampão PVC 75 mm', '${calc.tampaoPVC75} unid.'),
      ('Luva de esgoto 100 mm', '${calc.luvaEsgoto100} unid.'),
      ('Tê PVC 100 mm', '${calc.tePVC100} unid.'),
    ];
  }

  static Future<void> gerarPDF(
    CalculosBET calc,
    double distanciaCasa,
    String nomeComunidade,
  ) async {
    final doc = pw.Document();
    final itens = _listaDeCompras(calc, distanciaCasa);
    final comunidade = nomeComunidade.trim();

    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('lib/img-utils/logo-bet.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      // A lista continua disponível caso a imagem não possa ser carregada.
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          if (logo != null) pw.Center(child: pw.Image(logo, height: 60)),
          pw.Center(
            child: pw.Text(
              'LISTA DE COMPRAS - PROJETO BET',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
          ),
          if (comunidade.isNotEmpty) pw.Center(child: pw.Text(comunidade)),
          pw.Divider(color: PdfColors.green800),
          for (final (material, quantidade) in itens)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: pw.Text(material)),
                  pw.Text(
                    quantidade,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'Lista_Compras_BET.pdf',
    );
  }

  static String gerarTextoCompartilhamento(
    CalculosBET calc,
    double distanciaCasa,
    String nomeComunidade,
  ) {
    final comunidade = nomeComunidade.trim();
    return [
      '*LISTA DE COMPRAS - PROJETO BET*',
      if (comunidade.isNotEmpty) comunidade,
      '',
      for (final (material, quantidade) in _listaDeCompras(calc, distanciaCasa))
        '[ ] $material: $quantidade',
    ].join('\n');
  }
}
