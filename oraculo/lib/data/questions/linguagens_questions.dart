import '../../models/enem_question_model.dart';

/// Questões ENEM para os conteúdos de Linguagens:
/// 1. Literatura e Clássicos ('literatura-e-classicos') - 10 questões
/// 2. Gramática e Interpretação ('gramatica-e-interpretacao') - 10 questões

final List<EnemQuestionModel> literaturaEClassicosQuestions = [
  const EnemQuestionModel(
    id: 'lit-cla-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'Texto: "Ao verme que primeiro roeu as frias carnes do meu cadáver dedico como saudosa lembrança estas Memórias Póstumas." (Machado de Assis, Memórias Póstumas de Brás Cubas).',
    questionText:
        'A célebre dedicatória machadiana rompe com a tradição romântica do século XIX ao evidenciar:',
    options: [
      'A glorificação da vida eterna e a certeza dogmática da salvação espiritual.',
      'O tom de ironia corrosiva, pessimismo existencial e desfaçatez aristocrática do narrador defunto.',
      'A exaltação patriótica do solo brasileiro em sintonia com o indianismo.',
      'A submissão piedosa do autor perante as instituições religiosas do Império.',
      'A recusa da crueza material da morte em benefício do lirismo sentimental.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Machado de Assis instaura o Realismo no Brasil ao subverter o sentimentalismo romântico: o narrador Brás Cubas, já morto, olha para a própria existência com ironia desiludida e dedica sua obra friamente a um verme, desmistificando a hipocrisia social.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'Texto: "No meio do caminho tinha uma pedra / tinha uma pedra no meio do caminho / tinha uma pedra / no meio do caminho tinha uma pedra." (Carlos Drummond de Andrade).',
    questionText:
        'O poema drummondiano causou escândalo na época de sua publicação no Modernismo de 1928 porque:',
    options: [
      'Violou as regras canônicas do parnasianismo por meio da repetição obsessiva, linguagem coloquial e valorização da polissemia cotidiana.',
      'Utilizou sonetos clássicos camonianos com rimas ricas e métrica decassilábica.',
      'Pregava a volta dos valores estéticos da Idade Média e do Trovadorismo.',
      'Abordava temas exclusivamente campestres no estilo arcádico do século XVIII.',
      'Recusava o uso de metáforas sobre os obstáculos e limites da condição humana.',
    ],
    correctOptionIndex: 0,
    explanation:
        'Drummond chocou a crítica conservadora ao usar a repetição antilírica da palavra "pedra", rompendo radicalmente com a eloquência parnasiana e transformando o obstáculo simples em potente metáfora existencial moderna.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q3',
    number: 3,
    yearSource: 'ENEM 2020',
    contextText:
        'Texto: O romance "O Cortiço" (1890), de Aluísio Azevedo, é o ápice do Naturalismo no Brasil, retratando o crescimento desordenado de habitações coletivas no Rio de Janeiro.',
    questionText:
        'A concepção determinista e a zoomorfização dos personagens no romance naturalista revelam:',
    options: [
      'A crença romântica no livre-arbítrio absoluto e na pureza inata dos sentimentos humanos.',
      'A influência das teorias cientificistas do século XIX (evolucionismo e determinismo do meio, raça e momento histórico).',
      'O elogio da aristocracia agrária como classe guardiã da virtude moral da nação.',
      'A idealização lírica dos operários como heróis mitológicos intocáveis pelo vício.',
      'O desapego à descrição sensorial e aos detalhes fisiológicos e patológicos.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O Naturalismo retrata o indivíduo como refém das forças biológicas, do instinto animal e do ambiente social (zoomorfização e determinismo de Taine), contrapondo-se à visão idealizada do Romantismo.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q4',
    number: 4,
    yearSource: 'ENEM 2023',
    contextText:
        'Em "Vidas Secas" (1938), Graciliano Ramos constrói a narrativa da família de retirantes Fabiano, Sinhá Vitória, os dois meninos e a cachorra Baleia.',
    questionText:
        'A aridez estilística do romance, caracterizada pela concisão vocabular e economia de adjetivos, relaciona-se com:',
    options: [
      'A incapacidade técnica do autor de produzir metáforas elaboradas.',
      'A mimetização estética da própria secura da caatinga e da mudez/opressão social imposta aos retirantes pelo latifúndio.',
      'A busca por entreter o público infantil com contos de fadas do sertão.',
      'O sentimentalismo exacerbado herdado diretamente da 2ª geração ultrarromântica.',
      'A adesão entusiástica à retórica rococó do barroco mineiro.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Graciliano Ramos constrói uma linguagem "enxuta" que espelha formalmente o cenário desértico do sertão e a quase ausência de fala dos personagens, cuja brutalização pela fome e pelo poder dos coronéis os desumaniza.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'O Manifesto Antropófago (1928), lançado por Oswald de Andrade, postulava a metáfora da "deglutição crítica" das culturas estrangeiras.',
    questionText:
        'A proposta da Antropofagia no Modernismo brasileiro visava:',
    options: [
      'Imitar passivamente todos os cânones culturais europeus sem qualquer alteração.',
      'Devorar a cultura estrangeira, assimilando suas técnicas modernas e recombinando-as com a matriz cultural brasileira e indígena.',
      'Isolar o Brasil de qualquer contato internacional, expulsando turistas e obras de arte importadas.',
      'Preservar os moldes clássicos lusitanos e rejeitar as vanguardas futuristas e cubistas.',
      'Extinguir o idioma português em favor do tupi arcaico em todas as repartições públicas.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A antropofagia oswaldiana usava o canibalismo ritual tupinambá como metáfora: não se tratava de fechar o país nem de se acovardar diante da Europa, mas de "deglutir" a técnica ocidental para produzir arte genuinamente brasileira.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'Em "A Hora da Estrela" (1977), de Clarice Lispector, a datilógrafa alagoana Macabéa vagueia pelas ruas do Rio de Janeiro ignorante de sua própria infelicidade.',
    questionText:
        'A relação entre o narrador Rodrigo S.M. e a protagonista Macabéa evidencia:',
    options: [
      'Um relato jornalístico puramente neutro e impessoal sobre a migração nordestina.',
      'A metalinguagem e a angústia ética do narrador de classe média ao tentar retratar a miséria de uma mulher destituída de tudo.',
      'O desprezo absoluto do narrador pelos pobres, zombando da ingenuidade de Macabéa.',
      'Uma ode celebratória ao sucesso do capitalismo urbano que enriqueceu a jovem.',
      'O predomínio de rimas e estrofes parnasianas típicas da lírica quinhentista.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O romance questiona o próprio ato de narrar: Rodrigo S.M. expõe suas dores e contradições ao se deparar com a pobreza extrema de Macabéa, tornando o livro uma reflexão metalinguística e existencial profunda.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'A Segunda Geração do Romantismo no Brasil (Ultrarromantismo ou Mal do Século) foi marcada por autores como Álvares de Azevedo e Casimiro de Abreu.',
    questionText:
        'Constitui traço temático predominante na poesia ultrarromântica da Noite na Taverna e Lira dos Vinte Anos:',
    options: [
      'O engajamento na luta abolicionista e na denúncia da escravidão nas senzalas.',
      'O escapismo pela morte prematura, o pessimismo, a melancolia profunda e o amor idealizado inacessível.',
      'O entusiasmo com o progresso técnico e com as máquinas a vapor da revolução fabril.',
      'A frieza científica e o distanciamento analítico dos dramas emocionais.',
      'A descrição documental e objetiva da vida cotidiana nos campos de batalha.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O Byronismo/Ultrarromantismo enfatizava a evasão da realidade: o tédio existencial, o medo de amar e o desejo da morte consoladora como alívio para a dor do viver marcaram a jovem geração de poetas tuberculosos da época.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'Castro Alves, conhecido como "O Poeta dos Escravos", encerra a Terceira Geração Romântica (Geração Condoreira).',
    questionText:
        'Em "O Navio Negreiro", o tom grandiloquente e oratório do poeta destina-se a:',
    options: [
      'Celebrar a glória dos marinheiros traficantes e o lucro comercial das viagens atlânticas.',
      'Comover a opinião pública e denunciar a desumanidade hedionda do tráfico de escravizados no Atlântico.',
      'Defender a manutenção pacífica da escravatura em respeito à tradição imperial.',
      'Narrar fábulas alegóricas de animais marinhos para o entretenimento da nobreza.',
      'Substituir o debate político por descrições nostálgicas da infância campestre.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Castro Alves utilizou a poesia como arma cívica: com linguagem hiperbólica inspirada no vôo do condor e em Victor Hugo, denunciou a vergonha nacional da escravidão para mobilizar a sociedade em prol da abolição.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q9',
    number: 9,
    yearSource: 'ENEM 2023',
    contextText:
        'Em "Grande Sertão: Veredas" (1956), João Guimarães Rosa revoluciona a prosa brasileira com a narrativa do ex-jagunço Riobaldo.',
    questionText:
        'A originalidade da obra rosiana no panorama da literatura ocidental sustenta-se principalmente:',
    options: [
      'Na cópia literal do vocabulário arcaico lusitano de Portugal quinhentista.',
      'Na recriação da linguagem através de neologismos, sintaxe poética e elevação do sertão a um território metafísico universal ("o sertão é o mundo").',
      'Na narração cronológica linear estrita dos crimes cometidos pela polícia militar.',
      'Na recusa de temas filosóficos como a existência do bem, do mal e do pacto com o Diabo.',
      'Na ausência completa de personagens femininas ou relações de afeto.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Guimarães Rosa reinventou o idioma português forjando neologismos e fundindo a fala sertaneja com erudição clássica, transformando as perambulações dos jagunços numa epopeia metafísica sobre a existência humana.',
  ),
  const EnemQuestionModel(
    id: 'lit-cla-q10',
    number: 10,
    yearSource: 'ENEM 2018',
    contextText:
        'A Semana de Arte Moderna de 1922 no Theatro Municipal de São Paulo deflagrou a busca por novas formas de expressão estética no Brasil.',
    questionText:
        'Um dos propósitos centrais dos modernistas de 1922 contra a tradição parnasiana foi:',
    options: [
      'Impor o soneto rimado com rigor métrico alexandrino como único modelo permitido.',
      'Reivindicar a liberdade formal, o verso livre, o coloquialismo e a pesquisa das raízes populares brasileiras.',
      'Proibir a pintura abstrata e restaurar a pintura religiosa renascentista.',
      'Defender o latim como idioma obrigatório da literatura de ficção.',
      'Expulsar os artistas que fizessem críticas ao governo da República Velha.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A Semana de 22 lutou contra o passadismo parnasiano e simbolista, defendendo o verso livre sem rima obrigatória, a liberdade estética e a absorção da riqueza cultural do povo brasileiro.',
  ),
];

final List<EnemQuestionModel> gramaticaEInterpretacaoQuestions = [
  const EnemQuestionModel(
    id: 'gram-int-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'Texto publicitário: "Compre o novo sabão X e sinta a maciez incomparável em suas roupas. Não perca essa oportunidade!"',
    questionText:
        'O texto publicitário acima explora predominantemente a seguinte função da linguagem:',
    options: [
      'Metalinguística, pois explica o significado etimológico dos termos empregados.',
      'Conativa ou Apelativa, caracterizada pelo uso de verbos no imperativo para persuadir o interlocutor.',
      'Fática, cujo único objetivo é testar o canal de comunicação entre os falantes.',
      'Emotiva ou Expressiva, focada na exteriorização dos sentimentos íntimos do emissor.',
      'Poética, voltada exclusivamente para o ritmo rítmico dos sonetos greco-romanos.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A função conativa/apelativa centra-se no receptor e busca induzir seu comportamento por meio de verbos no modo imperativo ("Compre", "sinta", "Não perca"), traço típico da linguagem da propaganda.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'Considere as seguintes orações a respeito do emprego do sinal indicativo de crase:\nI. O jovem aspirava a vaga de diplomata na capital.\nII. Todos os candidatos entregaram os relatórios à coordenação.\nIII. Ela preferiu ir a pé em vez de tomar o ônibus.',
    questionText:
        'Quanto à norma-padrão da regência e crase, estão plenamente corretas:',
    options: [
      'Apenas I',
      'Apenas II e III',
      'Apenas I e II',
      'I, II e III',
      'Nenhuma das orações',
    ],
    correctOptionIndex: 1,
    explanation:
        'Na oração I há erro: o verbo "aspirar" no sentido de desejar/almejar é transitivo indireto (rege a preposição "a"); diante de "a vaga", ocorre crase obrigatória: "à vaga". Na II, "entregaram a + a coordenação = à coordenação" (correto). Na III, "a pé" é locução masculina, portanto sem crase (correto). Logo, II e III estão corretas.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q3',
    number: 3,
    yearSource: 'ENEM 2023',
    contextText:
        'Variação linguística diatópica (regional), diastrática (social) e diafásica (estilo/registro formal vs informal).',
    questionText:
        'No ENEM, o reconhecimento dos múltiplos falares e sotaques regionais do Brasil fundamenta-se no princípio linguístico de que:',
    options: [
      'Existe uma única variedade correta no país e todas as outras constituem erros crassos a serem extirpados.',
      'Todas as variedades linguísticas são legítimas, coerentes e adequadas aos seus contextos de uso, devendo-se combater o preconceito linguístico.',
      'Apenas os falantes com curso superior no Sudeste detêm a posse verdadeira da língua portuguesa.',
      'As gírias juvenis devem ser banidas das conversas cotidianas por lei federal.',
      'O português falado no meio rural é desprovido de regras gramaticais internas.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A linguística contemporânea e as diretrizes do ENEM estabelecem que a língua é heterogênea e dinâmica. Não há variedades inferiores ou erradas; o que existe é adequação ao contexto discursivo, sendo fundamental combater o preconceito linguístico.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q4',
    number: 4,
    yearSource: 'ENEM 2020',
    contextText:
        'Enunciado: "O jogador comeu a bola na partida decisiva do campeonato e garantiu a classificação da equipe."',
    questionText:
        'A expressão "comeu a bola" configura uma:',
    options: [
      'Metáfora informal / expressão idiomática que denota atuação brilhante no jogo.',
      'Incoerência semântica que impossibilita a compreensão do leitor.',
      'Metonímia causal referente à ingestão física de couro sintético.',
      'Hipérbole científica que expressa a dilatação gástrica do atleta.',
      'Crase indevida por omissão da preposição regimental.',
    ],
    correctOptionIndex: 0,
    explanation:
        'A expressão coloquial "comer a bola" é uma figura de linguagem (metáfora popular consolidada no jargão futebolístico) que expressa que o atleta jogou com excepcional habilidade.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'Poema: "Gastei trinta dias para ir do Rocio Grande ao coração de Marcela, não já cavalgando o corcel do cego Desejo, mas um asno paciente..." (Machado de Assis).',
    questionText:
        'Ao contrastar o "corcel do cego Desejo" com o "asno paciente", a figura de linguagem predominante que expressa o descompasso emocional é a:',
    options: [
      'Antítese',
      'Pleonasmo',
      'Sinestesia',
      'Onomatopeia',
      'Aliteração',
    ],
    correctOptionIndex: 0,
    explanation:
        'A antítese é a aproximação de ideias ou termos opostos: a nobreza veloz do "corcel" contrapõe-se à lentidão obstinada do "asno", ironizando as frustrações amorosas da juventude de Brás Cubas.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'Dicionário Aurélio: "Amor: s.m. Sentimento de afeição profunda que move uma pessoa a desejar o bem de outrem..."',
    questionText:
        'Quando a linguagem é utilizada para explicar o próprio código linguístico (como em dicionários e livros de gramática), manifesta-se a função:',
    options: [
      'Metalinguística',
      'Fática',
      'Poética',
      'Referencial',
      'Emotiva',
    ],
    correctOptionIndex: 0,
    explanation:
        'A função metalinguística ocorre quando a língua fala sobre a própria língua (o código explica o código), caso clássico de definições de dicionários, aulas de gramática ou poemas que refletem sobre o fazer poético.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'Considere a frase: "Havia muitos problemas na empresa, mas faziam anos que ninguém dizia nada."',
    questionText:
        'De acordo com as regras de concordância verbal da norma-padrão da Língua Portuguesa, o verbo "fazer" foi empregado incorretamente porque:',
    options: [
      'Deveria concordar no particípio passado "tinham feito".',
      'Quando indica tempo transcorrido, o verbo "fazer" é impessoal e deve permanecer obrigatoriamente na 3ª pessoa do singular ("fazia anos").',
      'Deveria ser conjugado no futuro do pretérito "faria anos".',
      'Exige preposição "de" após anos ("faziam de anos").',
      'Não pode ser utilizado em orações coordenadas adversativas.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Os verbos "fazer" (indicando tempo decorrido ou temperatura) e "haver" (no sentido de existir ou tempo transcorrido) são impessoais, isto é, não possuem sujeito, devendo ser grafados invariavelmente na 3ª pessoa do singular: "fazia anos" e "havia problemas".',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'A ambiguidade (anfibologia) decorre do duplo sentido não intencional de um enunciado, comprometendo a clareza da mensagem.',
    questionText:
        'Identifica-se ambiguidade que prejudica o sentido na seguinte oração:',
    options: [
      '"A diretora conversou com a professora sobre os seus alunos."',
      '"Os alunos entregaram as tarefas no prazo estipulado pelo calendário."',
      '"A reunião ministerial terminou antes do meio-dia."',
      '"A comissão avaliou detalhadamente os dados da pesquisa censitária."',
      '"Os cientistas descobriram uma nova vacina com alta eficácia."',
    ],
    correctOptionIndex: 0,
    explanation:
        'Em "A diretora conversou com a professora sobre os seus alunos", o pronome possessivo "seus" gera duplo sentido: os alunos da diretora ou os alunos da professora? Essa é a clássica ambiguidade provocada pelo pronome possessivo de terceira pessoa.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q9',
    number: 9,
    yearSource: 'ENEM 2023',
    contextText:
        'Texto lírico: "Um doce aroma aveludado invadiu o quarto silencioso na penumbra."',
    questionText:
        'A associação sensorial entre paladar ("doce"), tato ("aveludado") e olfato ("aroma") constitui a figura de linguagem denominada:',
    options: [
      'Sinestesia',
      'Metonímia',
      'Prosopopeia',
      'Hipérbato',
      'Eufemismo',
    ],
    correctOptionIndex: 0,
    explanation:
        'A sinestesia é a figura de linguagem caracterizada pelo cruzamento ou fusão de diferentes campos sensoriais humanos (olfato, tato, visão, audição e paladar) em uma mesma expressão estética.',
  ),
  const EnemQuestionModel(
    id: 'gram-int-q10',
    number: 10,
    yearSource: 'ENEM 2018',
    contextText:
        'Enunciado: "O presidente faltou com a verdade durante a entrevista coletiva concedida à imprensa."',
    questionText:
        'O emprego da locução "faltou com a verdade" em lugar do verbo "mentiu" exemplifica o uso de:',
    options: [
      'Eufemismo, empregado para suavizar uma expressão considerada desagradável, chocante ou ofensiva.',
      'Hipérbole, com o objetivo de exagerar expressivamente a declaração.',
      'Ironia, dizendo o contrário do que se pensa para zombar do interlocutor.',
      'Paranomásia, fundada na semelhança sonora de palavras com sentidos díspares.',
      'Catacrese, por ausência de um vocábulo específico na língua portuguesa.',
    ],
    correctOptionIndex: 0,
    explanation:
        'O eufemismo é a figura de linguagem utilizada para atenuar, suavizar ou abrandar termos rudes, grosseiros ou desagradáveis ("faltar com a verdade" em vez de "mentir", "partiu desta para uma melhor" em vez de "morreu").',
  ),
];
