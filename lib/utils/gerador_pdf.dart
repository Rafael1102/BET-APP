//import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:app_bet/controller/calculadora_bet.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class GeradorPDF {
  static Future<void> gerarPDF(CalculosBET calc, double distanciaCasa, String nomeComunidade) async {
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
      final ByteData bytes = await rootBundle.load('lib/img-utils/logo-bet.png');
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
            pw.Text(qtd, style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold)),
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
              if (logoImage != null)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Image(logoImage, height: 60),
                  ),
                ),
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (logoImage != null)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 10),
                            child: pw.Image(logoImage, width: 35, height: 35),
                          ),
                        pw.Text("PROJETO BET", style: titleStyle),
                      ],
                    ),
                    pw.Text("PROJETO BET", style: titleStyle),
                    pw.Text("Lista de Materiais", style: baseStyle),
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
            buildSectionHeader(
              "1. Dados Gerais da BET Quadrada de Alvenaria",
            ),
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
            buildSectionHeader("2. Materiais para construção das paredes da BET"),
            buildItemRow("Areia média", "${calc.areiaMedia.toStringAsFixed(2)} m³"),
            buildItemRow("Cimento", "${calc.cimentoKg.toStringAsFixed(2)} kg"),
            buildItemRow("Cimento", "${calc.cimentoSacos.toStringAsFixed(2)} sacos"),
            buildItemRow("Tijolo 6 furos", "${calc.tijolos6Furos} unid."),

            // 3. REBOCO
            buildSectionHeader("3. Materiais para reboco na parede da BET"),
            buildItemRow("Aditivo Impermeabilizante", "${calc.aditivoImpermeabilizante.toStringAsFixed(1)} L"),
            buildItemRow("Areia média", "${calc.areiaMedia.toStringAsFixed(3)} m³"),
            buildItemRow("Cimento", "${calc.cimentoComPerda.toStringAsFixed(2)} kg"),
            buildItemRow("Cimento", "${calc.cimentoSacoComPerda.toStringAsFixed(2)} sacos"),
            buildItemRow("Traço para reboco da paredes", calc.tracoReboco),

            // 4. PISO
            buildSectionHeader("4. Material para construção do piso da BET"),
            buildItemRow("Aditivo Impermeabilizante", "${calc.aditivoImpermeabilizante.toStringAsFixed(1)} L"),
            buildItemRow("Areia", "${calc.areiaParaPiso.toStringAsFixed(2)} m³"),
            buildItemRow("Cimento", "${calc.cimentoKgPerdaPiso} kg"),
            buildItemRow("Cimento", "${calc.cimentoSacoPerdaPiso} sacos"),
            buildItemRow("Pedra Brita/Seixo", "${calc.pedraBritaOuSeixo.toStringAsFixed(2)} m³"),
            buildItemRow("Traço para piso", calc.tracoPiso),

            // 5. PREENCHIMENTO
            buildSectionHeader("5. Material para preenchimento da BET de alvenaria"),
            buildItemRow("Pneu inservível", "${calc.pneuInservivel} unid."),
            buildItemRow("Entulho/Pedras (Limpo)", "${calc.entulhoPedras.toStringAsFixed(2)} m³"),
            buildItemRow("Pedra brita ou seixo grosso", "${calc.pedraBritaSeixo.toStringAsFixed(1)} m³"),
            buildItemRow("Areia Média", "${calc.areiaMediaPreenchimento.toStringAsFixed(1)} m³"),
            buildItemRow("Terra preta/Solo", "${calc.terraPretaSolo.toStringAsFixed(2)} m³"),
            buildItemRow("Mudas de Bananeira", "${calc.mudaBananeira} unid."),
            buildItemRow("Adubo Diverso", "${calc.aduboDiverso} L"),

            // 6. TUBULAÇÃO
            buildSectionHeader("6. Tubulações de Esgoto"),
            buildItemRow("Tubo PVC 100mm", "${calc.tuboEsgoto100(distanciaCasa).toStringAsFixed(1)} m (${calc.tuboEsgoto100Barras(distanciaCasa)} barras)"),
            buildItemRow("Tubo PVC 75mm", "${calc.tuboEsgoto75} m"),
            buildItemRow("Tubo PVC 40mm", "${calc.tuboEsgoto40} m"),
            buildItemRow("Tampão PVC 100mm", "${calc.tampaoPVC100} unid."),
            buildItemRow("Tampão PVC 75mm", "${calc.tampaoPVC75} unid."),
            buildItemRow(
              "Curva Esgoto 90º de 100mm",
              "Depende da instalação local",
            ),
            buildItemRow("Joelho Esgoto 45º diâmetro 100mm", "Depende da instalação local"),
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
                  
                  pw.Text("1. CONSTRUÇÃO E ALVENARIA", style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  buildChecklistItem("Tijolos 6 furos", "${calc.tijolos6Furos} unid."),
                  buildChecklistItem("Cimento Total", "${(calc.cimentoSacos + calc.cimentoSacoComPerda + calc.cimentoSacoPerdaPiso).toStringAsFixed(2)} sacos"),
                  buildChecklistItem("Areia Média", "${calc.areiaMedia.toStringAsFixed(2)} m³"),
                  buildChecklistItem("Pedra Brita/Seixo", "${calc.pedraBritaOuSeixo.toStringAsFixed(2)} m³"),
                  buildChecklistItem("Aditivo Impermeabilizante", "${calc.aditivoImpermeabilizante.toStringAsFixed(1)} L"),
                  pw.SizedBox(height: 12),
                  
                  pw.Text("2. PREENCHIMENTO E PAISAGISMO", style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  buildChecklistItem("Pneus Inservíveis", "${calc.pneuInservivel} unid."),
                  buildChecklistItem("Entulho/Pedras (Limpo)", "${calc.entulhoPedras.toStringAsFixed(2)} m³"),
                  buildChecklistItem("Terra Preta/Substrato", "${calc.terraPretaSolo.toStringAsFixed(2)} m³"),
                  buildChecklistItem("Mudas de Bananeira", "${calc.mudaBananeira} unid."),
                  buildChecklistItem("Adubo Diverso", "${calc.aduboDiverso} L"),
                  pw.SizedBox(height: 12),

                  pw.Text("3. TUBULAÇÃO DE ESGOTO", style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  buildChecklistItem("Tubo PVC 100mm", "${calc.tuboEsgoto100(distanciaCasa).toStringAsFixed(1)} m (${calc.tuboEsgoto100Barras(distanciaCasa)} barras)"),
                  buildChecklistItem("Tubo PVC 75mm", "${calc.tuboEsgoto75} m"),
                  buildChecklistItem("Tubo PVC 40mm", "${calc.tuboEsgoto40} m"),
                  buildChecklistItem("Tampão PVC 100mm", "${calc.tampaoPVC100} unid."),
                  buildChecklistItem("Tampão PVC 75mm", "${calc.tampaoPVC75} unid."),
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
    CalculosBET calc, double distanciaCasa, String nomeComunidade) {
    return """
*LISTA DE MATERIAIS - PROJETO BET*
---------------------------------------
*DADOS DO PROJETO:*
- Moradores: ${calc.n}
- Volume da BET: ${calc.volumeDaBet.toStringAsFixed(2)} m³
---------------------------------------

*1. CONSTRUÇÃO E ALVENARIA*
[ ] Tijolos 6 furos: ${calc.tijolos6Furos} unid.
[ ] Cimento (Paredes): ${calc.cimentoSacos.toStringAsFixed(2)} sacos (${calc.cimentoKg.toStringAsFixed(2)} kg)
[ ] Cimento (Reboco): ${calc.cimentoSacoComPerda.toStringAsFixed(2)} sacos (${calc.cimentoComPerda.toStringAsFixed(2)} kg)
[ ] Cimento (Piso): ${calc.cimentoSacoPerdaPiso} sacos (${calc.cimentoKgPerdaPiso} kg)
[ ] Cimento Total: ${(calc.cimentoSacos + calc.cimentoSacoComPerda + calc.cimentoSacoPerdaPiso).toStringAsFixed(2)} sacos
[ ] Areia Média: ${calc.areiaMedia.toStringAsFixed(2)} m³
[ ] Pedra Brita/Seixo: ${calc.pedraBritaOuSeixo.toStringAsFixed(2)} m³
[ ] Aditivo Impermeabilizante: ${calc.aditivoImpermeabilizante.toStringAsFixed(2)} L

*2. PREENCHIMENTO E PAISAGISMO*
[ ] Pneus Inservíveis: ${calc.pneuInservivel} unid.
[ ] Entulho/Pedras (Limpo): ${calc.entulhoPedras.toStringAsFixed(2)} m³
[ ] Terra Preta/Substrato: ${calc.terraPretaSolo.toStringAsFixed(2)} m³
[ ] Mudas de Bananeira: ${calc.mudaBananeira} unid.
[ ] Adubo Diverso: ${calc.aduboDiverso} L

*3. TUBULAÇÃO DE ESGOTO*
[ ] Tubo PVC 100mm: ${calc.tuboEsgoto100(distanciaCasa).toStringAsFixed(1)} m (${calc.tuboEsgoto100Barras(distanciaCasa)} barras)
[ ] Tubo PVC 75mm: ${calc.tuboEsgoto75} m
[ ] Tubo PVC 40mm: ${calc.tuboEsgoto40} m
[ ] Tampão PVC 100mm: ${calc.tampaoPVC100} unid.
[ ] Tampão PVC 75mm: ${calc.tampaoPVC75} unid.

---------------------------------------
Gerado pelo BET APP
""";
  }
}
