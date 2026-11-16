import '../../models/enem_question_model.dart';

/// Questões ENEM para os conteúdos de Redação:
/// 1. Redação Nota 1000 ('redacao-nota-1000') - 10 questões
/// 2. Estrutura Argumentativa ('estrutura-argumentativa') - 10 questões

final List<EnemQuestionModel> redacaoNota1000Questions = [
  const EnemQuestionModel(
    id: 'red-1000-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'A proposta de intervenção na prova de redação do ENEM deve apresentar cinco elementos constitutivos indispensáveis para a obtenção da nota máxima de 200 pontos na Competência 5.',
    questionText:
        'Considere o trecho: "O Ministério da Educação deve, portanto, promover palestras de conscientização nas escolas públicas e privadas, por meio de parcerias com psicólogos especialistas, com o objetivo de reduzir o estigma sobre a saúde mental juvenil."\nNesse fragmento, o elemento que NÃO foi devidamente detalhado para fins de pontuação integral é o:',
    options: [
      'Agente responsável pela ação.',
      'Ação interventiva a ser executada.',
      'Meio ou modo de execução.',
      'Efeito ou finalidade pretendida.',
      'Detalhamento de um dos elementos.',
    ],
    correctOptionIndex: 4,
    explanation:
        'O trecho apresenta agente ("Ministério da Educação"), ação ("promover palestras de conscientização"), meio/modo ("por meio de parcerias com psicólogos") e efeito ("com o objetivo de reduzir o estigma"). Contudo, não há oração explicativa ou desdobramento que configure detalhamento válido (como especificar atribuições do ministério, detalhar os recursos ou o cronograma das palestras).',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'Na avaliação da Competência 2 do ENEM, exige-se que o participante desenvolva o tema proposto a partir de um repertório sociocultural legítimo e produtivo.',
    questionText:
        'Para que um repertório seja considerado "legítimo e com uso produtivo" pela banca corretora do ENEM, ele deve:',
    options: [
      'Limitar-se estritamente aos textos motivadores apresentados na coletânea da prova.',
      'Pertencer a uma área reconhecida do conhecimento (filosofia, história, literatura) e estabelecer vínculo direto com a tese defendida.',
      'Conter ao menos três citações literais decoradas de autores clássicos da sociologia positivista.',
      'Abordar exclusivamente leis federais e artigos da Constituição Brasileira de 1988.',
      'Ser inserido no início da introdução, dispensando qualquer articulação com os parágrafos de desenvolvimento.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A banca do ENEM define repertório legitimado como aquele que possui respaldo em áreas do conhecimento (sociologia, filosofia, arte, ciência, história). O uso produtivo ocorre quando o estudante articula esse repertório organicamente aos argumentos e à tese defendida.',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q3',
    number: 3,
    yearSource: 'ENEM 2023',
    contextText:
        'A tese é o núcleo do texto dissertativo-argumentativo, representando o posicionamento crítico do autor sobre a problemática apresentada.',
    questionText:
        'Na introdução do modelo nota 1000 do ENEM, a formulação mais eficaz da tese consiste em:',
    options: [
      'Expor uma dúvida retórica aberta sem apontar culpados ou responsáveis.',
      'Apresentar de forma explícita dois eixos de problematização (D1 e D2) que serão desdobrados nos parágrafos seguintes.',
      'Copiar integralmente a frase-tema fornecida pela banca para evitar desvios temáticos.',
      'Apresentar logo a proposta de intervenção detalhada para poupar linhas no desfecho.',
      'Narrar um acontecimento pessoal ilustrando como a questão afetou a vida do candidato.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A estrutura nota 1000 consolidada no ENEM utiliza a tese bipartida (ou antecipação argumentativa), em que o candidato aponta dois fatores críticos (ex: a negligência governamental e a herança sociocultural) que guiarão o D1 e o D2.',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q4',
    number: 4,
    yearSource: 'ENEM 2020',
    contextText:
        'A Competência 1 do ENEM avalia a demonstração de domínio da modalidade escrita formal da Língua Portuguesa.',
    questionText:
        'Qual das seguintes construções é penalizada na Competência 1 por truncamento de períodos ou falha de estrutura sintática?',
    options: [
      'Construir períodos complexos articulados por conjunções subordinativas adverbiais causais.',
      'Isolar uma oração subordinada em um período independente por meio de ponto final ("O país enfrenta desafios. Porque a desigualdade persiste.").',
      'Empregar próclise justificada pela presença de palavras com sentido negativo.',
      'Utilizar vírgula antes de conjunções adversativas como "mas" e "porém".',
      'Inserir orações adjetivas explicativas isoladas por vírgulas.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O truncamento de períodos ocorre quando uma oração subordinada é separada da sua oração principal por ponto final indevido, fragmentando a estrutura sintática canônica.',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q5',
    number: 5,
    yearSource: 'ENEM 2023',
    contextText:
        'No ENEM, o respeito aos Direitos Humanos é critério de avaliação da proposta de intervenção na Competência 5.',
    questionText:
        'A violação expressa aos Direitos Humanos na proposta de intervenção acarreta atualmente:',
    options: [
      'Nota zero automática na redação inteira.',
      'Nota zero exclusivamente na Competência 5 (proposta de intervenção).',
      'Penalização de 40 pontos na Competência 3.',
      'Eliminação imediata do candidato do exame.',
      'Desconto cumulativo de 50 pontos em todas as cinco competências.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A partir da decisão judicial acatada pelo MEC e INEP em 2017, a violação aos direitos humanos não anula mais a redação toda, mas zera a Competência 5 (desconto total dos 200 pontos dessa competência).',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'A Competência 3 avalia a capacidade de selecionar, relacionar, organizar e interpretar informações, fatos, opiniões e argumentos em defesa de um ponto de vista (projeto de texto).',
    questionText:
        'Ocorre "falha no projeto de texto" quando o candidato:',
    options: [
      'Utiliza conectivos variados para ligar os parágrafos.',
      'Antecipa argumentos na introdução e os desenvolve rigorosamente no corpo do texto.',
      'Promete discutir um tema na tese da introdução, mas o abandona ou substitui nos desenvolvimentos sem justificativa.',
      'Organiza a redação em exatamente 4 parágrafos simétricos.',
      'Apresenta dados históricos para ilustrar a raiz do problema.',
    ],
    correctOptionIndex: 2,
    explanation:
        'O projeto de texto avalia o planejamento prévio e a coerência global. Se o autor menciona um argumento na tese mas não o fundamenta, ou insere ideias desconexas não anunciadas, caracteriza-se quebra do projeto de texto.',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'Na redação do ENEM, a tangenciação ao tema é um dos erros estruturais mais severos cometidos pelos candidatos.',
    questionText:
        'Se o tema for "O estigma associado às doenças mentais na sociedade brasileira" e o candidato redigir o texto falando apenas sobre os avanços da medicina e hospitais no Brasil, ignorando as palavras "estigma" e "doenças mentais", sua redação será classificada como:',
    options: [
      'Texto com abordagem completa com penalidade branda.',
      'Fuga total ao tema (anulação / nota zero).',
      'Tangenciamento ao tema, recebendo nota máxima de 40 pontos nas competências 2, 3 e 5.',
      'Redação exemplar por focar em soluções práticas da saúde.',
      'Desvio exclusivo da Competência 1.',
    ],
    correctOptionIndex: 2,
    explanation:
        'A tangenciação ocorre quando o participante aborda apenas o assunto mais amplo (saúde pública/medicina) e deixa de lado o núcleo temático específico delimitado pela proposta (o preconceito e o estigma das doenças mentais). No ENEM, tangenciamento limita severamente a pontuação.',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'A coesão interparágrafo e intraparágrafo é avaliada pela Competência 4 da matriz do ENEM.',
    questionText:
        'Para alcançar a faixa máxima (200 pontos) na Competência 4, a redação deve apresentar obrigatoriamente:',
    options: [
      'Presença expressiva de elementos coesivos interparágrafos (em ao menos 2 momentos de transição) e diversidade de conectivos dentro dos parágrafos, com raras ou nenhuma repetição.',
      'Uso da conjunção coordenativa "e" como elemento universal de abertura de todos os parágrafos.',
      'Ausência total de pronomes anafóricos para não comprometer a precisão lexical.',
      'Exclusividade de conectivos de oposição como "todavia" e "contudo" em todas as frases.',
      'Início do primeiro parágrafo com conjunções conclusivas como "Portanto" ou "Logo".',
    ],
    correctOptionIndex: 0,
    explanation:
        'A grade oficial do ENEM estipula que a nota máxima na Competência 4 requer operadores argumentativos interparágrafos em no mínimo dois pontos de transição (início do D2 e início da Conclusão) além de repertório coesivo diversificado e sem repetições viciosas.',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q9',
    number: 9,
    yearSource: 'ENEM 2019',
    contextText:
        'Em um desenvolvimento argumentativo eficiente, o candidato deve formular um "tópico frasal" conciso.',
    questionText:
        'A função primordial do tópico frasal no início de um parágrafo de desenvolvimento é:',
    options: [
      'Narrar uma anedota ou metáfora literária de teor poético.',
      'Sintetizar com clareza e objetividade o argumento central que será fundamentado ao longo do parágrafo.',
      'Apresentar imediatamente a proposta de intervenção social para adiantar a conclusão.',
      'Citar todas as fontes estatísticas que serão interpretadas na conclusão.',
      'Questionar o leitor sobre a veracidade do tema sem tomar posição.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O tópico frasal funciona como a oração nuclear do parágrafo: ele enuncia com assertividade a ideia-força que será defendida e explicada pelas orações subsequentes.',
  ),
  const EnemQuestionModel(
    id: 'red-1000-q10',
    number: 10,
    yearSource: 'ENEM 2023',
    contextText:
        'O desfecho do parágrafo de desenvolvimento (circuito argumentativo fechado) garante consistência lógica ao raciocínio.',
    questionText:
        'Para encerrar produtivamente um parágrafo de desenvolvimento no modelo nota 1000, recomenda-se:',
    options: [
      'Deixar a frase inacabada com reticências para provocar suspense no corretor.',
      'Inserir uma frase conclusiva com juízo de valor crítico, demonstrando como a discussão impacta negativamente a sociedade ou reforça a tese.',
      'Iniciar a citação de um autor inédito sem comentá-lo.',
      'Repetir a frase inicial da introdução sem qualquer alteração vocabular.',
      'Fazer um apelo emocional religioso ou doutrinário.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Um desenvolvimento robusto fecha o circuito argumentativo com uma oração crítica conclusiva (desfecho crítico), demonstrando explicitamente as consequências sociais daquele problema e reafirmando a tese.',
  ),
];

final List<EnemQuestionModel> estruturaArgumentativaQuestions = [
  const EnemQuestionModel(
    id: 'arg-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'Os operadores argumentativos orientam a conclusão a ser extraída dos enunciados e estabelecem hierarquias de força persuasiva.',
    questionText:
        'Considere o período: "A ampliação do acesso à internet é urgente, ______ a inclusão digital combate a perpetuação das desigualdades socioeconômicas."\nA conjunção que estabelece adequadamente a relação de causa e fundamentação lógica é:',
    options: [
      'porquanto',
      'conquanto',
      'contudo',
      'embora',
      'portanto',
    ],
    correctOptionIndex: 0,
    explanation:
        '"Porquanto" é conjunção causal/explicativa (equivalente a "já que", "porque", "visto que"). "Conquanto" e "embora" são concessivas; "contudo" é adversativa; "portanto" é conclusiva.',
  ),
  const EnemQuestionModel(
    id: 'arg-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'A contra-argumentação é uma estratégia persuasiva avançada em textos de opinião e ensaios dissertativos.',
    questionText:
        'Ao utilizar uma estratégia de contra-argumentação com operador concessivo ("Ainda que...", "Embora..."), o autor busca:',
    options: [
      'Concordar integralmente com a posição contrária, anulando a própria tese.',
      'Reconhecer um ponto do argumento opositor para, em seguida, refutá-lo ou superá-lo com um argumento de peso maior.',
      'Demonstrar dúvida e incerteza científica a respeito do tema abordado.',
      'Evitar a apresentação de dados estatísticos concretos.',
      'Finalizar o texto sem a necessidade de proposta de intervenção.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A concessão argumentativa admite momentaneamente a validade de uma perspectiva oposta para em seguida demonstrar que o seu argumento principal prevalece, conferindo maturidade e solidez ao texto.',
  ),
  const EnemQuestionModel(
    id: 'arg-q3',
    number: 3,
    yearSource: 'ENEM 2023',
    contextText:
        'A coesão referencial por anáfora e catáfora impede repetições enfadonhas de palavras no texto.',
    questionText:
        'Em "A falta de saneamento básico afeta milhões de cidadãos. Esse flagelo decorre do descaso do poder público", a expressão "Esse flagelo" exerce o papel de:',
    options: [
      'Catáfora antecipatória de um elemento ainda não mencionado.',
      'Anáfora com hiperônimo de teor valorativo, retomando o problema da falta de saneamento.',
      'Pleonasmo vicioso que prejudica a fluidez estilística.',
      'Elipse do sujeito indeterminado da oração.',
      'Operador discursivo puramente de oposição temporal.',
    ],
    correctOptionIndex: 1,
    explanation:
        '"Esse flagelo" é uma anáfora (retoma elemento anterior) que emprega um substantivo com carga crítica (juízo de valor), enriquecendo o vocabulário e a progressão temática.',
  ),
  const EnemQuestionModel(
    id: 'arg-q4',
    number: 4,
    yearSource: 'ENEM 2020',
    contextText:
        'O argumento de autoridade baseia-se na sustentação de uma tese por meio do saber reconhecido de especialistas ou instituições idôneas.',
    questionText:
        'Para que um argumento de autoridade não se transforme em uma falácia de apelo à autoridade, é indispensável que:',
    options: [
      'A autoridade citada seja uma celebridade com mais de um milhão de seguidores em mídias digitais.',
      'O especialista ou órgão citado tenha competência comprovada na área específica em debate e sua constatação dialogue com os fatos analisados.',
      'A citação seja reproduzida obrigatoriamente em latim clássico.',
      'O argumento seja blindado contra qualquer tipo de comparação com a realidade brasileira.',
      'A frase seja transcrita com mais de seis linhas de extensão ininterruptas.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Um argumento de autoridade legítimo fundamenta-se na legitimidade acadêmica ou institucional da fonte na matéria em pauta e em sua relação lógica e demonstrável com a tese.',
  ),
  const EnemQuestionModel(
    id: 'arg-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'A relação de causa e consequência é uma das técnicas mais eficazes de estruturação do parágrafo de desenvolvimento.',
    questionText:
        'Em uma cadeia de causa e efeito coerente sobre a evasão escolar, qual sequência expressa a lógica argumentativa correta?',
    options: [
      'A evasão escolar ocorre como causa da gravidez na infância, gerando como efeito a criação de creches públicas.',
      'A vulnerabilidade socioeconômica extrema compele o jovem ao trabalho precoce (causa), culminando no abandono dos estudos (consequência).',
      'O abandono escolar precoce acarreta o imediato aumento de vagas no ensino superior.',
      'A abundância de recursos didáticos nas escolas públicas gera a desmotivação dos alunos.',
      'A aprovação universal automática de notas é a única causa biológica da evasão infantil.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A lógica causal exige relação de causalidade plausível e comprovável: a necessidade imediata de renda devido à pobreza compele o aluno a priorizar o trabalho informal, resultando na evasão escolar.',
  ),
  const EnemQuestionModel(
    id: 'arg-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'Marcadores de pressuposição e subentendido interferem na orientação argumentativa de um texto.',
    questionText:
        'No enunciado: "O governo finalmente sancionou a lei de proteção aos povos originários", o vocábulo "finalmente" introduz o pressuposto de que:',
    options: [
      'A sanção da lei ocorreu com excessiva rapidez e antes do prazo previsto.',
      'A medida era aguardada há muito tempo e houve demora ou lentidão até sua concretização.',
      'A lei não terá nenhuma eficácia prática na realidade.',
      'O governo discorda integralmente do conteúdo sancionado.',
      'O autor do texto se opõe à criação de leis para os povos indígenas.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O advérbio "finalmente" carrega o valor semântico de expectativa prolongada ou morosidade anterior, indicando que a ação demorou a se consumar.',
  ),
  const EnemQuestionModel(
    id: 'arg-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'O uso de dados estatísticos na dissertação objetiva fundamentar hipóteses com evidências fáticas.',
    questionText:
        'Ao utilizar dados do IBGE ou IPEA no texto, a postura argumentativa ideal exigida pelo ENEM é:',
    options: [
      'Copiar longas tabelas de números sem qualquer interpretação crítica do seu significado social.',
      'Interpretar criticamente o número, demonstrando o que ele revela sobre a gravidade ou as causas da mazela abordada.',
      'Inventar porcentagens aproximadas caso não se recorde dos dados oficiais.',
      'Usar os números apenas para comprovar que o problema já foi 100% resolvido no país.',
      'Restringir a apresentação dos dados exclusivamente à conclusão da redação.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Na redação dissertativo-argumentativa do ENEM, os dados estatísticos devem vir acompanhados de reflexão crítica que evidencie sua implicação com a tese defendida.',
  ),
  const EnemQuestionModel(
    id: 'arg-q8',
    number: 8,
    yearSource: 'ENEM 2023',
    contextText:
        'Conectivos como "Outrossim", "Ademais" e "Além disso" desempenham papel estruturador específico.',
    questionText:
        'Esses operadores argumentativos são classificados predominantemente como marcadores de:',
    options: [
      'Oposição e quebra de expectativa.',
      'Soma e adição cumulativa de argumentos.',
      'Conclusão e encerramento de raciocínio.',
      'Condição e causalidade hipotética.',
      'Concessão e ressalva factual.',
    ],
    correctOptionIndex: 1,
    explanation:
        '"Ademais", "Outrossim" e "Além disso" são conectivos aditivos que introduzem um novo argumento em consonância com o anterior, muito utilizados para abrir o D2.',
  ),
  const EnemQuestionModel(
    id: 'arg-q9',
    number: 9,
    yearSource: 'ENEM 2020',
    contextText:
        'A alusão histórica contextualiza a gênese temporal de problemáticas contemporâneas.',
    questionText:
        'Para que uma alusão histórica seja produtiva na argumentação sobre o racismo estrutural no Brasil, o candidato deve:',
    options: [
      'Afirmar que a escravidão foi um período harmônico de integração social pacífica.',
      'Demonstrar como a ausência de políticas de integração dos ex-escravizados após a Lei Áurea perpetuou a marginalização social até os dias atuais.',
      'Narrar minuciosamente a biografia completa de todos os monarcas do Brasil Império.',
      'Limitar-se a indicar o ano de 1500 sem relacioná-lo com a questão racial contemporânea.',
      'Condenar o uso de fontes históricas em debates sobre o presente.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A produtividade da alusão histórica reside no fio condutor entre passado e presente: a abolição formal em 1888 sem medidas de inclusão gerou raízes estruturais na desigualdade racial do Brasil de hoje.',
  ),
  const EnemQuestionModel(
    id: 'arg-q10',
    number: 10,
    yearSource: 'ENEM 2018',
    contextText:
        'A falácia da generalização precipitada enfraquece a credibilidade de um texto argumentativo.',
    questionText:
        'Constitui exemplo de falácia de generalização indevida que deve ser evitada na redação:',
    options: [
      '"Pesquisas apontam que parcelas expressivas da população ainda não dispõem de água tratada."',
      '"Todos os jovens brasileiros são alienados e não se importam com questões ecológicas."',
      '"A negligência do Estado em regiões periféricas acentua o abismo da desigualdade social."',
      '"Alguns municípios brasileiros implementaram com sucesso a coleta seletiva de lixo."',
      '"O acesso a bens culturais no interior do país permanece amplamente restrito."',
    ],
    correctOptionIndex: 1,
    explanation:
        'Afirmações totalizantes ("todos os jovens...", "ninguém estuda...") constituem generalizações precipitadas, facilmente refutáveis e que fragilizam o rigor argumentativo avaliado na Competência 3.',
  ),
];
