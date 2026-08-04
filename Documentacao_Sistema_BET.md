# Documentação Técnica do Sistema - Projeto BET

Este documento apresenta a especificação técnica detalhada do aplicativo móvel de dimensionamento sustentável de Bacias de Evapotranspiração (BET). Ele foi estruturado de acordo com as normas acadêmicas para compor relatórios de desenvolvimento de sistemas e Trabalhos de Conclusão de Curso (TCC).

---

## 3.4 Desenvolvimento do Aplicativo

O desenvolvimento do aplicativo BET baseou-se na premissa de fornecer uma ferramenta de fácil usabilidade, alta performance e capacidade de funcionamento em ambientes offline (zonas rurais e comunidades isoladas). A seguir, detalham-se os componentes tecnológicos e a estrutura organizacional do sistema desenvolvido.

### 3.4.1 Tecnologias Utilizadas

A pilha tecnológica do projeto foi selecionada para garantir portabilidade multioperacional, estabilidade de execução e integração nativa com o hardware dos dispositivos móveis:

*   **Flutter (SDK ^3.10.7)**: Framework de desenvolvimento de interface de usuário (UI) multiplataforma, de código aberto, mantido pela Google. O Flutter utiliza renderização própria por meio do motor Skia/Impeller, garantindo que os componentes visuais tenham comportamento e aparência idênticos em diferentes versões do sistema operacional Android. O uso do Flutter permitiu implementar o padrão visual **Material 3** de forma fluida e responsiva.
*   **Dart**: Linguagem de programação fortemente tipada, otimizada para o desenvolvimento de clientes rápidos em qualquer plataforma. O Dart compila para código de máquina nativo (*Ahead-of-Time* - AOT) na versão de produção, eliminando a necessidade de pontes (*bridges*) interpretadas, o que reduz o consumo de memória RAM e de bateria nos aparelhos dos usuários.
*   **Android (Min SDK 21)**: O aplicativo foi configurado para suportar aparelhos a partir da API 21 (Android 5.0 Lollipop). Essa escolha técnica garante cobertura de compatibilidade em mais de 98% dos dispositivos móveis ativos no mercado brasileiro, atendendo comunidades de baixa renda que utilizam aparelhos mais antigos.
*   **Bibliotecas e Dependências Empregadas**:
    *   `pdf: ^3.10.4` e `printing: ^5.11.1`: Bibliotecas fundamentais para a geração programática de documentos digitais. O pacote `pdf` permite desenhar e dispor os elementos do relatório em formato vetorial. O pacote `printing` faz a interface com o gerenciador de impressão nativo do Android, permitindo que o usuário visualize o documento gerado em tempo real e salve-o diretamente como arquivo local ou envie-o para uma impressora configurada na rede local.
    *   `share_plus: ^8.0.2`: Fornece uma ponte nativa para invocar a folha de compartilhamento (*Share Sheet*) do sistema operacional, possibilitando o envio da lista de materiais gerada diretamente para outros aplicativos, como WhatsApp, Telegram, e-mail e blocos de notas.
    *   `shared_preferences: ^2.5.5`: Camada de persistência local que salva preferências simples do tipo chave-valor no disco do aparelho. É utilizada para armazenar o estado da pesquisa de usabilidade, garantindo que o pop-up de avaliação da pesquisa acadêmica não importune repetidamente o usuário que já respondeu ao questionário.
    *   `url_launcher: ^6.3.2`: Permite a abertura de URIs e links externos ao aplicativo. É utilizada no redirecionamento seguro para o formulário de pesquisa de usabilidade da escala SUS (System Usability Scale) hospedado no Google Forms.
    *   `flutter_speed_dial: ^7.0.0`: Componente visual que implementa um botão de ação flutuante expansível, otimizando o espaço de exibição de relatórios e agrupando as funções de exportação (PDF e Compartilhamento).
    *   `flutter_native_splash: ^2.4.7` e `flutter_launcher_icons: ^0.13.1`: Ferramentas de suporte ao desenvolvimento utilizadas para gerar e injetar o ícone personalizado do aplicativo e a tela de carregamento (*splash screen*) nativa nos diretórios do sistema operacional Android.

### 3.4.2 Estrutura do Sistema

A organização do código-fonte do aplicativo segue uma divisão de pastas lógica inspirada no padrão arquitetural **Controller-View** (simplificação do MVC adaptado para aplicações reativas de tela única):

