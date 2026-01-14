// ... imports ...
import 'package:flutter/material.dart';

import 'controller/calculadora_bet.dart'; // Importe o arquivo acima

class ResultadosPage extends StatelessWidget {
  final int moradores;
  final bool temAgua;
  final double distancia; // ADICIONADO: Precisamos da distância para o tubo
  // Widget auxiliar para criar os cabeçalhos verdes das seções
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity, // Garante que a barra verde ocupe toda a largura
      margin: const EdgeInsets.only(top: 20, bottom: 10), // Espaço acima e abaixo
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green, // Fundo verde da identidade visual
        borderRadius: BorderRadius.circular(4), // Bordas levemente arredondadas
      ),
      child: Text(
        title.toUpperCase(), // Transforma o texto em MAIÚSCULO
        style: const TextStyle(
          color: Colors.white, // Texto branco para contrastar
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  const ResultadosPage({
    super.key, 
    required this.moradores, 
    required this.temAgua,
    required this.distancia,
  });

  @override
  Widget build(BuildContext context) {
    final calc = CalculosBET(moradores);
    
    // ... (Definição de cores igual anterior) ...

    return Scaffold(
      // ... AppBar ...
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ... Cabeçalho do Resultado (Igual anterior) ...

            // SEÇÃO 1: DADOS GERAIS
            _buildSectionHeader("Dados Gerais da BET"),
            _buildResultRow("Volume da BET", "${calc.volumeBet.toStringAsFixed(2)} m³"),
            _buildResultRow("Comprimento", "${calc.comprimento.toStringAsFixed(2)} m"),
            _buildResultRow("Largura", "${calc.largura.toStringAsFixed(2)} m"),
            _buildResultRow("Área de Alvenaria (Total)", "${calc.areaAlvenariaTotal.toStringAsFixed(2)} m²"),
            _buildResultRow("Área do Piso", "${calc.areaPiso.toStringAsFixed(2)} m²"),

            const SizedBox(height: 20),

            // SEÇÃO 2: MATERIAIS
            _buildSectionHeader("Materiais Necessários"),
            
            _buildResultRow("Tijolos (6 furos)", "${calc.tijolos} unid."),
            _buildResultRow("Cimento", "${calc.cimentoSacos.toStringAsFixed(1)} sacos"),
            _buildResultRow("Areia Média", "${calc.areia.toStringAsFixed(2)} m³"),
            _buildResultRow("Brita/Seixo", "${calc.brita.toStringAsFixed(2)} m³"),
            _buildResultRow("Aditivo Impermeabilizante", "${calc.aditivo.toStringAsFixed(2)} L"),
            
            _buildResultRow("Pneus (Aro 13 a 16)", "${calc.pneus} unid."),
            
            _buildResultRow("Entulho/Pedras", "${calc.entulho.toStringAsFixed(2)} m³", 
              obs: "Coletar material limpo, sem terra."), // OBSERVAÇÃO AQUI
            
            _buildResultRow("Terra Preta", "${calc.terraPreta.toStringAsFixed(2)} m³"),
            _buildResultRow("Mudas de Bananeira", "${calc.mudasBananeira} unid."),
            _buildResultRow("Adubo", "${calc.adubo.toStringAsFixed(1)} L"),

            const SizedBox(height: 20),

            // SEÇÃO 3: TUBULAÇÃO
            _buildSectionHeader("Tubulações e Conexões"),
            _buildResultRow("Tubo PVC 100mm", "${calc.tubo100(distancia).toStringAsFixed(1)} m"),
            _buildResultRow("Tampão PVC 100mm", "${calc.tampao100} unid.", 
               obs: "2 unid. caso possua fossa antiga para desativar."),
            _buildResultRow("Luva PVC 100mm", "${calc.luva100} unid.", obs: "Pode variar conforme instalação."),
            _buildResultRow("Tê PVC 100mm", "${calc.tePVC100} unid."),

            // ... Adicionar botão voltar ...
          ],
        ),
      ),
    );
  }

  // Atualizei o widget de linha para aceitar Observações
  Widget _buildResultRow(String label, String value, {String? obs}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          if (obs != null) ...[ // Só mostra se tiver observação
            const SizedBox(height: 4),
            Text(
              "Obs: $obs",
              style: TextStyle(fontSize: 13, color: Colors.orange[800], fontStyle: FontStyle.italic),
            ),
          ]
        ],
      ),
    );
  }
}