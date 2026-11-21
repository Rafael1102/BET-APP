import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:app_bet/controller/calculadora_bet.dart';
import 'package:flutter/services.dart' show rootBundle;

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

    // Define o estilo base
    final baseStyle = pw.TextStyle(fontSize: 12);
    final titleStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green900,
    );
    final headerStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    // Carrega a logo
    pw.MemoryImage? logoImage;
    try {
      final bytes = await rootBundle.load(
        'lib/img-utils/logo-bet.png',
      );
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      // Continua sem a logo caso não encontre o arquivo
    }

    // Função auxiliar para criar linhas da tabela
    pw.Widget buildItemRow(String item, String qtd) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(item, style: baseStyle),
            pw.Text(
              qtd,
              style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Função auxiliar para criar item com checkbox para a lista de compras
    pw.Widget buildChecklistItem(String item, String qtd) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          children: [
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(child: pw.Text(item, style: baseStyle)),
            pw.Text(
              qtd,
              style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Função para criar cabeçalhos de seção (Faixa verde)
    pw.Widget buildSectionHeader(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 15, bottom: 5),
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        color: PdfColors.green800,
        width: double.infinity,
        child: pw.Text(title.toUpperCase(), style: headerStyle),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        // --- CABEÇALHO ---
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Expanded(
                      child: pw.SizedBox(),
                    ), // Espaço vazio na esquerda para equilibrar
                    pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        if (logoImage != null)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 8),
                            child: pw.Image(logoImage, height: 60),
                          ),
                        pw.Text("PROJETO BET", style: titleStyle),
                      ],
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.bottomRight,
                        child: pw.Text("Lista de Materiais", style: baseStyle),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Comunidade/Local: ${nomeComunidade.isEmpty ? "Não informado" : nomeComunidade}",
                style: baseStyle,
              ),
              pw.Text(
                "Moradores: ${calc.n} | Volume da BET: ${calc.volumeDaBet.toStringAsFixed(2)} m³",
              ),
              pw.Divider(color: PdfColors.green),
            ],
          );
        },

        // --- RODAPÉ ---
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Gerado pelo Aplicativo BET",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                "Página ${context.pageNumber} de ${context.pagesCount}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },

        // --- CORPO DO DOCUMENTO  ---
        build: (pw.Context context) {
          return [
            // 1. CONSTRUÇÃO
            buildSectionHeader("1. Dados Gerais da BET Quadrada de Alvenaria"),
            buildItemRow(
              "Volume da BET",
              "${calc.volumeDaBet.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Altura da Bet",
              "${calc.alturaDaBet.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Comprimento da Bet",
              "${calc.comprimentoDaBet.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Largura da Bet",
              "${calc.larguraDaBet.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Área da Alvenaria da BET paredes internas",
              "${calc.areaAlvenariaBetParedesInternas.toStringAsFixed(2)} m²",
            ),
            buildItemRow(
              "Altura do canteiro",
              "${calc.alturaDoCanteiro.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Área da alvenaria do canteiro",
              "${calc.areaAlvenariaDoCanteiro.toStringAsFixed(2)} m²",
            ),
            buildItemRow(
              "Área da alvenaria da BET + canteiro",
              "${calc.areaAlvenariaBetMaisCanteiro.toStringAsFixed(2)} m²",
            ),
            buildItemRow(
              "Área do piso da BET",
              "${calc.areaDoPisoDaBet.toStringAsFixed(2)} m²",
            ),
            buildItemRow(
              "Altura de camada de entulho",
              "${calc.alturaCamadaEntulho.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Altura da camada de seixo ou brita",
              "${calc.alturaCamadaBrita.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Altura da camada de areia",
              "${calc.alturaCamadaAreia.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Altura da camada de solo",
              "${calc.alturaCamadaSolo.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Volume da câmara de pneu",
              "${calc.volumeCamaraDePneu.toStringAsFixed(2)} m³",
            ),

            // 2. PAREDES
            buildSectionHeader(
              "2. Materiais para construção das paredes da BET",
            ),
            buildItemRow(
              "Areia média",
              "${calc.areiaMedia.toStringAsFixed(2)} m³",
            ),
            buildItemRow("Cimento", "${calc.cimentoKg.toStringAsFixed(2)} kg"),
            buildItemRow(
              "Cimento",
              "${calc.cimentoSacos.toStringAsFixed(2)} sacos",
            ),
            buildItemRow("Tijolo 6 furos", "${calc.tijolos6Furos} unid."),

            // 3. REBOCO
            buildSectionHeader("3. Materiais para reboco na parede da BET"),
            buildItemRow(
              "Aditivo Impermeabilizante",
              "${calc.aditivoImpermeabilizanteReboco.toStringAsFixed(2)} L",
            ),
            buildItemRow(
              "Areia média",
              "${calc.areiaMediaReboco.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Cimento",
              "${calc.cimentoComPerda.toStringAsFixed(2)} kg",
            ),
            buildItemRow(
              "Cimento",
              "${calc.cimentoSacoComPerda.toStringAsFixed(2)} sacos",
            ),
            buildItemRow("Traço para reboco da paredes", calc.tracoReboco),

            // 4. PISO
            buildSectionHeader("4. Material para construção do piso da BET"),
            buildItemRow(
              "Aditivo Impermeabilizante",
              "${calc.aditivoImpermeabilizantePiso.toStringAsFixed(2)} L",
            ),
            buildItemRow(
              "Areia média",
              "${calc.areiaParaPiso.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Cimento",
              "${calc.cimentoKgPerdaPiso.toStringAsFixed(2)} kg",
            ),
            buildItemRow(
              "Cimento",
              "${calc.cimentoSacoPerdaPiso.toStringAsFixed(2)} sacos",
            ),
            buildItemRow(
              "Pedra Brita/Seixo",
              "${calc.pedraBritaOuSeixoPiso.toStringAsFixed(2)} m³",
            ),
            buildItemRow("Traço para piso", calc.tracoPiso),

            // 5. PREENCHIMENTO
            buildSectionHeader(
              "5. Material para preenchimento da BET de alvenaria",
            ),
            buildItemRow("Pneu inservível", "${calc.pneuInservivel} unid."),
            buildItemRow(
              "Entulho/Pedras (Limpo)",
              "${calc.entulhoPedras.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Pedra brita ou seixo grosso",
              "${calc.pedraBritaSeixo.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Areia Média",
              "${calc.areiaMediaPreenchimento.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Terra preta/Solo",
              "${calc.terraPretaSolo.toStringAsFixed(2)} m³",
            ),
            buildItemRow("Mudas de Bananeira", "${calc.mudaBananeira} unid."),
            buildItemRow("Adubo Diverso", "${calc.aduboDiverso.ceil()} L"),

            // 6. TUBULAÇÃO
            buildSectionHeader("6. Tubulações de Esgoto"),
            buildItemRow(
              "Tubo PVC 100mm",
              "${calc.tuboEsgoto100(distanciaCasa).toStringAsFixed(1)} m (${calc.tuboEsgoto100Barras(distanciaCasa)} varas)",
            ),
            buildItemRow("Tubo PVC 75mm", "${calc.tuboEsgoto75} m"),
            buildItemRow("Tubo PVC 40mm", "${calc.tuboEsgoto40} m"),
            buildItemRow("Tampão PVC 100mm", "${calc.tampaoPVC100} unid."),
            buildItemRow("Tampão PVC 75mm", "${calc.tampaoPVC75} unid."),
            buildItemRow(
              "Curva Esgoto 90º de 100mm",
              "Depende da instalação local",
            ),
            buildItemRow(
              "Joelho Esgoto 45º diâmetro 100mm",
              "Depende da instalação local",
            ),
            buildItemRow("Luva Esgoto 100mm", "${calc.luvaEsgoto100} unid."),
            buildItemRow("Tê PVC 100mm", "${calc.tePVC100} unid."),

            pw.SizedBox(height: 5),
            pw.Text(
              "*Adquirir conexões (Luvas, Tês, Joelhos) conforme a instalação local.",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
            ),

            // --- LISTA DE COMPRAS (RESUMO) ---
            pw.SizedBox(height: 30),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.green800, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      "LISTA DE COMPRAS (RESUMO)",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 15),

                  pw.Text(
                    "1. CONSTRUÇÃO E ALVENARIA",
                    style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  buildChecklistItem(
                    "Tijolos 6 furos",
                    "${calc.tijolos6Furos} unid.",
                  ),
                  buildChecklistItem(
                    "Cimento Total",
                    "${calc.cimentoSacosTotal} sacos de 50 kg",
                  ),
                  buildChecklistItem(
                    "Areia Total",
                    "${calc.areiaMediaTotal.ceil()} m³",
                  ),
                  buildChecklistItem(
                    "Pedra Brita/Seixo",
                    "${calc.pedraBritaOuSeixo.ceil()} m³",
                  ),
                  buildChecklistItem(
                    "Aditivo Impermeabilizante",
                    "${calc.aditivoImpermeabilizante.ceil()} L",
                  ),
                  pw.SizedBox(height: 12),

                  pw.Text(
                    "2. PREENCHIMENTO E PAISAGISMO",
                    style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  buildChecklistItem(
                    "Pneus Inservíveis",
                    "${calc.pneuInservivel} unid.",
                  ),
                  buildChecklistItem(
                    "Entulho/Pedras (Limpo)",
                    "${calc.entulhoPedras.ceil()} m³",
                  ),
                  buildChecklistItem(
                    "Terra Preta/Substrato",
                    "${calc.terraPretaSolo.ceil()} m³",
                  ),
                  buildChecklistItem(
                    "Mudas de Bananeira",
                    "${calc.mudaBananeira} unid.",
                  ),
                  buildChecklistItem(
                    "Adubo Diverso",
                    "${calc.aduboDiverso.ceil()} L",
                  ),
                  pw.SizedBox(height: 12),

                  pw.Text(
                    "3. TUBULAÇÃO DE ESGOTO",
                    style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  buildChecklistItem(
                    "Tubo PVC 100mm",
                    "${calc.tuboEsgoto100(distanciaCasa).toStringAsFixed(1)} m (${calc.tuboEsgoto100Barras(distanciaCasa)} varas)",
                  ),
                  buildChecklistItem("Tubo PVC 75mm", "${calc.tuboEsgoto75} m"),
                  buildChecklistItem("Tubo PVC 40mm", "${calc.tuboEsgoto40} m"),
                  buildChecklistItem(
                    "Tampão PVC 100mm",
                    "${calc.tampaoPVC100} unid.",
                  ),
                  buildChecklistItem(
                    "Tampão PVC 75mm",
                    "${calc.tampaoPVC75} unid.",
                  ),
                  buildChecklistItem(
                    "Luva Esgoto 100mm",
                    "${calc.luvaEsgoto100} unid.",
                  ),
                  buildChecklistItem("Tê PVC 100mm", "${calc.tePVC100} unid."),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    "* Valores marcados como 'Total' representam a soma de todas as etapas da obra (construção, reboco, piso e preenchimento). Quantidades de compra arredondadas para cima.",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Lista_Materiais_BET.pdf',
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