```
lib/
├── controller/
│   └── calculadora_bet.dart   # Regras de negócio, dimensionamento e coeficientes de materiais
├── img-utils/
│   └── logo-bet.png           # Logotipo institucional inserido no cabeçalho do PDF
├── utils/
│   └── gerador_pdf.dart       # Lógica de renderização de PDF e mensagens de compartilhamento
├── main.dart                  # Tela Principal, gerenciamento de abas (coleta/relatório) e UI
└── tela_consentimento.dart    # Termo de Consentimento Livre e Esclarecido (TCLE) da pesquisa
```

A divisão de responsabilidades funciona da seguinte forma:
1.  **Interface com o Usuário (Views)**: O arquivo `main.dart` atua como o ponto de entrada e implementa a interface de captação de dados (formulário) e exibição visual do relatório técnico (tabelas e imagens esquemáticas). Ele gerencia o estado da navegação por meio de uma barra inferior e um widget `IndexedStack`, que preserva os dados inseridos nas caixas de texto mesmo ao alternar de aba.
2.  **Lógica e Matemática (Controller)**: O arquivo `calculadora_bet.dart` encapsula a totalidade das regras de dimensionamento de engenharia civil e saneamento ecológico na classe `CalculosBET`. Toda a reatividade da interface depende deste controlador.
3.  **Serviço de Exportação (Utils)**: O arquivo `gerador_pdf.dart` abstrai o código de montagem do PDF. Ele recebe a instância ativa do controlador e traduz as variáveis em um arquivo com leiaute formatado, contendo cabeçalho institucional, tabelas de dados estruturais e a listagem de materiais.

---

## 3.5 Implementação das Regras de Dimensionamento

As diretrizes matemáticas e os coeficientes de dimensionamento de materiais implementados na classe `CalculosBET` baseiam-se em referências técnicas de engenharia e saneamento ecológico rural. O cálculo realiza o dimensionamento estrutural da bacia a partir do número de moradores ($N$) e calcula as quantidades de insumos de construção civil necessários para a execução física da obra.

### 1. Dimensionamento Geométrico e Estrutural da BET

O volume de armazenamento hidráulico da bacia é determinado com base em uma taxa de contribuição de $1,8\text{ m}^3$ por morador ($N$).
$$\text{Volume da BET } (V) = N \times 1,8 \text{ m}^3$$

A altura vertical interna da bacia ($H$) é fixada em um valor padrão de segurança hidráulica de $1,5\text{ m}$, necessário para acomodar a sobreposição correta das camadas filtrantes.
$$\text{Altura da BET } (H) = 1,5 \text{ m}$$

A relação geométrica clássica para bacias retangulares estabelece que o comprimento ($C$) deve ser o dobro da largura ($L$) da estrutura, mantendo a proporção de $2:1$. Sendo a fórmula de volume de um paralelepípedo retangular dada por $V = H \times C \times L$, substitui-se a relação:
$$V = 1,5 \times (2L) \times L \implies V = 3L^2$$

Desta igualdade, isola-se a largura ($L$) e o comprimento ($C$):
$$\text{Largura da BET } (L) = \sqrt{\frac{V}{3}}$$
$$\text{Comprimento da BET } (C) = 2 \times L$$

A área do piso ($A_{\text{piso}}$) e as áreas de alvenaria para construção das paredes são computadas para o cálculo de tijolos e argamassas:
$$\text{Área do Piso } (A_{\text{piso}}) = C \times L$$
$$\text{Área das Paredes Internas } (A_{\text{alv\_int}}) = 2 \times (H \times C) + 2 \times (H \times L)$$

Para proteger a bacia de enxurradas e delimitar o plantio na superfície, constrói-se um canteiro periférico acima do nível do solo com a altura correspondente a três fiadas de tijolos de 6 furos assentados horizontalmente. Considerando que cada tijolo possui $14\text{ cm}$ ($0,14\text{ m}$) de altura:
$$\text{Altura do Canteiro } (H_{\text{canteiro}}) = 3 \times 0,14 \text{ m} = 0,42 \text{ m}$$
$$\text{Área da Alvenaria do Canteiro } (A_{\text{alv\_cant}}) = 2 \times (H_{\text{canteiro}} \times C) + 2 \times (H_{\text{canteiro}} \times L)$$
$$\text{Área Total de Alvenaria } (A_{\text{alv\_total}}) = A_{\text{alv\_int}} + A_{\text{alv\_cant}}$$

