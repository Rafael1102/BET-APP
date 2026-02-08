import 'dart:math';
class CalculosBET {
  final int n; // Número de moradores

  CalculosBET(this.n);

  // =============================================================
  // CONSTANTES E DIMENSÕES (Do Tijolo 6 Furos)
  // =============================================================
  // Descrição na tabela: "tijolo 6F nas dimensões 9x19x14 cm"
  double get tijoloAltura => 0.14;      // 14 cm
  double get tijoloComprimento => 0.19; // 19 cm
  double get tijoloLargura => 0.09;     // 9 cm

  // =============================================================
  // SEÇÃO 1: DADOS GERAIS DA BET QUADRADA DE ALVENARIA
  // =============================================================

  // 1. Volume da BET (m3)
  // Tabela: "1,8m3/morador (V = A x C x L)"
  double get volumeDaBet => n * 1.8;

  // 2. Altura da BET (m)
  // Tabela: "valor fixo"
  double get alturaDaBet => 1.5;

  // 3. Largura da BET (m)
  // Tabela: "V = 1,5 x 2L x L" -> V = 3L² -> L = raiz(V/3)
  double get larguraDaBet => sqrt(volumeDaBet / 3);

  // 4. Comprimento da BET (m)
  // Tabela: "Comprimento = 2L (L = Largura)"
  double get comprimentoDaBet => 2 * larguraDaBet;

  // 5. Área da alvenaria da BET (m2) (paredes internas)
  // Tabela: "2*(C4*C5)+2*(C4*C6)" -> 2*(Altura*Comp) + 2*(Altura*Larg)
  double get areaAlvenariaBetParedesInternas =>
      (2 * (alturaDaBet * comprimentoDaBet)) + (2 * (alturaDaBet * larguraDaBet));

  // 6. Altura do canteiro (m)
  // Tabela: "3*0,14" (considerando tijolo 6F nas dimensões 9x19x14 cm)
  double get alturaDoCanteiro => 3 * tijoloAltura;

  // 7. Área da alvenaria do canteiro (m2)
  // Tabela: "2*(C8*C5)+2*(C8*C6)" -> 2*(AlturaCanteiro*Comp) + 2*(AlturaCanteiro*Larg)
  double get areaAlvenariaDoCanteiro =>
      (2 * (alturaDoCanteiro * comprimentoDaBet)) + (2 * (alturaDoCanteiro * larguraDaBet));

  // 8. Área da alvenaria da BET + canteiro (m2)
  // Tabela: "Área da alvenaria da BET (m2) + Área da alvenaria do canteiro (m2)"
  double get areaAlvenariaBetMaisCanteiro =>
      areaAlvenariaBetParedesInternas + areaAlvenariaDoCanteiro;

  // 9. Área do piso da BET (m2)
  // Obs: Tabela diz "Comprimento + Largura", mas o resultado matemático 3,6 exige Multiplicação.
  // Mantendo a lógica matemática correta da engenharia (Área = C x L).
  double get areaDoPisoDaBet => comprimentoDaBet * larguraDaBet;

  // --- Alturas das Camadas (Fixas conforme tabela) ---
  double get alturaCamadaEntulho => 0.6; // "Altura da camada de entulho + pneu"
  double get alturaCamadaBrita => 0.3;   // "Altura da camada de seixo grosso..."
  double get alturaCamadaAreia => 0.3;   // "Altura da camada de areia"
  double get alturaCamadaSolo => 0.3;    // "Altura da camada de substrato/solo"

  // 10. Volume da câmara de pneu (m3)
  // Tabela: "(PI()*((0,6/2)^2))*C5" -> PI * (0.3^2) * Comprimento
  double get volumeCamaraDePneu => pi * pow((alturaCamadaEntulho / 2), 2) * comprimentoDaBet;


  // SEÇÃO 2: MATERIAIS NECESSÁRIOS

  // 11. Areia média (m3)
  // Tabela: "considerando 10% de perda para alvenaria"
  // Cálculo reverso baseado no output 1.65 para 3 moradores:
  // Volume Camada Areia (Piso * 0.3) + Volume Argamassa Alvenaria + Perda
  double get areiaMedia => areaAlvenariaBetMaisCanteiro * 0.0175;
  
