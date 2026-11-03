import '../models/book_model.dart';

// ============================================================================
// ✂️ ÁREA DE COPIAR E COLAR (TODOS OS COMPONENTES PARA CRIAR UM LIVRO NOVO)
// ============================================================================
//
// 📌 COMPONENTE 1: O LIVRO COMPLETO (Copie, cole no final da lista e preencha)
/*
BookModel(
  id: 'meu-livro-novo',
  title: 'Título do Material',
  category: BookCategories.redacao, // BookCategories.redacao, .matematica, .ciencias, .linguagens, .humanas
  imageUrl: BookCovers.redacao,      // BookCovers.redacao, .matematica, .geometria, .fisica, .historia...
  description: 'Sinopse explicativa do assunto que o estudante vai aprender.',
  readTimeMinutes: 15,
  author: 'Equipe Oráculo',
  tags: const ['enem', 'resumo', 'vestibular'],
  sections: [
    BookSectionModel(
      id: 'cap-1',
      title: '1. Introdução e Conceitos Principais',
      content: '''
Escreva aqui o conteúdo da aula ou matéria.
Pode usar quebras de linha normais e marcadores:
• Tópico 1
• Tópico 2
• Exemplo prático
''',
      keyTakeaways: const [
        'Conceito chave que sempre cai na prova',
        'Fórmula ou regra prática para lembrar',
      ],
      studyTip: 'Dica de ouro do professor ou pegadinha comum para ficar atento!',
    ),
  ],
),
*/
//
// 📌 COMPONENTE 2: UM NOVO CAPÍTULO (Copie e cole dentro de sections: [...])
/*
BookSectionModel(
  id: 'cap-2',
  title: '2. Título do Novo Capítulo',
  content: '''
Conteúdo explicativo deste novo capítulo...
• Detalhe A
• Detalhe B
''',
  keyTakeaways: const [
    'Ponto principal 1',
    'Ponto principal 2',
  ],
  studyTip: 'Dica prática para vestibulares e provas.',
),
*/
//
// 📌 COMPONENTE 3: LIVRO RÁPIDO (Criação em apenas 5 linhas)
/*
BookModel.quick(
  id: 'livro-rapido-1',
  title: 'Título Rápido',
  category: BookCategories.matematica,
  imageUrl: BookCovers.matematica,
  description: 'Resumo rápido do tema.',
  content: '''Texto explicativo completo aqui...''',
  studyTip: 'Dica importante!',
  keyTakeaways: const ['Ponto 1', 'Ponto 2'],
),
*/
//
// 📌 COMPONENTE 4: CAPAS REUTILIZÁVEIS DISPONÍVEIS:
// BookCovers.redacao       BookCovers.matematica      BookCovers.geometria
// BookCovers.literatura    BookCovers.linguagens      BookCovers.fisica
// BookCovers.quimica       BookCovers.biologia        BookCovers.historia
// BookCovers.filosofia     BookCovers.tecnologia      BookCovers.cadernos
//
// 📌 COMPONENTE 5: CATEGORIAS DISPONÍVEIS:
// BookCategories.redacao       BookCategories.matematica
// BookCategories.linguagens    BookCategories.ciencias
// BookCategories.humanas       BookCategories.atualidades
// ============================================================================