### 2. Alturas e Volumes das Camadas de Filtração e Recheio

O miolo interno da BET é composto por camadas filtrantes e preenchimentos com alturas verticais padronizadas:
*   **Camada de Pneus e Entulho** ($H_{\text{entulho}} = 0,6\text{ m}$): Localizada na base, cria um túnel oco para a recepção inicial do efluente.
    *   O volume da câmara interna dos pneus ($V_{\text{camara\_pneu}}$), modelado como um cilindro de diâmetro igual à altura da camada ($0,6\text{ m}$) e comprimento igual ao da bacia ($C$):
        $$V_{\text{camara\_pneu}} = \pi \times \left(\frac{H_{\text{entulho}}}{2}\right)^2 \times C = \pi \times 0,3^2 \times C$$
    *   O volume de entulho e pedras de descarte limpas ($V_{\text{entulho}}$) que ocupam o espaço externo ao túnel de pneus:
        $$V_{\text{entulho}} = (A_{\text{piso}} \times 0,6) - V_{\text{camara\_pneu}}$$
*   **Camada de Pedra Brita/Seixo Grosso** ($H_{\text{brita}} = 0,3\text{ m}$):
    $$V_{\text{brita\_camada}} = A_{\text{piso}} \times 0,3 \text{ m}^3$$
*   **Camada de Areia Média** ($H_{\text{areia}} = 0,3\text{ m}$):
    $$V_{\text{areia\_camada}} = A_{\text{piso}} \times 0,3 \text{ m}^3$$
*   **Camada de Substrato/Solo** ($H_{\text{solo}} = 0,3\text{ m}$):
    $$V_{\text{solo\_camada}} = A_{\text{piso}} \times 0,3 \text{ m}^3$$

### 3. Coeficientes de Consumo de Materiais Construtivos

O aplicativo calcula a lista de compras aplicando taxas de rendimento de materiais padronizados pela prática da construção civil:

*   **Tijolos de 6 Furos (9x19x14 cm)**: Estima-se o consumo de 42 unidades por metro quadrado de parede de alvenaria.
    $$\text{Tijolos } (Q_{\text{tijolos}}) = \lceil 42 \times A_{\text{alv\_total}} \rceil$$
*   **Cimento (Sacos de 50 kg)**: Dividido em três etapas da obra:
    1.  *Assentamento da Alvenaria*: Consumo padrão de 1 saco de cimento para cada 250 tijolos.
        $$\text{Cimento}_{\text{alv}} = \frac{Q_{\text{tijolos}}}{250} \text{ sacos}$$
    2.  *Reboco Impermeabilizante das Paredes*: Rendimento de $6\text{ kg}$ de cimento por $\text{m}^2$ de reboco interno e externo, acrescido de uma margem de 10% para perdas por desperdício.
        $$\text{Cimento}_{\text{reboco}} = \frac{(6 \times A_{\text{alv\_total}}) \times 1,1}{50} \text{ sacos}$$
    3.  *Concreto do Piso (Traço 1:2:3)*: Consumo de $0,316$ sacos de cimento por $\text{m}^2$ de base do piso, também sob acréscimo de 10% de perda.
        $$\text{Cimento}_{\text{piso}} = (A_{\text{piso}} \times 0,316) \times 1,1 \text{ sacos}$$
    *   *Cimento Total*:
        $$\text{Cimento}_{\text{total}} = \text{Cimento}_{\text{alv}} + \text{Cimento}_{\text{reboco}} + \text{Cimento}_{\text{piso}} \text{ sacos}$$
        *(Nota: Caso a fração decimal do cimento total ultrapasse 0,5 sacos, o sistema arredonda a compra para cima usando a função `ceilToDouble()` para evitar a falta de cimento no canteiro de obras).*
