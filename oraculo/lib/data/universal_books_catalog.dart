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
    description: 'Guia definitivo para dominar o texto dissertativo-argumentativo do ENEM, com estruturas, repertórios e modelos práticos.',
    readTimeMinutes: 15,
    author: 'Equipe de Redação Oráculo',
    tags: const ['redação', 'enem', 'nota 1000', 'dissertação', 'vestibular'],
    sections: [
      BookSectionModel(
        id: 'red-1',
        title: '1. O Esqueleto do Texto Nota 1000',
        content: '''A redação do ENEM exige uma estrutura dissertativa-argumentativa dividida rigidamente em 4 parágrafos:

• Parágrafo 1 - Introdução: Apresentação do tema + contextualização (repertório) + tese com 2 argumentos (D1 e D2).
• Parágrafo 2 - Desenvolvimento 1: Tópico frasal relacionado ao primeiro argumento + fundamentação teórica + desfecho crítico.
• Parágrafo 3 - Desenvolvimento 2: Tópico frasal do segundo argumento + dados ou citação + consequência social.
• Parágrafo 4 - Conclusão: Proposta de intervenção completa com os 5 elementos obrigatórios (Agente, Ação, Meio/Modo, Efeito e Detalhamento).''',
        keyTakeaways: const [
          'Mantenha sempre 4 parágrafos bem equilibrados (7 a 8 linhas cada).',
          'Sua tese deve conter explicitamente as duas causas que serão debatidas em D1 e D2.',
          'Nunca deixe de contextualizar o tema logo na primeira linha.',
        ],
        studyTip: 'Evite frases longas demais na introdução. O leitor precisa entender sua tese já no primeiro olhar.',
      ),
      BookSectionModel(
        id: 'red-2',
        title: '2. Proposta de Intervenção Nota Máxima (200 pts)',
        content: '''A competência 5 avalia a capacidade de propor uma solução aos problemas discutidos. Para alcançar a pontuação máxima de 200 pontos, seu parágrafo DEVE conter:

1. AGENTE: Quem executará a ação? (Ex: Ministério da Educação, Governo Federal, Mídia).
2. AÇÃO: O que será feito? (Ex: Deve instituir campanhas educativas permanentes).
3. MEIO / MODO: Como será feito? (Ex: Por intermédio de parcerias público-privadas e redes sociais).
4. EFEITO / FINALIDADE: Para que serve? (Ex: Com o intuito de democratizar o acesso à informação).
5. DETALHAMENTO: Uma informação adicional sobre um dos 4 itens acima (Ex: detalhando a ação com exemplos ou o agente com suas atribuições constitucionais).''',
        keyTakeaways: const [
          'Sempre confira os 5 elementos antes de passar o texto a limpo.',
          'O detalhamento pode ser uma oração explicativa como: ", órgão responsável por..."',
          'Respeite sempre os direitos humanos!',
        ],
        studyTip: 'Use o conectivo "Portanto," para iniciar o parágrafo de conclusão e indicar fechamento lógico.',
      ),
    ],
  ),

  BookModel(
    id: 'estrutura-argumentativa',
    title: 'Estrutura Argumentativa',
    category: BookCategories.redacao,
    imageUrl: BookCovers.cadernos,
    description: 'Como encadear argumentos consistentes, usar conectivos interparágrafos e evitar falhas de coerência.',
    readTimeMinutes: 12,
    author: 'Equipe de Redação Oráculo',
    tags: const ['argumentação', 'coesão', 'conectivos', 'coerência'],
    sections: [
      BookSectionModel(
        id: 'arg-1',
        title: '1. Conectivos Interparágrafos Essenciais',
        content: '''Para garantir a nota máxima na Competência 4 (coesão), é obrigatório utilizar conectivos interparágrafos (no início do D2 e da Conclusão):

• No início do D2: "Ademais,", "Outrossim,", "Além disso,", "Por outro lado," (caso seja uma antítese).
• No início da Conclusão: "Portanto,", "Em suma,", "Dessa maneira,", "Destarte,".

Dentro dos parágrafos, garanta pelo menos dois conectivos intraparágrafos em cada um: "Nesse sentido,", "Com efeito,", "Por conseguinte,", "Logo,".''',
        keyTakeaways: const [
          'Nunca inicie o D2 sem um conectivo interparágrafo.',
          'Varie o vocabulário para evitar repetições excessivas da mesma conjunção.',
        ],
        studyTip: 'Cuidado com "Sob esse viés" no primeiro parágrafo: só use conectivos referenciais se houver algo anterior a que se referir!',
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
    description: 'Estudo aprofundado de funções de 1º e 2º grau, gráficos, vértices, máximos e mínimos aplicados a questões reais.',
    readTimeMinutes: 18,
    author: 'Prof. Carlos - Oráculo Exatas',
    tags: const ['matemática', 'funções', 'álgebra', 'gráfico', 'enem'],
    sections: [
      BookSectionModel(
        id: 'mat-1',
        title: '1. Função Afim (1º Grau)',
        content: '''A função afim possui a lei de formação:
f(x) = ax + b (com a ≠ 0)

• 'a' é o coeficiente angular (taxa de variação). Se a > 0 a reta é crescente; se a < 0 é decrescente.
• 'b' é o coeficiente linear (o ponto exato onde a reta intercepta o eixo Y, ou seja, f(0) = b).

Zero ou Raiz da Função:
ax + b = 0  =>  x = -b / a''',
        keyTakeaways: const [
          'Taxa de variação: a = Δy / Δx',
          'O coeficiente linear representa o valor fixo em problemas cotidianos (ex: taxa fixa de táxi).',
        ],
        studyTip: 'Em gráficos de função afim no ENEM, identifique primeiro o ponto em que a reta cruza o eixo vertical Y: esse é imediatamente o seu termo independente b!',
      ),
      BookSectionModel(
        id: 'mat-2',
        title: '2. Função Quadrática e Vértice da Parábola',
        content: '''A função do 2º grau tem a forma:
f(x) = ax² + bx + c (com a ≠ 0)

O Vértice V(Xv, Yv) indica o ponto de máximo ou de mínimo:
• Xv = -b / (2a)
• Yv = -Δ / (4a) onde Δ = b² - 4ac

Se a > 0: a parábola tem concavidade para cima e o vértice é ponto de MÍNIMO.
Se a < 0: a parábola tem concavidade para baixo e o vértice é ponto de MÁXIMO.''',
        keyTakeaways: const [
          'Quando a questão pedir "qual o valor que gera o lucro máximo", calcula-se Xv.',
          'Quando a questão pedir "qual é o lucro máximo obtido", calcula-se Yv.',
        ],
        studyTip: 'Você também pode achar o Yv substituindo o Xv calculado diretamente na função f(Xv), sem precisar calcular Δ!',
      ),
    ],
  ),

  BookModel(
    id: 'geometria-espacial',
    title: 'Geometria Espacial',
    category: BookCategories.matematica,
    imageUrl: BookCovers.geometria,
    description: 'Fórmulas essenciais de prismas, cilindros, cones, esferas e pirâmides com macetes de cálculo de volume.',
    readTimeMinutes: 14,
    author: 'Prof. Carlos - Oráculo Exatas',
    tags: const ['geometria', 'espacial', 'volumes', 'prismas', 'cilindros'],
    sections: [
      BookSectionModel(
        id: 'geo-1',
        title: '1. Sólidos de Seção Constante (Prismas e Cilindros)',
        content: '''Todos os sólidos com bases paralelas e idênticas seguem a mesma regra fundamental de volume:

Volume = Área da Base × Altura (V = Ab · h)

• Prisma Retangular (Paralelepípedo): V = a · b · c
• Cubo: V = a³
• Cilindro Reto: V = (π · r²) · h
• Área lateral do cilindro: Al = 2 · π · r · h''',
        keyTakeaways: const [
          'Cilindro é apenas um prisma de base circular.',
          'Fique atento às conversões de unidades: 1 m³ = 1.000 L e 1 cm³ = 1 mL.',
        ],
        studyTip: 'No ENEM é comum aproximar π por 3 ou 3,14. Sempre leia com atenção o comando do enunciado!',
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
    description: 'Panorama das escolas literárias brasileiras: Romantismo, Realismo, Naturalismo, Modernismo e autores centrais.',
    readTimeMinutes: 20,
    author: 'Profª. Beatriz - Oráculo Letras',
    tags: const ['literatura', 'machado de assis', 'modernismo', 'enem'],
    sections: [
      BookSectionModel(
        id: 'lit-1',
        title: '1. O Realismo e Machado de Assis',
        content: '''O Realismo no Brasil tem marco inicial em 1881 com a publicação de "Memórias Póstumas de Brás Cubas".

Principais características machadianas:
• Narrador não confiável e irônico.
• Análise psicológica profunda das personagens.
• Crítica mordaz à hipocrisia da elite burguesa carioca do Segundo Reinado.
• Metalinguagem e diálogo direto com o leitor ("Que leitor amigo...")
• Fragmentação narrativa e digressões reflexivas.''',
        keyTakeaways: const [
          'Diferente do Romantismo idealizado, o Realismo desnuda o adultério, a falsidade e as ambições materiais.',
          'Dom Casmurro e a dúvida sobre Capitu simbolizam o ciúme e a ótica distorcida de Bentinho.',
        ],
        studyTip: 'Nas provas, foque no tom irônico: Machado nunca diz abertamente o que condena; ele finge elogiar para expor a decadência moral.',
      ),
    ],
  ),

  BookModel(
    id: 'gramatica-e-interpretacao',
    title: 'Gramática e Interpretação',
    category: BookCategories.linguagens,
    imageUrl: BookCovers.linguagens,
    description: 'Sintaxe aplicada, regência, crase, concordância e leitura analítica de textos verbais e não-verbais.',
    readTimeMinutes: 14,
    author: 'Profª. Beatriz - Oráculo Letras',
    tags: const ['gramática', 'crase', 'sintaxe', 'concordância'],
    sections: [
      BookSectionModel(
        id: 'gram-1',
        title: '1. Regras Infalíveis do Uso da Crase',
        content: '''A crase é a fusão da preposição 'a' com o artigo definido feminino 'a(s)' ou pronomes aquele(s), aquela(s).

Macetes práticos:
1. Substitua a palavra feminina seguinte por um termo masculino correspondente. Se virar "ao", há crase!
   Ex: "Fui à feira" -> "Fui ao mercado" (Logo, usa crase).
2. Diante de verbos no infinitivo: NUNCA ocorre crase (Ex: disposto a lutar).
3. Diante de palavras masculinas: Não ocorre crase (Ex: pagar a prazo).
4. Diante de pronomes de tratamento (você, vossa excelência): Não ocorre crase.''',
        keyTakeaways: const [
          'Vou a, volto de: crase pra quê? Vou a, volto da: crase no A!',
          'Locuções adverbiais femininas têm crase obrigatória: à noite, à tarde, às pressas.',
        ],
        studyTip: 'Pronomes indefinidos (a todos, a qualquer) repelem artigo feminino, logo nunca admitem crase.',
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
    description: 'Cinemática, Leis de Newton, Trabalho e Energia Mecânica, além dos fenômenos ópticos de reflexão e refração.',
    readTimeMinutes: 16,
    author: 'Prof. Henrique - Oráculo Ciências',
    tags: const ['física', 'newton', 'mecânica', 'energia', 'óptica'],
    sections: [
      BookSectionModel(
        id: 'fis-1',
        title: '1. As 3 Leis de Newton e Dinâmica',
        content: '''1ª Lei (Inércia): Todo corpo permanece em seu estado de repouso ou de movimento retilíneo uniforme (MRU), a menos que uma força resultante atue sobre ele.
2ª Lei (Princípio Fundamental da Dinâmica):
FR = m · a
A aceleração adquirida é diretamente proporcional à força resultante e inversamente proporcional à massa.
3ª Lei (Ação e Reação): Para toda ação, há uma reação de mesma intensidade, mesma direção e sentidos opostos, aplicadas em CORPOS DIFERENTES (portanto, nunca se anulam!).''',
        keyTakeaways: const [
          'Forças de ação e reação jamais se anulam porque atuam em corpos distintos.',
          'Peso é força gravitacional: P = m · g (massa é invariável, peso varia com a gravidade).',
        ],
        studyTip: 'Faça sempre o diagrama de corpo livre isolando o objeto antes de somar as forças.',
      ),
    ],
  ),

  BookModel(
    id: 'quimica-geral-organica',
    title: 'Química Geral & Orgânica',
    category: BookCategories.ciencias,
    imageUrl: BookCovers.quimica,
    description: 'Tabela periódica, estequiometria, ligações químicas e identificação das principais funções orgânicas.',
    readTimeMinutes: 15,
    author: 'Prof. Henrique - Oráculo Ciências',
    tags: const ['química', 'estequiometria', 'orgânica', 'funções'],
    sections: [
      BookSectionModel(
        id: 'qui-1',
        title: '1. Funções Orgânicas Oxigenadas',
        content: '''Identificação dos grupos funcionais mais cobrados no ENEM:

• Álcool: Hidroxila (-OH) ligada a carbono saturado.
• Fenol: Hidroxila (-OH) ligada diretamente a anel aromático.
• Aldeído: Carbonila (-C=O) na extremidade da cadeia (ligada a H).
• Cetona: Carbonila (-C=O) entre dois carbonos.
• Ácido Carboxílico: Carboxila (-COOH) na ponta da cadeia.
• Éster: Derivado de ácido carboxílico com cadeia carbônica no lugar do H (-COO-R).
• Éter: Oxigênio como heteroátomo entre dois carbonos (-C-O-C-).''',
        keyTakeaways: const [
          'Pontes de hidrogênio ocorrem intensamente em álcoois e ácidos carboxílicos, elevando o ponto de ebulição.',
          'Ácidos carboxílicos reagem com álcoois gerando éster e água (Esterificação).',
        ],
        studyTip: 'Aromas artificiais de doces e frutas quase sempre vêm de ésteres de cadeia curta.',
      ),
    ],
  ),

  BookModel(
    id: 'biologia-celular-genetica',
    title: 'Biologia Celular e Genética',
    category: BookCategories.ciencias,
    imageUrl: BookCovers.biologia,
    description: 'Organelas celulares, respiração aeróbica, mitose, meiose e as leis mendelianas com aplicações em biotecnologia.',
    readTimeMinutes: 17,
    author: 'Profª. Camila - Oráculo Bio',
    tags: const ['biologia', 'genética', 'célula', 'dna', 'mendel'],
    sections: [
      BookSectionModel(
        id: 'bio-1',
        title: '1. Primeira Lei de Mendel e Hereditariedade',
        content: '''A Primeira Lei de Mendel (Princípio da Segregação dos Fatores) estabelece que cada característica é determinada por um par de fatores (alelos) que se separam na formação dos gametas.

• Homozigoto: Indivíduo com alelos iguais (AA ou aa).
• Heterozigoto: Indivíduo com alelos diferentes (Aa).
• Genótipo: Constituição genética do indivíduo.
• Fenótipo: Manifestação física ou fisiológica resultante do genótipo interagindo com o meio ambiente (Fenótipo = Genótipo + Ambiente).''',
        keyTakeaways: const [
          'Cruzamento Aa x Aa resulta na proporção fenotípica clássica 3:1 e genotípica 1:2:1.',
          'Em heredogramas, indivíduos afetados com pais não afetados indicam caráter recessivo.',
        ],
        studyTip: 'Para identificar se uma doença é recessiva em heredogramas, procure o clássico "pais iguais gerando filho diferente". O filho diferente sempre é recessivo!',
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // CIÊNCIAS HUMANAS
  // -------------------------------------------------------------------------
  BookModel(
    id: 'historia-do-brasil',
    title: 'História do Brasil',
    category: BookCategories.humanas,
    imageUrl: BookCovers.historia,
    description: 'Da colonização e economia açucareira até a Era Vargas, Ditadura Militar e o processo de redemocratização.',
    readTimeMinutes: 19,
    author: 'Prof. André - Oráculo Humanas',
    tags: const ['história', 'brasil', 'vargas', 'ditadura', 'cidadania'],
    sections: [
      BookSectionModel(
        id: 'his-1',
        title: '1. A Era Vargas (1930 - 1945)',
        content: '''Getúlio Vargas governou o Brasil por 15 anos consecutivos nesta primeira fase, dividida em três momentos:

1. Governo Provisório (1930-1934): Dissolução do Congresso, Revolução Constitucionalista de 1932 em SP e criação da Constituição de 1934 (voto feminino, voto secreto e leis trabalhistas).
2. Governo Constitucional (1934-1937): Polarização política entre a AIB (integralistas fascistas) e a ANL (aliancistas de esquerda). Intentona Comunista de 1935 e forjamento do Plano Cohen.
3. Estado Novo (1937-1945): Ditadura com outorga da Constituição "Polaca", forte censura pelo DIP, propaganda estatal, criação da CLT (1943) e industrialização de base (CSN, Vale do Rio Doce).''',
        keyTakeaways: const [
          'Vargas praticava o trabalhismo: concedia direitos sociais enquanto controlava os sindicatos através da estrutura corporativista.',
          'A entrada do Brasil na Segunda Guerra ao lado dos Aliados gerou uma contradição insustentável para a ditadura interna, levando à queda de Vargas em 1945.',
        ],
        studyTip: 'O DIP (Departamento de Imprensa e Propaganda) é tema recorrente no ENEM como instrumento de construção do mito do "Pai dos Pobres".',
      ),
    ],
  ),

  BookModel(
    id: 'filosofia-e-sociologia',
    title: 'Filosofia e Sociologia',
    category: BookCategories.humanas,
    imageUrl: BookCovers.filosofia,
    description: 'Contratualismo (Hobbes, Locke, Rousseau), Ética, Iluminismo e os clássicos da sociologia: Marx, Weber e Durkheim.',
    readTimeMinutes: 16,
    author: 'Prof. André - Oráculo Humanas',
    tags: const ['filosofia', 'sociologia', 'ética', 'contratualismo', 'durkheim'],
    sections: [
      BookSectionModel(
        id: 'fil-1',
        title: '1. Os Filósofos Contratualistas',
        content: '''O Contratualismo busca explicar a origem do Estado e da sociedade civil a partir de um pacto entre os homens:

• Thomas Hobbes ("O Leviatã"): O homem no estado de natureza vive em guerra de todos contra todos ("o homem é o lobo do homem"). Para garantir a segurança e a vida, transfere sua liberdade a um soberano absoluto.
• John Locke ("Segundo Tratado sobre o Governo Civil"): No estado de natureza, os homens possuem direitos naturais (vida, liberdade e propriedade). O Estado surge para assegurar esses direitos; se falhar, o povo tem o direito de rebelião.
• Jean-Jacques Rousseau ("O Contrato Social"): "O homem nasce bom, a sociedade o corrompe" (surgimento da propriedade privada criou as desigualdades). O pacto legítimo deve se basear na Vontade Geral e na soberania popular.''',
        keyTakeaways: const [
          'Hobbes defende o absolutismo para conter o medo da morte violenta.',
          'Locke é o pai do liberalismo clássico e defensor da propriedade privada como direito natural.',
          'Rousseau é a base da democracia direta e participativa.',
        ],
        studyTip: 'Associe Locke a direito à propriedade e rebelião; associe Hobbes a medo e segurança; associe Rousseau a bondade natural e vontade geral.',
      ),
    ],
  ),
];
