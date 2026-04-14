import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TelaConsentimento extends StatefulWidget {
  const TelaConsentimento({Key? key}) : super(key: key);

  @override
  State<TelaConsentimento> createState() => _TelaConsentimentoState();
}

class _TelaConsentimentoState extends State<TelaConsentimento> {
  bool _aceitouTermos = false;

  // Função para abrir o questionário (Exemplo com Google Forms)
  Future<void> _abrirQuestionario() async {
    // Substitua pelo link real do seu Google Forms
    final String linkForms = "https://docs.google.com/forms/d/e/1FAIpQLSf3zyN37g-Vap33gV-CqfBLh3ove0YsRaDe5vqQX1A4gmLIpw/viewform?usp=dialog"; 
    
    // Lógica para abrir o link (requer o pacote url_launcher no pubspec.yaml)
    final Uri url = Uri.parse(linkForms);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o questionário.')),
      );
    }
    
    // Apenas para teste visual enquanto não coloca o link:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirecionando para a pesquisa... Obrigado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesquisa Acadêmica"),
        backgroundColor: Colors.green[800], // Mantendo a cor do projeto
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Área do Texto do Consentimento (Rolável)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Termo de Consentimento Livre e Esclarecido (TCLE)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Título da pesquisa: Desenvolvimento e Avaliação de um Aplicativo para Dimensionamento de Bacias de Evapotranspiração (BET)\n\n"
                    "Você está sendo convidado(a) a participar da avaliação de um aplicativo desenvolvido no âmbito da Universidade Federal Rural da Amazônia (UFRA), Campus Capitão Poço, sob a responsabilidade do Prof. Dr. Felipe André da Costa Brito e do discente Rafael de Oliveira Mendonça (Licenciatura em Computação).\n\n"
                    "Objetivo: Avaliar a usabilidade e a aceitação do aplicativo de dimensionamento de BETs, contribuindo para a sua validação e o seu aperfeiçoamento técnico.\n\n"
                    "Como funcionará: Ao aceitar participar, você utilizará o aplicativo e, em seguida, responderá a este breve questionário eletrônico sobre a sua experiência de uso. O tempo estimado para resposta é de aproximadamente 3 a 5 minutos.\n\n"
                    "Riscos e Benefícios: A atividade apresenta riscos mínimos, limitando-se ao tempo dedicado à avaliação. Não há benefícios diretos, mas a sua colaboração ajudará a aprimorar uma ferramenta que poderá auxiliar estudantes e profissionais de saneamento ambiental.\n\n"
                    "Privacidade e Voluntariedade: A sua participação é totalmente anônima e voluntária. Não solicitaremos nenhuma informação que permita a sua identificação. Os dados coletados serão analisados de forma agrupada e utilizados exclusivamente para fins acadêmicos e científicos. Você pode desistir de participar a qualquer momento, bastando fechar esta página.\n\n"
                    "Em caso de dúvidas, entre em contato com a equipe responsável:\n\n"
                    "Prof. Dr. Felipe André da Costa Brito - felipe.brito@ufra.edu.br\n\n"
                    "Rafael de Oliveira Mendonça – mailto:rafa.ro195@gmail.com \n\n"
                    "Ao selecionar a opção abaixo e prosseguir, você declara que leu, compreendeu as informações acima e concorda em participar voluntariamente da avaliação.",
                    style: TextStyle(fontSize: 15, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
          
          // Área de Ação (Fixa no rodapé)
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _aceitouTermos,
                      activeColor: Colors.green[800],
                      onChanged: (bool? value) {
                        setState(() {
                          _aceitouTermos = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Li e aceito participar da pesquisa.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      // O botão fica cinza se o checkbox não estiver marcado
                      disabledBackgroundColor: Colors.grey[300], 
                      disabledForegroundColor: Colors.grey[600],
                    ),
                    onPressed: _aceitouTermos ? _abrirQuestionario : null,
                    child: const Text(
                      "ACEITAR E RESPONDER",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}