*   **Areia Média ($\text{m}^3$)**:
    *   *Alvenaria*: $A_{\text{alv\_total}} \times 0,0175 \text{ m}^3$
    *   *Reboco (com 10% perda)*: $(A_{\text{alv\_total}} \times 0,0124) \times 1,1 \text{ m}^3$
    *   *Piso (com 10% perda)*: $(A_{\text{piso}} \times 0,023) \times 1,1 \text{ m}^3$
    *   *Preenchimento*: $V_{\text{areia\_camada}} = A_{\text{piso}} \times 0,3 \text{ m}^3$
    *   $$\text{Areia}_{\text{total}} = \text{Areia}_{\text{alv}} + \text{Areia}_{\text{reboco}} + \text{Areia}_{\text{piso}} + V_{\text{areia\_camada}}$$
*   **Pedra Brita ou Seixo Grosso ($\text{m}^3$)**:
    *   *Concreto do Piso (com 10% perda)*: $(A_{\text{piso}} \times 0,035) \times 1,1 \text{ m}^3$
    *   *Preenchimento*: $V_{\text{brita\_camada}} = A_{\text{piso}} \times 0,3 \text{ m}^3$
    *   $$\text{Brita}_{\text{total}} = \text{Brita}_{\text{piso}} + V_{\text{brita\_camada}}$$
*   **Aditivo Impermeabilizante (Litros)**: O reboco e o concreto do piso devem conter aditivo impermeabilizante para evitar a infiltração de efluentes no solo circundante sem tratamento adequado. A proporção é de $0,2\text{ Litros}$ por saco de cimento.
    $$\text{Aditivo Total } (L) = 0,2 \times (\text{Cimento}_{\text{reboco}} + \text{Cimento}_{\text{piso}})$$
*   **Pneus Inservíveis (Unidades)**: Quantidade estimada de pneus assentados em fila para criar a câmara interna. Assume-se uma largura de banda média de $20\text{ cm}$ ($0,2\text{ m}$) por pneu.
    $$\text{Pneus } (Q_{\text{pneus}}) = \lceil \frac{C}{0,2} \rceil$$
*   **Paisagismo (Mudas de Bananeira e Adubo)**:
    *   As bananeiras atuam como as plantas evapotranspiradoras centrais do processo ecológico. Recomenda-se o plantio de 1,25 mudas a cada metro quadrado de piso.
        $$\text{Mudas de Bananeira } (Q_{\text{mudas}}) = \lceil 1,25 \times A_{\text{piso}} \rceil$$
    *   Cada cova exige $4\text{ Litros}$ de adubo orgânico misturado.
        $$\text{Adubo Total } (L) = Q_{\text{mudas}} \times 4 \text{ Litros}$$
*   **Tubulações e Conexões**:
    *   Tubo de PVC rígido de 100mm para condução de esgoto bruto:
        $$\text{Comprimento do Tubo } (C_{\text{tubo}}) = \text{distanciaCasa} + 2,0 \text{ metros}$$
        $$\text{Quantidade de barras (6 metros) } (Q_{\text{barras}}) = \lceil \frac{C_{\text{tubo}}}{6} \rceil$$
    *   Valores padrão de conexões e tubos complementares (ventilação e monitoramento):
        *   Tubo PVC 75mm: $1\text{ m}$ (para duto de monitoramento)
        *   Tubo PVC 40mm: $3\text{ m}$ (para ventilação e saída de vapor)
        *   Tampão PVC 100mm: 1 unidade
        *   Tampão PVC 75mm: 1 unidade
        *   Luva Esgoto 100mm: 1 unidade
        *   Tê PVC Esgoto 100mm: 1 unidade

---

## DESENVOLVIMENTO DO SISTEMA

### 4.1 Arquitetura do Aplicativo

O aplicativo utiliza um padrão arquitetural reativo baseado nos recursos nativos do Flutter. Ele evita a complexidade de gerenciadores de estado externos pesados (como Bloc ou Redux), adotando uma estrutura modular limpa, adequada para sistemas focados em utilidade matemática rápida e relatórios locais:

```
                  ┌──────────────────────────────────────────────┐
                  │          Material 3 User Interface           │
                  │  (main.dart & tela_consentimento.dart)       │
                  └──────────────┬──────────────────┬────────────┘
                                 │                  │
         Captação de Dados       │                  │  Ação de
         e Gatilho de Cálculo    │                  │  Exportação
                                 ▼                  ▼
             ┌─────────────────────────┐      ┌─────────────────────────┐
             │       Controller        │      │    Utilidades (PDF)     │
             │ (calculadora_bet.dart)  │◀─────│  (gerador_pdf.dart)     │
             └─────────────────────────┘      └─────────────────────────┘
```