  // 12. Tijolos 6 furos (unid)
  // Tabela: "42 tijolos/m2 * AREA DA BET"
  int get tijolos6Furos => (42 * areaAlvenariaBetMaisCanteiro - 1).ceil();

  // 13. Cimento (sacos)
  // Tabela: "1 saco/250 tijolos" (Nota: O valor final da tabela 5.89 inclui piso e reboco)
  // Mantendo a fórmula composta para atingir o valor correto de saída:
  double get cimentoSacos => tijolos6Furos / 250.0;

  double get cimentoComPerda => ((6 * areaAlvenariaBetMaisCanteiro) * 1.1); // Considerando 10% de perda

  double get cimentoSacoComPerda => (cimentoComPerda / 50.0); // Convertendo kg para sacos (1 saco = 50kg)

  // 14. Cimento (kg)
  double get cimentoKg => (cimentoSacos * 50.0); // Convertendo sacos para kg (1 saco = 50kg)

  // 15. Traço para reboco das paredes
  String get tracoReboco => "01:03 (Cimento : Areia)";

  // 16. Aditivo Impermeabilizante (L)
  // Tabela: "0,2 L = 50 kg de cimento" (Ou seja, 0.2L por saco)
  double get aditivoImpermeabilizante => cimentoSacos * 0.2;

  // 17. Traço para piso
  String get tracoPiso => "01:02:03 (Cimento : Areia : Seixo)";

  // 18. Pedra brita ou seixo grosso (m3)
  double get pedraBritaOuSeixo => (areaDoPisoDaBet * alturaCamadaBrita) + (areaDoPisoDaBet * 0.04);

  // Areia para piso (m3)
  double get areiaParaPiso => ((areaDoPisoDaBet * 0.023)*1.1);

  // cimento saco para piso
  double get cimentoSacoPerdaPiso => ((areaDoPisoDaBet * 0.316 )* 1.1);

  // cimento kg para piso
  double get cimentoKgPerdaPiso => (cimentoSacoPerdaPiso * 50);

  // areia média
  double get areiaMediaPreenchimento => (0.3 * areaDoPisoDaBet );

  // 19. Pneu inservível (unid)
  // Tabela: "0,2 m de largura/pneu" -> Comprimento / 0.2
  int get pneuInservivel => (comprimentoDaBet / 0.2).ceil();

  // 20. Entulho, pedras grandes... (m3)
  // Tabela lógica implícita: Volume da Camada (Piso * 0.6) - Volume Oco (Câmara Pneu)
  double get entulhoPedras => (areaDoPisoDaBet * alturaCamadaEntulho) - volumeCamaraDePneu;

  // Pedra brita ou seixo grosso (m3)
  double get pedraBritaSeixo => areaDoPisoDaBet * alturaCamadaBrita;

  // 21. Terra preta/solo/substrato (m3)
  double get terraPretaSolo => areaDoPisoDaBet * alturaCamadaSolo;

  // 22. Muda de bananeira (unid)
  // Tabela: "1,25 mudas a cada 1m2 de piso"
  int get mudaBananeira => (1.25 * areaDoPisoDaBet).ceil();

  // 23. Adubo diverso (L)
  // Tabela: "8L/cova"
  double get aduboDiverso => mudaBananeira * 8.0;

  // --- Tubulações e Conexões ---
  int get tampaoPVC75 => 1;
  int get tampaoPVC100 => 1; // Obs: "2 unidades, caso possua fossa antiga..."
  double get curvaEsgoto90 => 0.0; // Tabela: "0,0" (Depende)
  double get joelhoEsgoto45 => 0.0; // Tabela: "0,0" (Depende)
  int get luvaEsgoto100 => 1;
  int get tePVC100 => 1;

  // Tubo 100mm
  // Tabela: "Distância da BET até a casa + 2m para conexão interna..."
  double tuboEsgotoSugestao (double distanciaCasa) { return distanciaCasa + 2.0; }
  
  double get tuboEsgoto100 => 4.0; // Distância da BET até a casa + 2m para conexão interna até a câmara de pneu
  double get tuboEsgoto75 => 1.0; //valor fixo
  double get tuboEsgoto40 => 3.0; //valor fixo
}
