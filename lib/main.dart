import 'package:flutter/material.dart';
import 'package:app_bet/controller/calculadora_bet.dart'; // Importa sua lógica de cálculo

void main() => runApp(const ProjetoBET());

class ProjetoBET extends StatelessWidget {
  const ProjetoBET({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Projeto BET',
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
  // --- VARIÁVEIS GLOBAIS DA TELA (O "ESTADO") ---
  int _indiceAtual = 0; // Controla qual aba está visível (0 = Coleta, 1 = Relatório)
  
  // Controladores de texto (ficam aqui para os dados não sumirem ao trocar de aba)
  final _moradoresController = TextEditingController();
  final _distanciaController = TextEditingController();
  
  // Variáveis de dados
  bool? _temAgua;
  bool _calculoRealizado = false; // Para controlar se mostramos o relatório ou aviso

  // --- LÓGICA DO BOTÃO FLUTUANTE ---
  void _realizarCalculo() {
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    // Validação básica
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

    // Se passou na validação:
    setState(() {
      _calculoRealizado = true; // Libera a visualização do relatório
      _indiceAtual = 1; // Muda automaticamente para a aba de Relatório
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista das Telas (Abas)
    final List<Widget> _telas = [
      // ABA 0: FORMULÁRIO DE COLETA
      _buildAbaFormulario(),
      
      // ABA 1: RELATÓRIO TÉCNICO
      _buildAbaRelatorio(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_indiceAtual == 0 ? "Coleta de Dados" : "Relatório Técnico"),
      ),
      
      // IndexedStack preserva o estado das telas (não apaga o que digitou)
      body: IndexedStack(
        index: _indiceAtual,
        children: _telas,
      ),

      // --- MENU FIXO INFERIOR ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual,
        onDestinationSelected: (index) {
          setState(() {
            _indiceAtual = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note),
            label: 'Coleta',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment),
            label: 'Relatório',
          ),
        ],
      ),

      // --- BOTÃO FLUTUANTE NO CANTO INFERIOR ESQUERDO ---
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // <-- O TRUQUE ESTÁ AQUI
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _realizarCalculo,
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calculate),
        label: const Text("CALCULAR"),
      ),
    );
  }

  // --- CONSTRUÇÃO DA ABA DE FORMULÁRIO ---
  Widget _buildAbaFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80), // 80 no final para o botão não tapar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          
          const SizedBox(height: 20),

          _buildCardInput(
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
                  groupValue: _temAgua,
                  onChanged: (val) => setState(() => _temAgua = val),
                  activeColor: Colors.green,
                ),
                RadioListTile<bool>(
                  title: const Text("Não (Solo Seco)"),
                  value: false,
                  groupValue: _temAgua,
                  onChanged: (val) => setState(() => _temAgua = val),
                  activeColor: Colors.green,
                ),
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

    // Prepara os dados para exibir
    int moradores = int.parse(_moradoresController.text);
    double distancia = double.tryParse(_distanciaController.text) ?? 4.0;
    
    // Instancia a classe de cálculos que criamos anteriormente
    final calc = CalculosBET(moradores);
    
    // Lógica visual do tipo de fossa
    final bool alvenariaSuspensa = _temAgua!;
    final String tituloFossa = alvenariaSuspensa ? "ALVENARIA SUSPENSA" : "ALVENARIA ESCAVADA";
    final Color corDestaque = alvenariaSuspensa ? Colors.orange[800]! : Colors.green[800]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Espaço pro botão
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
                Text("RECOMENDAÇÃO TÉCNICA", style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(tituloFossa, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: corDestaque), textAlign: TextAlign.center),
              ],
            ),
          ),
          
          // Seção 1
          _buildSectionHeader("Dados Gerais"),
          _buildRow("Volume da BET", "${calc.volumeBet.toStringAsFixed(2)} m³"),
          _buildRow("Dimensões (LxC)", "${calc.largura.toStringAsFixed(2)}m x ${calc.comprimento.toStringAsFixed(2)}m"),
          _buildRow("Profundidade", "${calc.alturaBet.toStringAsFixed(2)} m"),
          _buildRow("Área Alvenaria", "${calc.areaAlvenariaTotal.toStringAsFixed(2)} m²"),

          // Seção 2
          _buildSectionHeader("Materiais"),
          _buildRow("Tijolos (6 furos)", "${calc.tijolos} unid."),
          _buildRow("Cimento", "${calc.cimentoSacos.toStringAsFixed(1)} sacos"),
          _buildRow("Areia Média", "${calc.areia.toStringAsFixed(2)} m³"),
          _buildRow("Brita/Seixo", "${calc.brita.toStringAsFixed(2)} m³"),
          _buildRow("Pneus", "${calc.pneus} unid."),
          _buildRow("Entulho", "${calc.entulho.toStringAsFixed(2)} m³", obs: "Material limpo"),
          _buildRow("Mudas Bananeira", "${calc.mudasBananeira} unid."),

          // Seção 3
          _buildSectionHeader("Tubulação"),
          _buildRow("Tubo 100mm", "${calc.tubo100(distancia).toStringAsFixed(1)} m"),
          _buildRow("Conexões Básicas", "Luva, Tê e Tampão (verificar local)"),
        ],
      ),
    );
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
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
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
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRow(String label, String value, {String? obs}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          if (obs != null) Text("Obs: $obs", style: TextStyle(fontSize: 12, color: Colors.orange[800], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}