import 'package:flutter/material.dart';
import 'package:app_bet/controller/calculadora_bet.dart';

void main() => runApp(const ProjetoBET());

class ProjetoBET extends StatelessWidget {
  const ProjetoBET({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BET',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceAtual = 0; // Controla qual aba está visível

  // Controladores de texto
  final _moradoresController = TextEditingController();
  final _distanciaController = TextEditingController();

  bool? _temAgua;
  bool _calculoRealizado = false; 

  Widget _buildMenuExpansivo({
    required String titulo,
    required List<Widget> itens,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.green[50], // Fundo verdinho padrão
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green.shade200), // Borda verde
        ),
        child: Theme(
          // Remove a linha divisória padrão do Flutter
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(Icons.info_outline, color: Colors.green[800]),
            iconColor: Colors.green[800],
            collapsedIconColor: Colors.green[800],
            title: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  children: [
                    const Divider(), // Uma linha fina para separar o título
                    ...itens, // O operador "..." espalha a lista aqui dentro
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DO BOTÃO FLUTUANTE ---
  void _realizarCalculo() {
    FocusScope.of(context).unfocus(); // Esconde teclado

    // Validação: Verifica se o campo está vazio OU se a água é nula
    if (_moradoresController.text.isEmpty || _temAgua == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os moradores e a condição do solo!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? moradores = int.tryParse(_moradoresController.text);
    if (moradores == null || moradores > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Máximo de 8 moradores permitido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {_calculoRealizado = true;
      _indiceAtual = 1; // Vai para a aba de relatório
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> telas = [_buildAbaFormulario(), _buildAbaRelatorio()];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _indiceAtual == 0 ? "Coleta de Dados" : "Relatório Técnico",
        ),
      ),
      // IndexedStack preserva os dados digitados ao trocar de aba
      body: IndexedStack(index: _indiceAtual, children: telas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual,
        onDestinationSelected: (index) {
          setState(() {
            _indiceAtual = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Coleta'),
          NavigationDestination(
            icon: Icon(Icons.assessment),
            label: 'Relatório',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _indiceAtual == 0
        ? FloatingActionButton.extended(
        onPressed: _realizarCalculo,
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calculate),
        label: const Text("CALCULAR"),
       )
       : null,
    );
   }

  // --- CONSTRUÇÃO DA ABA DE FORMULÁRIO ---
  Widget _buildAbaFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildCardInput(
            title: "Dados da Família",
            child: Column(
              children: [
                TextField(
                  controller: _moradoresController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Número de moradores (Max 8)",
                    prefixIcon: Icon(Icons.people),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _distanciaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Distância da casa (metros)",
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                    helperText: "Necessário para calcular tubulação",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), _buildCardInput(
            title: "Análise do Solo",
            child: Column(
              children: [
                const Text(
                  "Ao escavar o solo a 1,5m, há aparecimento de água?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RadioListTile<bool>(
                  title: const Text("Sim (Lençol Freático Alto)"),
                  value: true,
                  // ignore: deprecated_member_use
                  groupValue: _temAgua,
                  // ignore: deprecated_member_use
                  onChanged: (val) => setState(() => _temAgua = val),),
                RadioListTile<bool>(
                  title: const Text("Não (Solo Seco)"),
                  value: false,
                  // ignore: deprecated_member_use
                  groupValue: _temAgua,
                  // ignore: deprecated_member_use
                  onChanged: (val) => setState(() => _temAgua = val),),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Pressione o botão 'Calcular' abaixo para ver o relatório.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONSTRUÇÃO DA ABA DE RELATÓRIO ---
  Widget _buildAbaRelatorio() {
    if (!_calculoRealizado) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              "Nenhum cálculo realizado ainda.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Text("Preencha a aba 'Coleta' primeiro."),
          ],
        ),
      );
    }

    int moradores = int.tryParse(_moradoresController.text) ?? 0;
    double distancia = double.tryParse(_distanciaController.text) ?? 4.0;

    final calc = CalculosBET(moradores);

    final bool alvenariaSuspensa = _temAgua ?? false;
    final String tituloFossa = alvenariaSuspensa
        ? "ALVENARIA SUSPENSA"
        : "ALVENARIA ESCAVADA";
    final Color corDestaque = alvenariaSuspensa
        ? Colors.orange[800]!
        : Colors.green[800]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de Resultado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: alvenariaSuspensa ? Colors.orange[50] : Colors.green[50],
              border: Border.all(color: corDestaque, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  "RECOMENDAÇÃO TÉCNICA",
                  style: TextStyle(
                    color: corDestaque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tituloFossa,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: corDestaque,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // SEÇÃO 1: DADOS GERAIS
          _buildSectionHeader("Dados Gerais da BET"),
          _buildRow("Volume da BET","${calc.volumeDaBet.toStringAsFixed(1)} m³", ),
          _buildRow("Altura da BET","${calc.alturaDaBet.toStringAsFixed(1)} m",  ),
          _buildRow("Comprimento da BET","${calc.comprimentoDaBet.toStringAsFixed(2)} m",),
          _buildRow("Largura da BET","${calc.larguraDaBet.toStringAsFixed(2)} m",),
          _buildRow("Área alvenaria BET + canteiro","${calc.areaAlvenariaBetMaisCanteiro.toStringAsFixed(1)} m²",),

          // (Lista Expansora)
          _buildMenuExpansivo(
            titulo: "Ver Detalhes Geométricos",
            itens: [
              _buildRow("Área alvenaria BET (paredes int.)","${calc.areaAlvenariaBetParedesInternas.toStringAsFixed(1)} m²",),
              _buildRow("Altura do canteiro","${calc.alturaDoCanteiro.toStringAsFixed(1)} m",),
              _buildRow("Área alvenaria do canteiro","${calc.areaAlvenariaDoCanteiro.toStringAsFixed(1)} m²",),
              _buildRow("Área do piso da BET","${calc.areaDoPisoDaBet.toStringAsFixed(1)} m²",),
              _buildRow("Alt. da camada de entulho/pneu ","${calc.alturaCamadaEntulho.toStringAsFixed(2)} m²",),
              _buildRow("Alt. da camada de seixo grosso ou pedra brita","${calc.alturaCamadaBrita.toStringAsFixed(2)} m²",),
              _buildRow("Alt. da camada de areia","${calc.alturaCamadaAreia.toStringAsFixed(2)} m²",),
              _buildRow("Alt. da camada de substrato/solo","${calc.alturaCamadaSolo.toStringAsFixed(2)} m²",),
              _buildRow("Volume da câmara de pneu","${calc.volumeCamaraDePneu.toStringAsFixed(3)} m³",),
            ],
          ),

          // SEÇÃO 2: MATERIAIS
          _buildSectionHeader("Construção das paredes da BET"),
          _buildRow("Areia Média", "${calc.areiaMedia.toStringAsFixed(2)} m³"),
          _buildRow("Cimento (Kg)", "${calc.cimentoKg.toStringAsFixed(2)} kg"),
          _buildRow("Cimento (Sacos)","${calc.cimentoSacos.toStringAsFixed(2)} sacos",),
          _buildRow("Tijolos 6 furos", "${calc.tijolos6Furos} unid."),

          // SEÇÃO 3: MATERIAIS DA PAREDE
          _buildSectionHeader("Para reboco na parede da BET"),

          // LISTA EXPANSORA
          _buildRow("Traço", calc.tracoReboco),
          _buildMenuExpansivo(
            titulo: "Considerado 10% de perda",
            itens: [
              _buildRow(
                "Aditivo Impermeabilizante",
                "${calc.aditivoImpermeabilizante.toStringAsFixed(1)} L",
              ),
              _buildRow(
                "Areia média",
                "${calc.areiaMedia.toStringAsFixed(3)} m³",
              ),
              _buildRow(
                "Cimento (Kg)",
                "${calc.cimentoComPerda.toStringAsFixed(2)} kg",
              ),
              _buildRow(
                "Cimento (Sacos)",
                "${(calc.cimentoSacoComPerda).toStringAsFixed(2)} sacos",
              ),
            ],
          ),

          // SEÇÃO 4: MATERIAIS DO PISO
          _buildSectionHeader("Para construção do piso da BET"),
          _buildRow("Traço", calc.tracoPiso),

          // LISTA EXPANSORA
          _buildMenuExpansivo(
            titulo: "Considerado 10% de perda",
            itens: [
              _buildRow(
                "Aditivo Impermeabilizante",
                "${calc.aditivoImpermeabilizante.toStringAsFixed(1)} L",
              ),
              _buildRow("Areia", "${calc.areiaParaPiso.toStringAsFixed(2)} m³"),
              _buildRow(
                "Cimento (kg)",
                "${calc.cimentoKgPerdaPiso.toStringAsFixed(2)} kg",
              ),
              _buildRow(
                "Cimento (sacos)",
                "${calc.cimentoSacoPerdaPiso.toStringAsFixed(2)} sacos",
              ),
              _buildRow(
                "Pedra Brita/Seixo",
                "${calc.pedraBritaOuSeixo.toStringAsFixed(2)} m³",
              ),
            ],
          ),
          // SEÇÃO 5: MATERIAIS PARA PREENCHIMENTO
          _buildSectionHeader("Para preenchimento da BET de alvenaria"),
          _buildRow("Pneu Inservível", "${calc.pneuInservivel} unid."),
          _buildRow(
            "Entulho/Pedras",
            "${calc.entulhoPedras.toStringAsFixed(2)} m³",
            obs: "Material limpo,  Sem resíduos de terra ou outros materiais.",
          ),

          _buildRow(
            "Pedra brita ou seixo grosso",
            "${calc.terraPretaSolo.toStringAsFixed(1)} m³",
          ),
          _buildRow(
            "Areia Média",
            "${calc.areiaMediaPreenchimento.toStringAsFixed(1)} m³",
          ),
          _buildRow(
            "Terra Preta/Solo",
            "${calc.terraPretaSolo.toStringAsFixed(1)} m³",
          ),
          _buildRow("Mudas Bananeira", "${calc.mudaBananeira} unid."),
          _buildRow(
            "Adubo Diverso",
            "${calc.aduboDiverso.toStringAsFixed(1)} L",
          ),

          // SEÇÃO 3: Outros materiais
          _buildSectionHeader("Materiais de Tubulação"),
          _buildRow("Tubo de esgoto de PVC diâmetro 100 mm", "${calc.tuboEsgoto100.toStringAsFixed(1)} m", ),
          _buildRow("Tubo de esgoto de PVC diâmetro 75 mm", "${calc.tuboEsgoto75.toStringAsFixed(1)} m", ),
          _buildRow("Tubo de esgoto de PVC diâmetro 40 mm","${calc.tuboEsgoto40.toStringAsFixed(1)} m", ),
          _buildRow("Tampão PVC 100mm", "${calc.tampaoPVC100} un"),
          _buildRow("Tampão PVC 75mm", "${calc.tampaoPVC75} un"),
          _buildRow("Curva esgoto 90° de 100mm", "${calc.curvaEsgoto90.toStringAsFixed(0)} un", obs: "Verificar será precisa de conexões onde a BET será instalada",),
          _buildRow("Joelho esgoto 45° de 100mm", "${calc.joelhoEsgoto45.toStringAsFixed(0)} un", obs: "Verificar será precisa de conexões onde a BET será instalada",),
          _buildRow("Luva esgoto 100mm", "${calc.luvaEsgoto100} un"),
          _buildRow("Tê esgoto 100mm", "${calc.tePVC100} un"),


          const SizedBox(height: 10),

          // LISTA EXPANSORA
          _buildMenuExpansivo(
            titulo: "Sugestões e prevenções",
            itens: [
          _buildRow("tubo de Esgoto PVC 100MM", "${calc.tuboEsgotoSugestao(distancia).toStringAsFixed(1)} m", obs: "Seugestão para conexão interna..."),
          _buildRow("Conexões 100mm", "Luva, Tê e Tampão"),
            ],
          ),
        ], // Fecha children
      ), // Fecha Column
    ); // Fecha SingleChildScrollView
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildCardInput({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.green,
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {String? obs}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 16)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (obs != null) ...[
            const SizedBox(height: 4),
            Text(
              "Obs: $obs",
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[800],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
