//import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:app_bet/controller/calculadora_bet.dart';

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
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
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

            // 2. TRAÇOS
            buildSectionHeader(
              "2. Materiais necessários para a contrução e preenchimento da BET",
            ),
            buildItemRow(
              "Areia média considerando 10% de perda",
              "${calc.areiaMedia.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Cimento, considerando 10% de perda",
              "${calc.cimentoComPerda.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Cimento considerando tijolo 6 furos (9X19X14CM) e 10% de perda",
              "${calc.cimentoSacoComPerda.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Tijolo 6 furos considerando (9X19X14CM) ",
              "${calc.tijolos6Furos} unid.",
            ),
            buildItemRow(
              "Traço para reboco da paredes",
              calc.tracoReboco,
            ),
            buildItemRow(
              "Aditivo Impermeabilizante considerando 10% de perda",
              "${calc.aditivoImpermeabilizante.toStringAsFixed(2)} L",
            ),
            buildItemRow("Traço para piso", calc.tracoPiso),
            buildItemRow(
              "Pedra brita ou seixo grosso considerando 10% de perda",
              "${calc.pedraBritaOuSeixo.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Pneu inervivel, aro 13 a 16",
              "${calc.pneuInservivel} unid.",
            ),
            buildItemRow(
              "Entulho, pedras grandes, cacos, restos da construção",
              "${calc.entulhoPedras.toStringAsFixed(2)} m³",
            ),
            buildItemRow(
              "Terra preta/ Solo/ Substrato",
              "${calc.terraPretaSolo.toStringAsFixed(2)} m³",
            ),
            buildItemRow("Mudas de Bananeira", "${calc.mudaBananeira} unid."),
            buildItemRow(
              "Adubo Diverso",
              "${calc.aduboDiverso.toStringAsFixed(1)} L",
            ),

            // 4. TUBULAÇÃO
            buildSectionHeader("3. Tubulações de Esgoto"),
            buildItemRow(
              "Tubo PVC 100mm", "${calc.tuboEsgoto100(distanciaCasa).toStringAsFixed(1)} m",),
            buildItemRow(
              "Tubo PVC 75mm",
              "${calc.tuboEsgoto75.toStringAsFixed(1)} m",
            ),
            buildItemRow(
              "Tubo PVC 40mm",
              "${calc.tuboEsgoto40.toStringAsFixed(1)} m",
            ),
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
[ ] Cimento Total: ${calc.cimentoSacos.toStringAsFixed(1)} sacos (${calc.cimentoKg.toStringAsFixed(1)} kg)
[ ] Areia Média: ${calc.areiaMedia.toStringAsFixed(2)} m³
[ ] Pedra Brita/Seixo: ${calc.pedraBritaOuSeixo.toStringAsFixed(2)} m³
[ ] Aditivo Impermeabilizante: ${calc.aditivoImpermeabilizante.toStringAsFixed(2)} L

*2. PREENCHIMENTO E PAISAGISMO*
[ ] Pneus Inservíveis: ${calc.pneuInservivel} unid.
[ ] Entulho/Pedras (Limpo): ${calc.entulhoPedras.toStringAsFixed(2)} m³
[ ] Terra Preta/Substrato: ${calc.terraPretaSolo.toStringAsFixed(2)} m³
[ ] Mudas de Bananeira: ${calc.mudaBananeira} unid.
[ ] Adubo Diverso: ${calc.aduboDiverso.toStringAsFixed(1)} L

*3. TUBULAÇÃO DE ESGOTO*
[ ] Tubo PVC 100mm: ${calc.tuboEsgoto100(distanciaCasa).toStringAsFixed(1)} m
[ ] Tubo PVC 75mm: ${calc.tuboEsgoto75.toStringAsFixed(1)} m
[ ] Tubo PVC 40mm: ${calc.tuboEsgoto40.toStringAsFixed(1)} m
[ ] Tampão PVC 100mm: ${calc.tampaoPVC100} unid.
[ ] Tampão PVC 75mm: ${calc.tampaoPVC75} unid.

---------------------------------------
Gerado pelo BET APP
""";
  }
}