*   **Camada de Visão (UI - Views)**: O arquivo [main.dart](file:///C:/Users/rafar/Desktop/BET/BET-APP/lib/main.dart) concentra a montagem da interface gráfica. O estado local da tela é controlado pela classe `_TelaPrincipalState`. A inserção dos dados é validada dinamicamente, notificando o usuário por meio de `SnackBar` em caso de dados inválidos ou ausentes. A renderização visual das seções de relatório de materiais adota tabelas nativas (`Table`) e componentes expansíveis (`ExpansionTile`), que diminuem a sobrecarga cognitiva do usuário ao esconder detalhes secundários sob demanda.
*   **Camada de Controle (Controller)**: A lógica matemática e as fórmulas descritas na seção 3.5 estão alocadas na classe `CalculosBET` em [calculadora_bet.dart](file:///C:/Users/rafar/Desktop/BET/BET-APP/lib/controller/calculadora_bet.dart). A classe recebe o número de moradores no seu construtor e disponibiliza as propriedades calculadas como membros públicos de leitura. Isso cria um desacoplamento saudável, permitindo alterar os coeficientes das fórmulas no controlador sem a necessidade de modificar os arquivos da interface gráfica.
*   **Camada de Serviços (Utils/Serviços)**: O gerador de PDF e a montagem do texto de compartilhamento estão alocados em [gerador_pdf.dart](file:///C:/Users/rafar/Desktop/BET/BET-APP/lib/utils/gerador_pdf.dart). Ao ser acionado pela interface, o gerador monta a estrutura de páginas baseando-se nas informações que extrai diretamente do controlador.

### 4.2 Interface do Sistema

A interface do aplicativo BET adota um design centrado na usabilidade rural e técnica. O fluxo visual baseia-se em duas telas principais operadas sob uma barra de navegação com transição instantânea:

1.  **Tela de Coleta de Dados (Formulário)**:
    *   **Campo "Nome da Comunidade/Local"**: Campo de texto flexível que permite identificar o relatório técnico.
    *   **Campo "Número de moradores"**: Campo numérico validado. O sistema restringe a entrada a um limite físico de até 8 moradores, garantindo que o dimensionamento não ultrapasse a capacidade de evapotranspiração segura do ecossistema de alvenaria retangular padrão.
    *   **Campo "Distância até a casa"**: Campo numérico para o cálculo do comprimento e de quantas barras de esgoto PVC de 100mm serão adquiridas.
    *   **Seletor "Presença de água no solo a 1,5 metros"**: Componente do tipo rádio (`RadioListTile`) para identificar a profundidade do lençol freático local, essencial para a decisão de engenharia da fundação da BET.
    *   **Botão Flutuante Principal (FAB)**: Botão com ícone de calculadora e legenda em texto que realiza a validação cruzada dos dados e inicia o processamento do relatório.
2.  **Tela de Exibição do Relatório Técnico**:
    *   **Banner de Recomendação Técnica**: Localizado no topo da tela, exibe a classificação do projeto ("ALVENARIA SUSPENSA" ou "ALVENARIA ESCAVADA") com cores de destaque (Laranja para solo com lençol alto e Verde para solo seco) e um desenho técnico detalhado demonstrando o perfil construtivo recomendado.
    *   **Tabelas de Informações**: Listagem de todas as dimensões estruturais (Volume, Comprimento, Largura, Alturas das camadas) e a especificação de insumos divididos em cartões de cabeçalho verde, seguindo a ordem lógica da construção (Paredes $\rightarrow$ Reboco $\rightarrow$ Piso $\rightarrow$ Preenchimento e Plantio $\rightarrow$ Tubulações).
    *   **Submenus Expansíveis ("Ver Mais Detalhes" e "Quant. Traço")**: Reduzem o tamanho visual do relatório, permitindo que usuários mais avançados analisem volumes parciais das camadas e traços recomendados de mistura de concreto sem poluir a leitura geral dos materiais de compra.
3.  **Botão de Ações Dinâmicas (Speed Dial)**:
    *   Menu flutuante circular que surge na tela de relatórios e expande em duas opções com rótulos de texto descritivos: "Salvar relatório em PDF" (ícone vermelho de documento) e "Compartilhar Lista de Materiais" (ícone azul de partilha).

### 4.3 Implementação dos Cálculos

A execução matemática ocorre em tempo de execução de forma preguiçosa (*lazy evaluation*). A classe `CalculosBET` realiza as operações por meio de funções puras e expressões matemáticas baseadas nas propriedades do objeto. 

O controlador garante consistência nas conversões de unidades estruturais. Os cálculos de volume baseiam-se em valores flutuantes de dupla precisão (`double`), assegurando exatidão no volume total em metros cúbicos ($m^3$). No entanto, para insumos comerciais que são comercializados apenas em frações inteiras no varejo, o Dart realiza a conversão automática para inteiros (`int`) arredondando sempre para cima. Exemplo prático de código no controlador:
```dart
int get tijolos6Furos => tijolos6FurosCalculado.ceil();
int get pneuInservivel => (comprimentoDaBet / 0.2).ceil();
int get mudaBananeira => (1.25 * areaDoPisoDaBet).ceil();
```
O cimento total utiliza uma condicional lógica personalizada para evitar que pequenos resíduos decimais façam o usuário comprar um saco a mais sem necessidade, aplicando arredondamento para cima apenas quando a sobra decimal é significativa ($> 0.5$ sacos):
```dart
double get cimentoSacosTotal {
  double total = cimentoSacos + cimentoSacoComPerda + cimentoSacoPerdaPiso;
  if ((total - total.truncate()) > 0.5) {
    return total.ceilToDouble();
  }
  return total;
}
```

### 4.4 Funcionalidades Implementadas

O aplicativo BET agrupa cinco funcionalidades principais integradas:

#### 4.4.1 Dimensionamento Automático
A partir unicamente da inserção do número de moradores ($N$), o sistema determina instantaneamente todas as dimensões físicas da bacia ecológica e o volume de materiais necessários para a infraestrutura, eliminando a necessidade de planilhas complexas de engenharia por parte dos técnicos em campo.

#### 4.4.2 Definição do Tipo de BET
Funcionalidade lógica de tomada de decisão. O aplicativo avalia a resposta referente ao lençol freático local para determinar o método de construção:
*   Se a variável `_temAgua` for marcada como **verdadeira**, a estrutura lógica direciona para o tipo de **Alvenaria Suspensa**. A bacia é projetada para sobressair acima do terreno natural. Essa técnica evita que a água subterrânea penetre na BET (o que encheria a bacia rapidamente e inviabilizaria o tratamento por saturação) e impede a infiltração de efluentes sanitários diretamente no aquífero livre.
*   Se a variável `_temAgua` for marcada como **falsa**, o sistema define a recomendação de **Alvenaria Escavada**. A bacia é embutida no solo, o que reduz custos com alvenaria externa estrutural devido ao confinamento físico promovido pelas paredes de terra natural.

#### 4.4.3 Geração de Relatório Técnico
O sistema reúne os dados e os apresenta de forma ordenada e sequencial no visor do aparelho celular. A listagem é segregada por etapas cronológicas da construção, o que facilita o cronograma de compras física e a execução do trabalho por parte do pedreiro.

#### 4.4.4 Exportação em PDF
Criação automatizada de um documento de relatório técnico no formato padrão A4. A biblioteca `pdf` desenha o cabeçalho técnico com identificação do projeto, campo para preencher a comunidade rural atendida, número de moradores e volume cúbico final do projeto. A página principal do PDF exibe as tabelas de quantitativos e uma seção dedicada à **"Lista de Compras (Resumo)"**, desenhada com caixas de marcação físicas (checklist) que podem ser impressas para conferência no momento da aquisição dos materiais de construção civil.

#### 4.4.5 Compartilhamento de Informações
Implementação de exportação instantânea do resumo de materiais. A rotina do serviço formata um texto em string estruturado com marcadores gráficos (como asteriscos para negrito e colchetes vazios `[ ]` representando checklist de tarefas). O sistema invoca a API do sistema operacional, permitindo enviar esses dados em formato texto sem a necessidade de baixar e enviar arquivos pesados, ideal para conexões rurais lentas.

### 4.5 Fluxo de Funcionamento do Sistema

O fluxo operacional do usuário no sistema é ilustrado no diagrama e detalhado a seguir:

```mermaid
sequenceDiagram
    actor U as Usuário/Técnico
    participant UI as Interface (main.dart)
    participant C as Controller (calculadora_bet.dart)
    participant P as Utils (gerador_pdf.dart)
    participant E as Sistema Operacional/Nativo

    Note over U, UI: Início do Aplicativo
    UI->>E: Verifica persistência local (SharedPreferences)
    E-->>UI: Retorna se Pesquisa SUS já foi respondida
    Note over UI: Se não respondida, exibe pop-up de TCC por 1 min
    
    U->>UI: Insere Comunidade, Moradores, Distância e Tipo de Solo
    U->>UI: Pressiona botão "CALCULAR"
    UI->>UI: Valida os dados inseridos (ex: moradores <= 8)
    
    UI->>C: Instancia CalculosBET(moradores)
    C-->>UI: Retorna propriedades e dimensões calculadas
    Note over UI: UI define Tipo de BET:<br/>Alvenaria Suspensa se solo úmido;<br/>Alvenaria Escavada se solo seco
    UI->>UI: Alterna para a aba "Relatório" e exibe resultados
    
    rect rgb(230, 245, 230)
        Note over U, UI: Opção de Exportação (Menu Flutuante)
        alt Salvar em PDF
            U->>UI: Seleciona "Salvar em PDF"
            UI->>P: Executa gerarPDF(CalculosBET, distancia, comunidade)
            P->>E: Invoca gerenciador de impressão nativo (Printing.layoutPdf)
            E-->>U: Abre tela de salvamento de arquivo / impressão do celular
        else Compartilhar Lista
            U->>UI: Seleciona "Compartilhar Lista de Materiais"
            UI->>P: Solicita gerarTextoCompartilhamento(CalculosBET, distancia, comunidade)
            P-->>UI: Retorna texto formatado com checklist
            UI->>E: Invoca janela de compartilhamento nativa (Share.share)
            E-->>U: Exibe opções de envio (WhatsApp, E-mail, etc.)
        end
    end

    rect rgb(240, 240, 245)
        Note over U, UI: Pesquisa Científica (TCC)
        U->>UI: Clica no botão "RESPONDER" no pop-up do TCC
        UI->>UI: Abre tela_consentimento.dart (Exibe TCLE acadêmico)
        U->>UI: Marca checkbox de consentimento e clica em prosseguir
        UI->>E: Invoca url_launcher para abrir link do Google Forms no navegador
    end
```

1.  **Entrada de Dados (Coleta)**: O técnico ou morador abre o aplicativo na aba de "Coleta", preenche o nome da comunidade, indica o número de moradores que residem na casa (limitado a 8) e a distância da casa até o local da fossa. Em seguida, seleciona o estado de umidade do solo a 1,5m.
2.  **Validação e Inicialização**: O sistema verifica se todos os campos obrigatórios foram informados. Caso os dados estejam corretos, instancia a classe de negócios `CalculosBET` com os parâmetros inseridos.
3.  **Processamento da Recomendação de Engenharia**: O sistema realiza os cálculos de volume de evapotranspiração e dimensiona o comprimento, largura e áreas. Simultaneamente, avalia o estado do solo: se houver água subterrânea na escavação, o aplicativo seleciona o leiaute de "Alvenaria Suspensa" e exibe a imagem correspondente; caso contrário, seleciona o leiaute de "Alvenaria Escavada".
4.  **Visualização do Relatório**: O aplicativo altera automaticamente o índice da aba ativa para exibir o relatório de dimensionamento. O usuário pode analisar item por item e expandir os menus expansivos para verificar volumes de escavação e traços de concreto.
5.  **Ações de Saída**: O usuário utiliza o menu flutuante expansível para:
    *   *Salvar em PDF*: Onde o gerador de arquivos compila as tabelas de materiais e gera um documento A4 com checklists prontos para impressão física.
    *   *Compartilhar*: Onde o aplicativo compila uma mensagem de texto reativa e invoca a janela de compartilhamento do aparelho celular para envio rápido de insumos via aplicativos de mensagem.
6.  **Participação na Pesquisa Científica**: Ao interagir com o pop-up temporário de avaliação de usabilidade acadêmica, o usuário acessa a tela de consentimento livre e esclarecido, de onde é direcionado de forma segura ao questionário acadêmico de validação científica (TCC/UFRA) hospedado externamente.
