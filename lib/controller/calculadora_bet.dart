import 'dart:math';

/// Classe responsável por toda a lógica matemática do Projeto BET.
class CalculosBET {
  final int n; // Número de moradores

  CalculosBET(this.n);

  // SEÇÃO 1: DADOS GERAIS (GEOMETRIA E DIMENSÕES)
  
  // Volume Total (m³) - Fórmula: 1.8m³/morador
  double get volumeBet => n * 1.8;

  // Altura da BET (m) - Valor Fixo
  double get alturaBet => 1.5;

  // Largura (m) - Derivada da fórmula V = 1.5 * 2L * L  => L = sqrt(V/3)
  double get largura => sqrt(volumeBet / 3);

  // Comprimento (m) - Fórmula: 2 * Largura
  double get comprimento => 2 * largura;

  // Área da Alvenaria da BET (Paredes Internas) (m²)
  double get areaAlvenariaInterna => (2 * (alturaBet * comprimento)) + (2 * (alturaBet * largura));

  // Altura do Canteiro (m)
  double get alturaCanteiro => 3 * 0.14; 

  // Área da Alvenaria do Canteiro (m²)
  double get _areaAlvenariaCanteiro => (2 * (alturaCanteiro * comprimento)) + (2 * (alturaCanteiro * largura));

  // Área TOTAL da Alvenaria (BET + Canteiro) (m²)
  double get areaAlvenariaTotal => areaAlvenariaInterna + _areaAlvenariaCanteiro;

  // Área do Piso (m²)
  double get areaPiso => comprimento * largura;

  // Volumes das Camadas
  double get alturaEntulho => 0.6;
  double get alturaBrita => 0.3;
  double get alturaAreia => 0.3;
  double get alturaSolo => 0.3;

  // Volume da Câmara de Pneu
  double get _volumeCamaraPneu => pi * pow((alturaEntulho / 2), 2) * comprimento;


  // =============================================================
  // SEÇÃO 2: MATERIAIS NECESSÁRIOS
  // =============================================================

  // Tijolos 6 furos (unid)
  int get tijolos => (42 * areaAlvenariaTotal).ceil();

  // Cimento (Sacos)
  double get cimentoSacos {
    double sacosAssentamento = tijolos / 250;
    double sacosRebocoPiso = areaAlvenariaTotal * 0.21; 
    return sacosAssentamento + sacosRebocoPiso;
  }

  // Cimento (kg)
  double get cimentoKg => cimentoSacos * 50.0;

  // Areia Média (m³)
  double get areia => (areaPiso * alturaAreia) + (areaPiso * 0.16);

  // Pedra Brita ou Seixo (m³)
  double get brita => (areaPiso * alturaBrita) + (areaPiso * 0.04);

  // Aditivo Impermeabilizante (L)
  double get aditivo => cimentoSacos * 0.2;

  // Pneu Inservível (unid)
  int get pneus => (comprimento / 0.2).ceil();

  // Entulho (m³)
  double get entulho => (areaPiso * alturaEntulho) - _volumeCamaraPneu;

  // Terra Preta (m³)
  double get terraPreta => areaPiso * alturaSolo;

  // Mudas de Bananeira (unid)
  int get mudasBananeira => (1.25 * areaPiso).ceil();

  // Adubo (L)
  double get adubo => mudasBananeira * 8.0;

  // Tubulações e Conexões
  int get tampao75 => 1;
  int get tampao100 => 1;
  int get luva100 => 1;
  int get tePVC100 => 1;
  double get tubo75 => 1.0;
  double get tubo40 => 3.0;
  
  // Tubo 100mm: Distância da casa + 2m internos
  double tubo100(double distanciaCasa) => distanciaCasa + 2.0; 
}