final List<BookModel> universalBooksCatalog = [
  // -------------------------------------------------------------------------
  // REDAÇÃO
  // -------------------------------------------------------------------------
  BookModel(
    id: 'redacao-nota-1000',
    title: 'Redação Nota 1000',
    category: BookCategories.redacao,
    imageUrl: BookCovers.redacao,
    description:
        'Guia definitivo para dominar o texto dissertativo-argumentativo do ENEM, com estruturas, repertórios e modelos práticos.',
    readTimeMinutes: 15,
    author: 'Equipe de Redação Oráculo',
    tags: const ['redação', 'enem', 'nota 1000', 'dissertação', 'vestibular'],
    sections: [
      BookSectionModel(
        id: 'red-1',
        title: '1. O Esqueleto do Texto Nota 1000',
        content:
            '''A redação do **ENEM** exige uma estrutura dissertativa-argumentativa dividida rigidamente em **4 parágrafos**:

• **Parágrafo 1 - Introdução:** Apresentação do tema + contextualização com repertório sociocultural + tese com **2 argumentos** (D1 e D2).

• **Parágrafo 2 - Desenvolvimento 1:** Tópico frasal relacionado ao primeiro argumento + fundamentação teórica + desfecho crítico.

• **Parágrafo 3 - Desenvolvimento 2:** Tópico frasal do segundo argumento + dados estatísticos ou citação + consequência social direta.

• **Parágrafo 4 - Conclusão:** Proposta de intervenção completa com os **5 elementos obrigatórios** (Agente, Ação, Meio/Modo, Efeito e Detalhamento).''',
        keyTakeaways: const [
          'Mantenha sempre 4 parágrafos bem equilibrados (7 a 8 linhas cada).',
          'Sua tese deve conter explicitamente as duas causas que serão debatidas em D1 e D2.',
          'Nunca deixe de contextualizar o tema logo na primeira linha.',
        ],
        studyTip:
            'Evite frases longas demais na introdução. O leitor precisa entender sua tese já no primeiro olhar.',
      ),
      BookSectionModel(
        id: 'red-2',
        title: '2. Proposta de Intervenção Nota Máxima (200 pts)',
        content:
            '''A **Competência 5** avalia a capacidade de propor uma solução detalhada aos problemas discutidos. Para alcançar a pontuação máxima de **200 pontos**, seu parágrafo DEVE conter:

1. **AGENTE:** Quem executará a ação? *(Ex: Ministério da Educação, Governo Federal, Mídia).*

2. **AÇÃO:** O que será feito? *(Ex: Deve instituir campanhas educativas permanentes).*

3. **MEIO / MODO:** Como será feito? *(Ex: Por intermédio de parcerias público-privadas e redes sociais).*

4. **EFEITO / FINALIDADE:** Para que serve? *(Ex: Com o intuito de democratizar o acesso à informação).*

5. **DETALHAMENTO:** Informação adicional sobre um dos 4 itens acima *(Ex: detalhando a ação com exemplos ou o agente com suas atribuições constitucionais).*''',
        keyTakeaways: const [
          'Sempre confira os 5 elementos antes de passar o texto a limpo.',
          'O detalhamento pode ser uma oração explicativa como: ", órgão responsável por..."',
          'Respeite sempre os direitos humanos!',
        ],
        studyTip:
            'Use o conectivo "Portanto," para iniciar o parágrafo de conclusão e indicar fechamento lógico.',
      ),
    ],
  ),

  BookModel(
    id: 'estrutura-argumentativa',
    title: 'Estrutura Argumentativa',
    category: BookCategories.redacao,
    imageUrl: BookCovers.cadernos,
    description:
        'Como encadear argumentos consistentes, usar conectivos interparágrafos e evitar falhas de coerência.',
    readTimeMinutes: 12,
    author: 'Equipe de Redação Oráculo',
    tags: const ['argumentação', 'coesão', 'conectivos', 'coerência'],
    sections: [
      BookSectionModel(
        id: 'arg-1',
        title: '1. Conectivos Interparágrafos Essenciais',
        content:
            '''Para garantir a nota máxima na **Competência 4 (coesão)**, é obrigatório utilizar conectivos interparágrafos expressivos:

### Conectivos Interparágrafos (Obrigatórios)
• **No início do D2:** "Ademais,", "Outrossim,", "Além disso,", "Por outro lado," (caso seja uma antítese).
• **No início da Conclusão:** "Portanto,", "Em suma,", "Dessa maneira,", "Destarte,".

### Conectivos Intraparágrafos (Dentro do Parágrafo)
Garanta pelo menos dois conectivos dentro de cada parágrafo:
• **Causais e Consecutivos:** "Nesse sentido,", "Com efeito,", "Por conseguinte,", "Logo,".
• **Explicativos:** "Visto que,", "Dado que,", "Haja vista que,".''',
        keyTakeaways: const [
          'Nunca inicie o D2 sem um conectivo interparágrafo.',
          'Varie o vocabulário para evitar repetições excessivas da mesma conjunção.',
        ],
        studyTip:
            'Cuidado com "Sob esse viés" no primeiro parágrafo: só use conectivos referenciais se houver algo anterior a que se referir!',
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // MATEMÁTICA
  // -------------------------------------------------------------------------
  BookModel(
    id: 'matematica-e-funcoes',
    title: 'Matemática e Funções',
    category: BookCategories.matematica,
    imageUrl: BookCovers.matematica,
    description:
        'Estudo aprofundado de funções de 1º e 2º grau, gráficos, vértices, máximos e mínimos aplicados a questões reais.',
    readTimeMinutes: 18,
    author: 'Prof. Carlos - Oráculo Exatas',
    tags: const ['matemática', 'funções', 'álgebra', 'gráfico', 'enem'],
    sections: [
      BookSectionModel(
        id: 'mat-1',
        title: '1. Função Afim (1º Grau)',
        content: '''A **Função Afim** possui a lei de formação elementar:

`f(x) = ax + b` (com **a ≠ 0**)

• **'a' (Coeficiente Angular):** É a taxa de variação. Se **a > 0**, a reta é crescente; se **a < 0**, é decrescente.

• **'b' (Coeficiente Linear):** É o ponto exato onde a reta intercepta o eixo vertical Y, ou seja, **f(0) = b**.

### Raiz ou Zero da Função
Para encontrar onde a reta corta o eixo horizontal X:
`ax + b = 0  =>  x = -b / a`''',
        keyTakeaways: const [
          'Taxa de variação: a = Δy / Δx',
          'O coeficiente linear representa o valor fixo em problemas cotidianos (ex: taxa fixa de táxi).',
        ],
        studyTip:
            'Em gráficos de função afim no ENEM, identifique primeiro o ponto em que a reta cruza o eixo vertical Y: esse é imediatamente o seu termo independente b!',
      ),
      BookSectionModel(
        id: 'mat-2',
        title: '2. Função Quadrática e Vértice da Parábola',
        content: '''A **Função Quadrática** (2º grau) é representada pela forma canônica:

`f(x) = ax² + bx + c` (com **a ≠ 0**)

### Vértice da Parábola V(Xv, Yv)
O vértice indica o ponto extremo (máximo ou mínimo):
• **Xv = -b / (2a)**
• **Yv = -Δ / (4a)** onde **Δ = b² - 4ac**

### Concavidade
• **Se a > 0:** Concavidade voltada para CIMA -> O vértice é ponto de **MÍNIMO**.
• **Se a < 0:** Concavidade voltada para BAIXO -> O vértice é ponto de **MÁXIMO**.''',
        keyTakeaways: const [
          'Quando a questão pedir "qual o valor que gera o lucro máximo", calcula-se Xv.',
          'Quando a questão pedir "qual é o lucro máximo obtido", calcula-se Yv.',
        ],
        studyTip:
            'Você também pode achar o Yv substituindo o Xv calculado diretamente na função f(Xv), sem precisar calcular Δ!',
      ),
    ],
  ),

  BookModel(
    id: 'geometria-espacial',
    title: 'Geometria Espacial',
    category: BookCategories.matematica,
    imageUrl: BookCovers.geometria,
    description:
        'Fórmulas essenciais de prismas, cilindros, cones, esferas e pirâmides com macetes de cálculo de volume.',
    readTimeMinutes: 14,
    author: 'Prof. Carlos - Oráculo Exatas',
    tags: const ['geometria', 'espacial', 'volumes', 'prismas', 'cilindros'],
    sections: [
      BookSectionModel(
        id: 'geo-1',
        title: '1. Sólidos de Seção Constante (Prismas e Cilindros)',
        content:
            '''Todos os sólidos com bases paralelas e idênticas seguem a mesma regra fundamental de volume:

`Volume = Área da Base × Altura (V = Ab · h)`

### Fórmulas Principais
• **Prisma Retangular (Paralelepípedo):** `V = a · b · c`
• **Cubo:** `V = a³`
• **Cilindro Reto:** `V = (π · r²) · h`
• **Área Lateral do Cilindro:** `Al = 2 · π · r · h`''',
        keyTakeaways: const [
          'Cilindro é apenas um prisma de base circular.',
          'Fique atento às conversões de unidades: 1 m³ = 1.000 L e 1 cm³ = 1 mL.',
        ],
        studyTip:
            'No ENEM é comum aproximar π por 3 ou 3,14. Sempre leia com atenção o comando do enunciado!',
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // LINGUAGENS
  // -------------------------------------------------------------------------
  BookModel(
    id: 'literatura-e-classicos',
    title: 'Literatura e Clássicos',
    category: BookCategories.linguagens,
    imageUrl: BookCovers.literatura,
    description:
        'Panorama das escolas literárias brasileiras: Romantismo, Realismo, Naturalismo, Modernismo e autores centrais.',
    readTimeMinutes: 20,
    author: 'Profª. Beatriz - Oráculo Letras',
    tags: const ['literatura', 'machado de assis', 'modernismo', 'enem'],
    sections: [
      BookSectionModel(
        id: 'lit-1',
        title: '1. O Realismo e Machado de Assis',
        content:
            '''O **Realismo no Brasil** tem marco inicial em **1881** com a publicação de *"Memórias Póstumas de Brás Cubas"*.

### Características Centrais de Machado de Assis
• **Narrador não confiável e irônico:** Conduz o leitor através de ambiguidades morais e meias-verdades.

• **Análise psicológica profunda:** Foco nas motivações íntimas, hipocrisias e interesses materiais.

• **Crítica à elite burguesa:** Desnuda a vaidade superficial do Segundo Reinado carioca.

• **Metalinguagem e diálogo direto:** Conversa explícita com o leitor (*"Que leitor amigo..."*).

• **Fragmentação e digressões:** Capítulos curtos, reflexões filosóficas e pausas na trama linear.''',
        keyTakeaways: const [
          'Diferente do Romantismo idealizado, o Realismo desnuda o adultério, a falsidade e as ambições materiais.',
          'Dom Casmurro e a dúvida sobre Capitu simbolizam o ciúme e a ótica distorcida de Bentinho.',
        ],
        studyTip:
            'Nas provas, foque no tom irônico: Machado nunca diz abertamente o que condena; ele finge elogiar para expor a decadência moral.',
      ),
    ],
  ),

  BookModel(
    id: 'gramatica-e-interpretacao',
    title: 'Gramática e Interpretação',
    category: BookCategories.linguagens,
    imageUrl: BookCovers.linguagens,
    description:
        'Sintaxe aplicada, regência, crase, concordância e leitura analítica de textos verbais e não-verbais.',
    readTimeMinutes: 14,
    author: 'Profª. Beatriz - Oráculo Letras',
    tags: const ['gramática', 'crase', 'sintaxe', 'concordância'],
    sections: [
      BookSectionModel(
        id: 'gram-1',
        title: '1. Regras Infalíveis do Uso da Crase',
        content:
            '''A **Crase** é a fusão da preposição 'a' com o artigo definido feminino 'a(s)' ou com pronomes demonstrativos (*aquele, aquela, aquilo*).

### Macetes Práticos de Aplicação
1. **Substituição pelo Masculino:** Troque o termo feminino por um masculino equivalente. Se virar **"ao"**, há crase!
   *(Ex: "Fui à feira" -> "Fui ao mercado" => logo, usa crase).*

2. **Antes de Verbos no Infinitivo:** **NUNCA** ocorre crase.
   *(Ex: "Disposto a lutar", "Começou a escrever").*

3. **Antes de Palavras Masculinas:** Não ocorre crase.
   *(Ex: "Pagar a prazo", "Andar a cavalo").*

4. **Antes de Pronomes de Tratamento:** Não ocorre crase *(você, vossa excelência).*''',
        keyTakeaways: const [
          'Vou a, volto de: crase pra quê? Vou a, volto da: crase no A!',
          'Locuções adverbiais femininas têm crase obrigatória: à noite, à tarde, às pressas.',
        ],
        studyTip:
            'Pronomes indefinidos (a todos, a qualquer) repelem artigo feminino, logo nunca admitem crase.',
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // CIÊNCIAS DA NATUREZA
  // -------------------------------------------------------------------------
  BookModel(
    id: 'fisica-mecanica-optica',
    title: 'Física Mecânica & Óptica',
    category: BookCategories.ciencias,
    imageUrl: BookCovers.fisica,
    description:
        'Cinemática, Leis de Newton, Trabalho e Energia Mecânica, além dos fenômenos ópticos de reflexão e refração.',
    readTimeMinutes: 16,
    author: 'Prof. Henrique - Oráculo Ciências',
    tags: const ['física', 'newton', 'mecânica', 'energia', 'óptica'],
    sections: [
      BookSectionModel(
        id: 'fis-1',
        title: '1. As 3 Leis de Newton e Dinâmica',
        content:
            '''As Leis de Newton regem a Dinâmica clássica:

### 1ª Lei de Newton (Inércia)
Todo corpo permanece em seu estado de **repouso** ou de **movimento retilíneo uniforme (MRU)**, a menos que uma força resultante não-nula atue sobre ele.

### 2ª Lei de Newton (Princípio Fundamental da Dinâmica)
`FR = m · a`
A aceleração adquirida é diretamente proporcional à força resultante e inversamente proporcional à massa do objeto.

### 3ª Lei de Newton (Ação e Reação)
Para toda ação, há uma reação de **mesma intensidade**, **mesma direção** e **sentidos opostos**, aplicadas em **CORPOS DIFERENTES** *(portanto, nunca se anulam!).*''',
        keyTakeaways: const [
          'Forças de ação e reação jamais se anulam porque atuam em corpos distintos.',
          'Peso é força gravitacional: P = m · g (massa é invariável, peso varia com a gravidade).',
        ],
        studyTip:
            'Faça sempre o diagrama de corpo livre isolando o objeto antes de somar as forças.',
      ),
    ],
  ),

  BookModel(
    id: 'quimica-geral-organica',
    title: 'Química Geral & Orgânica',
    category: BookCategories.ciencias,
    imageUrl: BookCovers.quimica,
    description:
        'Tabela periódica, estequiometria, ligações químicas e identificação das principais funções orgânicas.',
    readTimeMinutes: 15,
    author: 'Prof. Henrique - Oráculo Ciências',
    tags: const ['química', 'estequiometria', 'orgânica', 'funções'],
    sections: [
      BookSectionModel(
        id: 'qui-1',
        title: '1. Funções Orgânicas Oxigenadas',
        content: '''Identificação dos grupos funcionais oxigenados mais cobrados em vestibulares:

• **Álcool:** Hidroxila `(-OH)` ligada a carbono saturado.

• **Fenol:** Hidroxila `(-OH)` ligada diretamente a anel aromático.

• **Aldeído:** Carbonila `(-C=O)` na extremidade da cadeia (ligada a H).

• **Cetona:** Carbonila `(-C=O)` entre dois átomos de carbono.

• **Ácido Carboxílico:** Carboxila `(-COOH)` na ponta da cadeia.

• **Éster:** Derivado de ácido com cadeia carbônica no lugar do hidrogênio `(-COO-R)`.

• **Éter:** Oxigênio como heteroátomo entre dois carbonos `(-C-O-C-)`.''',
        keyTakeaways: const [
          'Pontes de hidrogênio ocorrem intensamente em álcoois e ácidos carboxílicos, elevando o ponto de ebulição.',
          'Ácidos carboxílicos reagem com álcoois gerando éster e água (Esterificação).',
        ],
        studyTip:
            'Aromas artificiais de doces e frutas quase sempre vêm de ésteres de cadeia curta.',
      ),
    ],
  ),

  BookModel(
    id: 'biologia-celular-genetica',
    title: 'Biologia Celular e Genética',
    category: BookCategories.ciencias,
    imageUrl: BookCovers.biologia,
    description:
        'Organelas celulares, respiração aeróbica, mitose, meiose e as leis mendelianas com aplicações em biotecnologia.',
    readTimeMinutes: 17,
    author: 'Profª. Camila - Oráculo Bio',
    tags: const ['biologia', 'genética', 'célula', 'dna', 'mendel'],
    sections: [
      BookSectionModel(
        id: 'bio-1',
        title: '1. Primeira Lei de Mendel e Hereditariedade',
        content:
            '''A **Primeira Lei de Mendel** *(Princípio da Segregação dos Fatores)* estabelece que cada característica é determinada por um par de fatores (alelos) que se separam durante a formação dos gametas.

### Conceitos Fundamentais
• **Homozigoto:** Indivíduo com alelos iguais `(AA ou aa)`.
• **Heterozigoto:** Indivíduo com alelos diferentes `(Aa)`.
• **Genótipo:** A constituição genética do indivíduo.
• **Fenótipo:** Manifestação física ou fisiológica observável resultante da interação:
`Fenótipo = Genótipo + Ambiente`''',
        keyTakeaways: const [
          'Cruzamento Aa x Aa resulta na proporção fenotípica clássica 3:1 e genotípica 1:2:1.',
          'Em heredogramas, indivíduos afetados com pais não afetados indicam caráter recessivo.',
        ],
        studyTip:
            'Para identificar se uma doença é recessiva em heredogramas, procure o clássico "pais iguais gerando filho diferente". O filho diferente sempre é recessivo!',
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // CIÊNCIAS HUMANAS
  // -------------------------------------------------------------------------
  BookModel(
    id: 'livro-1793723493857',
    title: 'História da Arte',
    category: 'Humanas',
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCRpZKp1o_B2lBdG9FOMc8_l1WDigw3gUXl_wJipLu8w&s=10',
    description:
        'História da Arte na Pré-História e Antiguidade: pinturas rupestres, esculturas de fertilidade e rituais mágicos.',
    readTimeMinutes: 10,
    author: 'Toda Matéria & Oráculo Humanas',
    tags: const ['Artes', 'História', 'Estética', 'Pré-história'],
    sections: [
      BookSectionModel(
        id: 'sec-1',
        title: 'Arte Pré-histórica',
        content: '''Ainda no período pré-histórico, antes da invenção da escrita, o ser humano já produzia manifestações artísticas expressivas. Tudo o que sabemos sobre essas civilizações foi descoberto por pesquisadores através da análise rigorosa de objetos, fósseis e pinturas rupestres.

### As 3 Fases da Pré-História
Esse longo período da humanidade é tradicionalmente dividido em três grandes momentos:

• **Paleolítico Inferior** (aprox. 500 mil a.C.)
• **Paleolítico Superior** (aprox. 30 mil a.C.): Momento em que surgem as primeiras manifestações artísticas complexas, como as famosas pinturas nas cavernas de **Lascaux** (França) e **Altamira** (Espanha).
• **Neolítico** (aprox. 10 mil a.C.): Revolução agrícola, polimento da pedra e fixação das primeiras comunidades humanas.

### Características da Arte no Paleolítico
As primeiras expressões artísticas da humanidade foram encontradas em escavações sobretudo na **Ásia, África e Europa**:

• **Pinturas Rupestres:** Realizadas no interior de cavernas onde os grupos nômades, caçadores e coletores, se abrigavam das intempéries climáticas e dos predadores selvagens.
• **Esculturas Femininas Volumosas:** Estatuetas talhadas em rocha, osso ou madeira com formas avantajadas, associadas diretamente a rituais de **fertilidade e reprodução da espécie**.
• **A Vênus de Willendorf:** Encontrada na Áustria, é o exemplo mais celebre mundialmente da escultura paleolítica.
• **Traços e Símbolos:** Riscos, mãos em negativo e linhas entrelaçadas que demonstram apurada imaginação e simbolismo.

### Finalidade Mágica e Rituais de Sobrevivência
A arte paleolítica estava intimamente conectada à espiritualidade prática e à busca de sobrevivência:

• **Ritual de Iniciação e Caça:** Pintar animais selvagens nas paredes rochosas representava um ritual mágico; acreditava-se que desenhar a presa vulnerável garantia o êxito da caçada no dia seguinte.
• **Integração Homem e Natureza:** Sem a divisão moderna entre utilitário e estético, a arte fazia parte ativa da sobrevivência com forte traço **realista e naturalista**.''',
        keyTakeaways: const [
          'A arte no Paleolítico Superior possuía finalidade mágica e ritualística ligada à caça e à sobrevivência.',
          'As esculturas femininas (como a Vênus de Willendorf) simbolizavam fertilidade e continuidade da vida.',
          'Lascaux (França) e Altamira (Espanha) são os maiores sítios de arte rupestre do mundo.',
        ],
        studyTip:
            'Nas questões do ENEM e vestibulares, lembre-se: a arte rupestre não era decorativa nem para "galerias", e sim um instrumento mágico vital para a sobrevivência do grupo!',
      ),
    ],
  ),
  BookModel(
    id: 'historia-do-brasil',
    title: 'História do Brasil',
    category: BookCategories.humanas,
    imageUrl: BookCovers.historia,
    description:
        'Da colonização e economia açucareira até a Era Vargas, Ditadura Militar e o processo de redemocratização.',
    readTimeMinutes: 19,
    author: 'Prof. André - Oráculo Humanas',
    tags: const ['história', 'brasil', 'vargas', 'ditadura', 'cidadania'],
    sections: [
      BookSectionModel(
        id: 'his-1',
        title: '1. A Era Vargas (1930 - 1945)',
        content:
            '''Getúlio Vargas governou o Brasil por **15 anos consecutivos** nesta primeira fase, dividida em três momentos cruciais:

1. **Governo Provisório (1930 - 1934):**
   • Dissolução do Congresso e nomeação de interventores estaduais.
   • **Revolução Constitucionalista de 1932** em São Paulo.
   • Criação da **Constituição de 1934** (conquista do voto feminino, voto secreto e primeiras leis trabalhistas).

2. **Governo Constitucional (1934 - 1937):**
   • Polarização política entre a **AIB** (integralistas fascistas) e a **ANL** (aliancistas de esquerda).
   • **Intentona Comunista de 1935** e posterior forjamento do fictício **Plano Cohen**.

3. **Estado Novo (1937 - 1945):**
   • Ditadura com outorga da Constituição "Polaca".
   • Forte censura e propaganda pelo **DIP** (Departamento de Imprensa e Propaganda).
   • Criação da **CLT (1943)** e consolidação da indústria de base (CSN, Vale do Rio Doce).''',
        keyTakeaways: const [
          'Vargas praticava o trabalhismo: concedia direitos sociais enquanto controlava os sindicatos através da estrutura corporativista.',
          'A entrada do Brasil na Segunda Guerra ao lado dos Aliados gerou uma contradição insustentável para a ditadura interna, levando à queda de Vargas em 1945.',
        ],
        studyTip:
            'O DIP (Departamento de Imprensa e Propaganda) é tema recorrente no ENEM como instrumento de construção do mito do "Pai dos Pobres".',
      ),
    ],
  ),

  BookModel(
    id: 'filosofia-e-sociologia',
    title: 'Filosofia e Sociologia',
    category: BookCategories.humanas,
    imageUrl: BookCovers.filosofia,
    description:
        'Contratualismo (Hobbes, Locke, Rousseau), Ética, Iluminismo e os clássicos da sociologia: Marx, Weber e Durkheim.',
    readTimeMinutes: 16,
    author: 'Prof. André - Oráculo Humanas',
    tags: const [
      'filosofia',
      'sociologia',
      'ética',
      'contratualismo',
      'durkheim',
    ],
    sections: [
      BookSectionModel(
        id: 'fil-1',
        title: '1. Os Filósofos Contratualistas',
        content:
            '''O **Contratualismo** busca explicar a origem do Estado e da sociedade civil a partir de um pacto entre os homens:

• **Thomas Hobbes (*"O Leviatã"*):**
  No estado de natureza, o homem vive em guerra de todos contra todos (*"o homem é o lobo do homem"*). Para garantir a segurança e a vida, transfere sua liberdade a um **soberano absoluto**.

• **John Locke (*"Segundo Tratado sobre o Governo Civil"*):**
  No estado de natureza, os homens possuem **direitos naturais inalienáveis** (vida, liberdade e propriedade). O Estado surge para assegurar esses direitos; se falhar, o povo tem o direito legítimo de **rebelião**.

• **Jean-Jacques Rousseau (*"O Contrato Social"*):**
  *"O homem nasce bom, a sociedade o corrompe"* (o surgimento da propriedade privada criou as desigualdades). O pacto legítimo deve se basear na **Vontade Geral** e na soberania popular democrática.''',
        keyTakeaways: const [
          'Hobbes defende o absolutismo para conter o medo da morte violenta.',
          'Locke é o pai do liberalismo clássico e defensor da propriedade privada como direito natural.',
          'Rousseau é a base da democracia direta e participativa.',
        ],
        studyTip:
            'Associe Locke a direito à propriedade e rebelião; associe Hobbes a medo e segurança; associe Rousseau a bondade natural e vontade geral.',
      ),
    ],
  ),
];
