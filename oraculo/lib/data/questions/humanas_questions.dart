import '../../models/enem_question_model.dart';

/// Questões ENEM para os conteúdos de Ciências Humanas:
/// 1. História do Brasil ('historia-do-brasil') - 10 questões
/// 2. Filosofia e Sociologia ('filosofia-e-sociologia') - 10 questões

final List<EnemQuestionModel> historiaDoBrasilQuestions = [
  const EnemQuestionModel(
    id: 'his-bra-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'O Departamento de Imprensa e Propaganda (DIP), criado durante o Estado Novo (1937-1945) por Getúlio Vargas, exercia rígida censura prévia aos meios de comunicação e produzia cartilhas escolares e programas radiofônicos como "A Hora do Brasil".',
    questionText:
        'A atuação ideológica do DIP tinha como propósito primordial:',
    options: [
      'Fomentar a luta de classes e estimular greves operárias contra as indústrias estatais.',
      'Construir a imagem mítica de Vargas como "Pai dos Pobres" e fiador da coesão e da harmonia nacional.',
      'Promover a descentralização do poder político em benefício dos coronéis estaduais.',
      'Incentivar a livre circulação de ideias socialistas e anarquistas nos jornais.',
      'Desarticular os cultos cívicos e os desfiles patrióticos da juventude.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O DIP era a engrenagem propagandística do Estado Novo varguista: censurava vozes dissidentes e construía ativamente a figura carismática de Getúlio Vargas como o grande protetor da classe trabalhadora ("Pai dos Pobres").',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'O Ato Institucional nº 5 (AI-5), baixado em 13 de dezembro de 1968 durante o governo do general Costa e Silva, é considerado o momento de maior endurecimento da Ditadura Militar no Brasil.',
    questionText:
        'Entre as medidas autoritárias mais drásticas outorgadas pelo AI-5, destaca-se:',
    options: [
      'A concessão de anistia ampla, geral e irrestrita a todos os presos políticos.',
      'A suspensão das garantias constitucionais, incluindo o habeas corpus para crimes contra a segurança nacional, e o fechamento do Congresso Nacional.',
      'A convocação imediata de eleições diretas para a Presidência da República.',
      'A legalização de partidos de oposição de matriz comunista.',
      'A abolição definitiva das forças armadas regulares.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O AI-5 suspendeu a garantia de habeas corpus para os acusados de crimes políticos, fechou o Congresso, cassou mandatos eletivos e institucionalizou a censura prévia irrestrita, inaugurando os "anos de chumbo" da ditadura.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q3',
    number: 3,
    yearSource: 'ENEM 2020',
    contextText:
        'A Constituição de 1824, outorgada por D. Pedro I após a dissolução forçada da Assembleia Constituinte, instituiu quatro poderes políticos no Império do Brasil: Executivo, Legislativo, Judiciário e Moderador.',
    questionText:
        'O Poder Moderador, exclusividade privativa da figura do Imperador, conferia-lhe a prerrogativa de:',
    options: [
      'Submeter todas as decisões reais à aprovação prévia do Papa em Roma.',
      'Intervir sobre os demais três poderes, podendo demitir ministros, dissolver a Câmara dos Deputados e nomear senadores vitalícios.',
      'Extinguir imediatamente a monarquia e proclamar a república federativa.',
      'Restringir seu papel a funções cerimoniais sem qualquer peso deliberativo.',
      'Transferir a administração das províncias aos presidentes eleitos por voto universal feminino.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Criado sob a inspiração do filósofo Benjamin Constant, o Poder Moderador tornava o Imperador a "chave de toda a organização política", permitindo-lhe intervir soberanamente nos demais poderes, demitindo gabinetes e dissolvendo o Legislativo à vontade.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q4',
    number: 4,
    yearSource: 'ENEM 2023',
    contextText:
        'Durante a Primeira República (1889-1930), a estrutura política brasileira ficou conhecida como "República Oligárquica" ou "Política do Café com Leite".',
    questionText:
        'O mecanismo eleitoral do "voto de cabresto" praticado pelos coronéis no interior do país fundamentava-se:',
    options: [
      'Na total inviolabilidade do sigilo do voto eletrônico nas urnas rurais.',
      'No voto aberto e na coerção física, econômica e clientelista sobre os eleitores dependentes dos favores do fazendeiro local.',
      'Na fiscalização independente da Justiça Eleitoral sobre o alistamento.',
      'Na exigência de diploma de nível superior para todos os cidadãos eleitores.',
      'Na ausência de disputas políticas entre as oligarquias paulistas e mineiras.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O coronelismo assentava-se no controle clientelista dos votos: como a votação era aberta (não secreta), os coronéis impunham seus candidatos aos trabalhadores e moradores sob ameaça de violência armada ou perda de terras e empregos.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'A Lei de Terras de 1850 foi promulgada praticamente no mesmo momento da Lei Eusébio de Queirós, que extinguiu o tráfico negreiro transatlântico para o Brasil.',
    questionText:
        'Ao estabelecer que o acesso à terra pública só poderia ocorrer mediante compra à vista em leilão e não mais por posse ou ocupação, a Lei de Terras tinha como objetivo implícito:',
    options: [
      'Distribuir pequenos lotes gratuitos aos escravizados recém-libertos para torná-los proprietários.',
      'Impedir que imigrantes europeus e ex-escravizados tivessem acesso facilitado à terra, forçando-os a trabalhar como mão de obra assalariada nos cafezais.',
      'Doar todas as fazendas cafeeiras improdutivas aos sindicatos operários.',
      'Transferir o controle do campo para as ordens religiosas jesuíticas.',
      'Estimular a subsistência familiar em detrimento da grande monocultura de exportação.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Com o fim iminente da escravidão, a elite latifundiária blindou a propriedade da terra: proibindo a posse por ocupação e exigindo compra em dinheiro, garantia que imigrantes pobres e negros libertos continuassem submetidos ao trabalho dependente nos latifúndios.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'A Campanha das "Diretas Já" (1983-1984) mobilizou milhões de brasileiros nas praças das principais capitais em torno da Emenda Dante de Oliveira.',
    questionText:
        'O objetivo cívico central do movimento popular das Diretas Já era:',
    options: [
      'Manter o Colégio Eleitoral indireto para a escolha do presidente.',
      'Restabelecer as eleições diretas para a Presidência da República no Brasil, acelerando o término do regime militar.',
      'Revogar a anistia concedida aos presos e exilados da ditadura.',
      'Apoiar a continuidade do general João Figueiredo no poder.',
      'Proibir o funcionamento de centrais sindicais no país.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A mobilização exigia a aprovação da Emenda Constitucional Dante de Oliveira para que o povo brasileiro pudesse escolher diretamente o próximo presidente pelo voto popular, marco crucial na redemocratização.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'A Revolta da Vacina, ocorrida no Rio de Janeiro em novembro de 1904, eclodiu durante a reforma urbana do prefeito Pereira Passos e as medidas sanitárias de Oswaldo Cruz.',
    questionText:
        'Além da obrigatoriedade da vacinação antivariólica, a indignação popular foi catalisada por:',
    options: [
      'A expulsão forçada de famílias pobres do centro da cidade (o "bota-abaixo") e a demolição violenta de seus cortiços sem indenizações adequadas.',
      'A proibição do Carnaval de rua e a taxação de carruagens elétricas.',
      'A tomada do poder pelos sindicatos ferroviários alinhados à União Soviética.',
      'A exigência de serviço militar feminino obrigatório.',
      'O fechamento definitivo dos portos aos navios estrangeiros.',
    ],
    correctOptionIndex: 0,
    explanation:
        'A Revolta da Vacina não foi apenas medo da agulha: a população pobre já sofria com o autoritarismo do "bota-abaixo" de Pereira Passos, que demoliu os cortiços centrais para higienizar e embelezar a cidade ao estilo parisiense, empurrando as massas para os morros sem amparo.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'A política do "trabalhismo" desenvolvida por Getúlio Vargas consolidou a Consolidação das Leis do Trabalho (CLT) em 1º de maio de 1943.',
    questionText:
        'A concessão de direitos trabalhistas (salário mínimo, férias remuneradas, jornada de 8 horas) combinava-se no modelo varguista com:',
    options: [
      'A total autonomia e liberdade de greve para os sindicatos operários sem tutela do Estado.',
      'O enquadramento corporativista e a rigorosa tutela dos sindicatos sob a égide do Ministério do Trabalho, neutralizando a liderança comunista.',
      'O fim da propriedade privada dos meios de produção industriais.',
      'A extinção do imposto sindical compulsório.',
      'A rejeição do apoio das camadas populares às reformas estatais.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Vargas atrelou a conquista de direitos trabalhistas ao controle corporativista: os sindicatos só eram reconhecidos se submetidos ao Estado (Ministério do Trabalho) e os líderes sindicais ("pelegos") eram cooptados, coibindo greves e revoltas de esquerda.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q9',
    number: 9,
    yearSource: 'ENEM 2023',
    contextText:
        'A Guerra de Canudos (1896-1897), no sertão baiano, liderada por Antônio Conselheiro, reuniu cerca de 25 mil sertanejos na comunidade de Belo Monte.',
    questionText:
        'A reação violenta do governo da jovem República brasileira, que enviou sucessivas expedições militares até a aniquilação total do arraial, justificava-se pelo discurso oficial de que:',
    options: [
      'Canudos era um foco monarquista e fanático que ameaçava a soberania da recém-proclamada República.',
      'Os sertanejos pretendiam invadir a capital federal para reinstaurar o tráfico negreiro.',
      'O arraial recebia armas secretas financiadas pela coroa britânica.',
      'Antônio Conselheiro havia assinado um pacto militar com caudilhos argentinos.',
      'Os moradores se recusavam a pagar impostos ao imperador D. Pedro II.',
    ],
    correctOptionIndex: 0,
    explanation:
        'As elites da República da Espada e a imprensa carioca retrataram Canudos como uma perigosa conspiração monarquista financiada para derrubar a República, justificando o massacre de sertanejos que apenas buscavam sobreviver à seca e ao domínio escorchante dos coronéis.',
  ),
  const EnemQuestionModel(
    id: 'his-bra-q10',
    number: 10,
    yearSource: 'ENEM 2018',
    contextText:
        'A chamada "Constituição Cidadã" de 1988 coroou o processo de redemocratização política do Brasil após 21 anos de regime militar.',
    questionText:
        'A Carta Magna de 1988 representou um marco histórico na consolidação democrática ao:',
    options: [
      'Restringir o sufrágio eleitoral exclusivamente aos proprietários de terras alfabetizados.',
      'Consagrar a ampliação sem precedentes dos direitos fundamentais, individuais e sociais (saúde como dever do Estado no SUS, voto facultativo aos 16 anos, igualdade de gênero e racismo como crime inafiançável).',
      'Extinguir o Ministério Público e subordinar o Judiciário às ordens do Presidente da República.',
      'Proibir a livre criação de partidos políticos e sindicatos profissionais.',
      'Instituir o Poder Moderador vitalício concedido ao comandante do Exército.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Promulgada sob a liderança de Ulysses Guimarães, a Constituição de 1988 estabeleceu o Estado Democrático de Direito, consagrando os direitos sociais (SUS, previdência social, educação), direitos trabalhistas, combate ao racismo e proteção aos povos indígenas.',
  ),
];

final List<EnemQuestionModel> filosofiaESociologiaQuestions = [
  const EnemQuestionModel(
    id: 'fil-soc-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'Texto: "O homem nasce livre, e por toda parte encontra-se a ferros. O que se crê senhor dos demais não deixa de ser mais escravo do que eles." (Jean-Jacques Rousseau, Do Contrato Social).',
    questionText:
        'Na filosofia política de Rousseau, a superação da opressão e o estabelecimento de uma ordem social justa realizam-se mediante:',
    options: [
      'A submissão incondicional a um monarca absolutista com poderes teocráticos.',
      'O pacto legítimo fundado na Vontade Geral e na soberania inalienável do povo.',
      'A restauração da barbárie do estado de natureza primitivo sem leis ou regras.',
      'A proteção irrestrita da propriedade privada dos grandes proprietários de terras.',
      'A substituição do sufrágio universal pelo governo exclusivo de sábios filósofos.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Rousseau propõe que a legitimidade do poder político decorre do pacto social em que cada indivíduo se une a todos sob a suprema direção da Vontade Geral, garantindo a soberania popular e a igualdade civil dos cidadãos.',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'Texto: "A vida do homem no estado de natureza é solitária, miserável, sórdida, brutal e curta... guerra de todos contra todos." (Thomas Hobbes, Leviatã).',
    questionText:
        'Para Thomas Hobbes, a justificativa racional para a criação do Estado e a renúncia à liberdade natural baseia-se na necessidade de:',
    options: [
      'Garantir o direito inalienável dos cidadãos de realizarem revoluções armadas periódicas.',
      'Escapar do medo constante da morte violenta e assegurar a paz civil e a ordem sob a autoridade do soberano.',
      'Instituir a democracia direta ateniense com assembleias populares.',
      'Proteger a propriedade privada concedida diretamente pela vontade divina.',
      'Abolir a autoridade das forças armadas regulares.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Hobbes argumenta que, sem um poder comum coercitivo que imponha respeito ("o Leviatã"), os seres humanos viveriam em estado constante de medo da morte violenta ("o homem é o lobo do homem"), sendo a segurança a razão de ser do Estado.',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q3',
    number: 3,
    yearSource: 'ENEM 2020',
    contextText:
        'Para Émile Durkheim, a Sociologia deve dedicar-se ao estudo dos "fatos sociais", concebidos como "coisas".',
    questionText:
        'As três características constitutivas de um fato social segundo o método durkheimiano são:',
    options: [
      'Subjetividade, anarquia e voluntariedade.',
      'Coercitividade, exterioridade e generalidade.',
      'Individualidade, inconsciência e historicidade temporária.',
      'Livre-arbítrio, emotividade e originalidade artística.',
      'Biotipologia, hereditariedade e espontaneidade.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Durkheim define fato social como maneiras de agir, pensar e sentir exteriores ao indivíduo (existem antes dele), dotadas de poder coercitivo (impõem-se a ele com sanções sociais) e gerais no âmbito de uma dada sociedade.',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q4',
    number: 4,
    yearSource: 'ENEM 2023',
    contextText:
        'Texto: "Age de tal maneira que a máxima da tua vontade possa sempre valer ao mesmo tempo como princípio de uma legislação universal." (Immanuel Kant, Crítica da Razão Prática).',
    questionText:
        'O princípio ético formulado por Kant, conhecido como Imperativo Categórico, fundamenta-se na:',
    options: [
      'Busca utilitarista da felicidade individual a qualquer custo moral.',
      'Ação moral por dever, desinteressada de inclinações empíricas e universalizável pela razão pura.',
      'Conformação às tradições religiosas sob o receio de castigo eterno no além.',
      'Validação da mentira piedosa como instrumento aceitável de convivência pacífica.',
      'Subordinação das normas morais às leis econômicas de mercado.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A ética deontológica kantiana baseia-se no Imperativo Categórico: uma ação só é moralmente boa se for realizada estritamente por dever e se sua máxima puder ser convertida em lei universal válida para qualquer ser racional.',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'Para Karl Marx, a produção material da vida é o alicerce sobre o qual se ergue a superestrutura jurídica e política da sociedade (Materialismo Histórico).',
    questionText:
        'O conceito marxista de "mais-valia" corresponde à:',
    options: [
      'Soma dos impostos alfandegários recolhidos pelo governo na exportação.',
      'Diferença entre o valor total produzido pelo trabalho do operário e o salário pago a ele pelo capitalista detentor dos meios de produção.',
      'Margem de lucro reinvestida compulsoriamente em melhorias salariais na fábrica.',
      'Taxa de juros bancária cobrada sobre empréstimos concedidos aos camponeses.',
      'Perda de valor das máquinas industriais em decorrência do desgaste mecânico.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A mais-valia é a base da acumulação capitalista: representa o trabalho excedente não pago ao operário, apropriado pelo dono dos meios de produção sob a forma de lucro.',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'Max Weber desenvolveu a teoria da "Ação Social" e identificou quatro tipos ideais de orientação da conduta humana.',
    questionText:
        'A ação social de um estudante que decide passar horas resolvendo simulados de olho em uma vaga no curso de Medicina é classificada predominantemente por Weber como:',
    options: [
      'Ação afetiva guiada pelo desespero emocional imediato.',
      'Ação racional com relação a fins (instrumental), orientada para atingir um objetivo prático deliberado mediante meios calculados.',
      'Ação tradicional motivada por hábitos cegos transmitidos ancestralmente.',
      'Ação desprovida de qualquer sentido subjetivo visado pelo agente.',
      'Comportamento puramente biológico e reflexo.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A ação racional com relação a fins ocorre quando o agente visa conscientemente a uma finalidade específica (passar no vestibular) e planeja racionalmente os meios e custos adequados para alcançá-la (estudo e simulados).',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'Theodor Adorno e Max Horkheimer, pensadores da Escola de Frankfurt, cunharam o conceito de "Indústria Cultural" na obra Dialética do Esclarecimento.',
    questionText:
        'Segundo os teóricos críticos frankfurtianos, a Indústria Cultural opera de modo a:',
    options: [
      'Estimular o senso crítico, a rebeldia reflexiva e a autonomia intelectual dos cidadãos.',
      'Transformar a arte e os bens culturais em mercadorias estandardizadas destinadas ao consumo passivo, promovendo a alienação das massas.',
      'Democratizar os museus e extinguir o comércio internacional de obras de arte.',
      'Banir a tecnologia dos estúdios cinematográficos em favor do artesanato folclórico.',
      'Eliminar a publicidade corporativa em prol da propaganda filosófica acadêmica.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A Indústria Cultural reduz os produtos culturais a mercadorias padronizadas e fáceis de assimilar, gerando entretenimento que aplaca as tensões sociais e fomenta o conformismo das massas sob o capitalismo tardio.',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'Texto: "A virtude é, pois, uma disposição de caráter relacionada com a escolha de ações e paixões, e consistente num meio-termo..." (Aristóteles, Ética a Nicômaco).',
    questionText:
        'A doutrina aristotélica da virtude (justo meio ou "mesotes") defende que a excelência moral reside:',
    options: [
      'No excesso passional que despreza a moderação racional.',
      'No equilíbrio equidistante entre dois vícios opostos: um por falta (deficiência) e outro por excesso.',
      'Na obediência cega a mandamentos impostos por oráculos místicos.',
      'Na renúncia a qualquer busca pela felicidade (eudaimonia) terrena.',
      'Na acumulação ilimitada de bens materiais e privilégios de berço.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Para Aristóteles, a virtude moral é o equilíbrio prudente (justo meio) entre os extremos: a coragem, por exemplo, é a mediania entre a covardia (falta) e a temeridade irresponsável (excesso).',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q9',
    number: 9,
    yearSource: 'ENEM 2023',
    contextText:
        'O sociólogo polonês Zygmunt Bauman formulou a metáfora da "Modernidade Líquida" para caracterizar a sociedade contemporânea.',
    questionText:
        'Na visão de Bauman, a fluidez das relações sociais no mundo líquido reflete-se em:',
    options: [
      'Vínculos comunitários inabaláveis e instituições sólidas e perpétuas.',
      'Fragilização e volatilidade dos laços afetivos e profissionais, marcados pelo individualismo consumista e pela incerteza permanente.',
      'Triunfo absoluto das certezas ideológicas e políticas dos séculos passados.',
      'Abolição de celulares e internet em benefício do contato presencial íntimo.',
      'Estabilidade garantida no emprego com aposentadorias precoces asseguradas a todos.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A Modernidade Líquida de Bauman descreve um tempo de liquidez institucional e relacional: as certezas sólidas derreteram-se, os laços humanos tornaram-se descartáveis ("amor líquido") e a insegurança rege a vida contemporânea.',
  ),
  const EnemQuestionModel(
    id: 'fil-soc-q10',
    number: 10,
    yearSource: 'ENEM 2018',
    contextText:
        'O filósofo John Locke é considerado o pai do liberalismo político e formulador dos direitos naturais inalienáveis.',
    questionText:
        'Segundo Locke no "Segundo Tratado sobre o Governo Civil", se o governante violar sistematicamente os direitos naturais à vida, à liberdade e à propriedade dos cidadãos, o povo tem o direito legítimo de:',
    options: [
      'Resignar-se em silêncio por ser a autoridade do rei concedida por Deus.',
      'Rebelar-se e depor o governo tirânico, restaurando a legalidade e a proteção aos seus direitos.',
      'Entregar suas terras ao império vizinho para garantir abrigo militar.',
      'Aceitar a escravidão perpétua como penitência moral pelo pecado original.',
      'Eliminar todo e qualquer tribunal civil ou corte judicial.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Para John Locke, o poder político é um contrato de confiança: o governo existe unicamente para salvaguardar os direitos naturais (vida, liberdade, propriedade). Quando o Estado rompe esse pacto e se torna tirânico, o povo possui o direito inalienável de resistência e rebelião.',
  ),
];
