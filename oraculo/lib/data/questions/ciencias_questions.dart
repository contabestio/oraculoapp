import '../../models/enem_question_model.dart';

/// Questões ENEM para os conteúdos de Ciências da Natureza:
/// 1. Física Mecânica & Óptica ('fisica-mecanica-optica') - 10 questões
/// 2. Química Geral & Orgânica ('quimica-geral-organica') - 10 questões (inclui a exata Questão 98 da imagem!)
/// 3. Biologia Celular e Genética ('biologia-celular-genetica') - 10 questões

final List<EnemQuestionModel> fisicaMecanicaOpticaQuestions = [
  const EnemQuestionModel(
    id: 'fis-mec-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'Um veículo esportivo de massa 1.200 kg trafega em linha reta por uma rodovia horizontal e atinge a velocidade de 108 km/h (30 m/s). O motorista aciona os freios bruscamente até o veículo parar totalmente em 5 segundos.',
    questionText:
        'O módulo da força resultante média exercida pelos freios sobre o veículo durante essa desaceleração é:',
    options: [
      '3.600 N',
      '4.800 N',
      '6.000 N',
      '7.200 N',
      '8.400 N',
    ],
    correctOptionIndex: 3,
    explanation:
        'A aceleração escalar média é a = Δv / Δt = (0 - 30) / 5 = -6 m/s². Pela 2ª Lei de Newton (Princípio Fundamental da Dinâmica): |FR| = m · |a| = 1.200 · 6 = 7.200 N.',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'Em uma montanha-russa ideal, um carrinho de 500 kg parte do repouso do topo de uma colina a 20 metros de altura em relação ao solo. Despreze quaisquer forças dissipativas como atrito e resistência do ar e adote g = 10 m/s².',
    questionText:
        'A velocidade do carrinho ao atingir a base da pista ao nível do solo vale:',
    options: [
      '10 m/s',
      '14 m/s',
      '20 m/s',
      '25 m/s',
      '40 m/s',
    ],
    correctOptionIndex: 2,
    explanation:
        'Pelo Princípio da Conservação da Energia Mecânica: Emec_inicial = Emec_final => Epg = Ec => m · g · h = (m · v²) / 2 => v = √(2 · g · h) = √(2 · 10 · 20) = √400 = 20 m/s.',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q3',
    number: 3,
    yearSource: 'ENEM 2020',
    contextText:
        'A 3ª Lei de Newton (Ação e Reação) estabelece que para toda ação há uma reação de mesma intensidade, mesma direção e sentidos opostos.',
    questionText:
        'Essas forças de ação e reação jamais se anulam mutuamente porque:',
    options: [
      'Possuem intensidades ligeiramente diferentes no vácuo.',
      'Atuam sempre aplicadas em corpos diferentes.',
      'Possuem direções perpendiculares entre si.',
      'Ocorrem em instantes de tempo consecutivos e não simultâneos.',
      'Dependem da constante elástica de Hooke.',
    ],
    correctOptionIndex: 1,
    explanation:
        'As forças de ação e reação nunca se equilibram ou se cancelam porque atuam em corpos distintos (o corpo A exerce força em B, e o corpo B exerce força em A).',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q4',
    number: 4,
    yearSource: 'ENEM 2023',
    contextText:
        'Um feixe de luz monocromática passa do ar (índice de refração nar = 1,0) para a água (nágua = 1,33).',
    questionText:
        'Ao penetrar na água, o que ocorre com a frequência e a velocidade de propagação desse feixe luminoso?',
    options: [
      'A frequência aumenta e a velocidade diminui.',
      'A frequência permanece inalterada e a velocidade diminui.',
      'A frequência e a velocidade permanecem estritamente constantes.',
      'A frequência diminui e a velocidade aumenta.',
      'A frequência diminui e o comprimento de onda aumenta.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Na refração de qualquer onda, a frequência f é determinada pela fonte emissora e NUNCA muda ao mudar de meio. Como a água é mais refringente que o ar (v = c / n), a velocidade da luz diminui.',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'Espelhos esféricos são amplamente utilizados no cotidiano: espelhos côncavos em maquiagem e odontologia, e espelhos convexos em retrovisores de ônibus e esquinas de garagens.',
    questionText:
        'A imagem conjugada por um espelho esférico CONVEXO para um objeto real colocado a qualquer distância diante dele é sempre:',
    options: [
      'Real, invertida e maior que o objeto.',
      'Virtual, direita e menor que o objeto.',
      'Real, direita e de mesmo tamanho.',
      'Virtual, invertida e ampliada.',
      'Imprópria localizada no centro de curvatura.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O espelho convexo conjuga sempre imagem com as mesmas características para qualquer posição do objeto: virtual (atrás do espelho), direita e menor, o que proporciona um campo visual significativamente ampliado.',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'Um motor elétrico realiza um trabalho útil de 15.000 Joules em um intervalo de tempo de 30 segundos.',
    questionText:
        'A potência mecânica média desenvolvida por esse motor é de:',
    options: [
      '300 W',
      '450 W',
      '500 W',
      '750 W',
      '1.000 W',
    ],
    correctOptionIndex: 2,
    explanation:
        'A potência é a taxa temporal de realização de trabalho: P = W / Δt = 15.000 J / 30 s = 500 Watts.',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'Um objeto de 4 kg é abandonado em queda livre a partir do repouso do alto de um edifício de 45 metros de altura. Despreze a resistência do ar e considere g = 10 m/s².',
    questionText:
        'O tempo que o objeto leva para atingir o solo é de:',
    options: [
      '2,0 s',
      '2,5 s',
      '3,0 s',
      '4,5 s',
      '5,0 s',
    ],
    correctOptionIndex: 2,
    explanation:
        'Pela função horária da queda livre: h = (g · t²) / 2 => 45 = (10 · t²) / 2 => 45 = 5t² => t² = 9 => t = 3,0 segundos.',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'Uma pessoa segura uma mala de 10 kg e caminha horizontalmente com velocidade constante de 1 m/s por uma distância de 20 metros em uma plataforma plana.',
    questionText:
        'O trabalho realizado pela força peso sobre a mala durante esse deslocamento horizontal é igual a:',
    options: [
      '0 Joules',
      '200 Joules',
      '1.000 Joules',
      '2.000 Joules',
      '-2.000 Joules',
    ],
    correctOptionIndex: 0,
    explanation:
        'O trabalho é W = F · d · cos(θ). A força peso atua na vertical (para baixo) e o deslocamento ocorre na horizontal. O ângulo entre peso e deslocamento é θ = 90°. Como cos(90°) = 0, o trabalho realizado pelo peso é nulo (0 Joules).',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q9',
    number: 9,
    yearSource: 'ENEM 2023',
    contextText:
        'O fenômeno da dispersão da luz branca em um prisma de vidro transparente revela que as cores que compõem o espectro visível sofrem desvios angulares desiguais.',
    questionText:
        'Dentre as cores do espectro visível, a radiação monocromática que sofre o MAIOR desvio angular ao atravessar o prisma e apresenta o MAIOR índice de refração no vidro é a luz:',
    options: [
      'Vermelha',
      'Amarela',
      'Verde',
      'Violeta',
      'Alaranjada',
    ],
    correctOptionIndex: 3,
    explanation:
        'A luz violeta possui a menor velocidade no vidro, a menor longitude de onda e a maior frequência no espectro visível, resultando no maior índice de refração relativo e, consequentemente, no maior desvio na refração.',
  ),
  const EnemQuestionModel(
    id: 'fis-mec-q10',
    number: 10,
    yearSource: 'ENEM 2018',
    contextText:
        'Um arqueiro puxa a corda do arco aplicando uma força que deforma a madeira elástica em 0,4 metro. A constante elástica do arco vale k = 500 N/m.',
    questionText:
        'A energia potencial elástica acumulada no arco pronto para disparar a flecha é de:',
    options: [
      '20 J',
      '40 J',
      '80 J',
      '100 J',
      '200 J',
    ],
    correctOptionIndex: 1,
    explanation:
        'A energia potencial elástica é Ep = (k · x²) / 2 = (500 · (0,4)²) / 2 = (500 · 0,16) / 2 = 80 / 2 = 40 Joules.',
  ),
];

final List<EnemQuestionModel> quimicaGeralOrganicaQuestions = [
  // QUESTÃO 98 - EXATAMENTE A QUESTÃO DA IMAGEM DO USUÁRIO!
  const EnemQuestionModel(
    id: 'qui-org-q98',
    number: 98,
    yearSource: 'ENEM',
    contextText:
        'Para obtenção do princípio ativo a partir das folhas de uma planta medicinal, um pesquisador as colocou em um béquer, adicionou água e aqueceu a mistura a 100 °C. Após dez minutos de aquecimento, a mistura foi separada com auxílio de funil e algodão. A parte líquida, por conter ainda pequenas partículas, foi submetida a um processo de separação a intensa rotação, e o sobrenadante, recolhido para avaliação da atividade biológica.',
    questionText:
        'A sequência dos procedimentos utilizados pelo pesquisador foi:',
    options: [
      'Filtração, decantação e extração.',
      'Extração, filtração e centrifugação.',
      'Destilação, filtração e precipitação.',
      'Centrifugação, extração e decantação.',
      'Precipitação, decantação e centrifugação.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Análise detalhada das 3 etapas do experimento:\n1. Colocar em água quente a 100 °C para dissolver o princípio ativo das folhas: processo de EXTRAÇÃO (extração por solvente/infusão).\n2. Separação com funil e algodão para reter as folhas sólidas: processo de FILTRAÇÃO mecânica simples.\n3. Separação por intensa rotação para sedimentar micropartículas e recolher o sobrenadante: processo de CENTRIFUGAÇÃO.\nPortanto, a sequência correta é: Extração, filtração e centrifugação (Alternativa B).',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q2',
    number: 2,
    yearSource: 'ENEM 2022',
    contextText:
        'O acetato de etila (etanoato de etila) é um composto orgânico com aroma característico de frutas e amplamente utilizado como solvente e aromatizante alimentar.',
    questionText:
        'O composto pertence à função orgânica oxigenada denominada:',
    options: [
      'Álcool',
      'Éter',
      'Éster',
      'Cetona',
      'Ácido carboxílico',
    ],
    correctOptionIndex: 2,
    explanation:
        'O etanoato de etila (CH3-COO-CH2CH3) possui o grupo funcional -COO- ligado a duas cadeias carbônicas, caracterizando a função ÉSTER, obtida pela reação de esterificação entre um ácido carboxílico e um álcool.',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q3',
    number: 3,
    yearSource: 'ENEM 2021',
    contextText:
        'A gasolina é uma mistura homogênea de hidrocarbonetos e o etanol é um combustível oxigenado (álcool). No Brasil, adiciona-se cerca de 27% de etanol anidro à gasolina comercial.',
    questionText:
        'Para determinar o teor de etanol na gasolina, realiza-se o teste da proveta misturando gasolina com água e salmoura. O etanol migra para a fase aquosa porque:',
    options: [
      'O etanol é apolar como os hidrocarbonetos da gasolina.',
      'O etanol estabelece fortes ligações de hidrogênio (interações dipolo-dipolo de alta energia) com as moléculas polares de água.',
      'O etanol reage quimicamente com o sal produzindo éter insolúvel.',
      'A densidade da gasolina atrai seletivamente o sal de cozinha.',
      'O etanol evapora espontaneamente na presença de cloreto de sódio.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O etanol (CH3CH2OH) é anfifílico, mas sua hidroxila (-OH) forma ligações de hidrogênio muito intensas com a água polar. Diante da adição de água, o etanol é extraído da fase apolar (gasolina) para a fase aquosa polar.',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q4',
    number: 4,
    yearSource: 'ENEM 2020',
    contextText:
        'Considere a combustão completa do gás metano (CH4), principal componente do gás natural:\nCH4(g) + 2 O2(g) -> CO2(g) + 2 H2O(g)\nMassas molares (g/mol): C = 12, H = 1, O = 16.',
    questionText:
        'A massa de gás carbônico (CO2) lançada na atmosfera pela queima estequiométrica de 32 gramas de metano é de:',
    options: [
      '44 g',
      '64 g',
      '88 g',
      '132 g',
      '176 g',
    ],
    correctOptionIndex: 2,
    explanation:
        'Massa molar do CH4 = 12 + 4(1) = 16 g/mol. Número de mols de metano: n = 32 g / 16 g/mol = 2 mols de CH4. Pela estequiometria 1:1, são produzidos 2 mols de CO2. Massa molar do CO2 = 12 + 2(16) = 44 g/mol. Logo, massa de CO2 = 2 · 44 g = 88 g.',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q5',
    number: 5,
    yearSource: 'ENEM 2023',
    contextText:
        'O fenol é um composto orgânico cuja fórmula molecular mínima é C6H5OH.',
    questionText:
        'A característica estrutural que define e diferencia quimicamente um FENOL de um ÁLCOOL aromático é:',
    options: [
      'A presença de ligação tripla entre carbonos sp.',
      'A ligação direta do grupo hidroxila (-OH) a um carbono saturado de cadeia aberta.',
      'A ligação direta do grupo hidroxila (-OH) a um átomo de carbono do anel benzênico (aromático).',
      'A presença obrigatória de átomos de enxofre e nitrogênio no ciclo.',
      'A insolubilidade total em qualquer solvente orgânico oxigenado.',
    ],
    correctOptionIndex: 2,
    explanation:
        'Nos fenóis, a hidroxila (-OH) está ligada diretamente a um carbono do anel benzênico, o que confere ao composto caráter ácido muito mais acentuado do que nos álcoois alifáticos comuns.',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q6',
    number: 6,
    yearSource: 'ENEM 2019',
    contextText:
        'A água e o óleo de soja não se misturam, formando um sistema heterogêneo bifásico. Ao adicionar detergente de cozinha à mistura e agitar vigorosamente, forma-se uma emulsão estável.',
    questionText:
        'O detergente atua como agente tensoativo/emulsificante porque suas moléculas:',
    options: [
      'São estritamente apolares e quebram a tensão da água por atrito térmico.',
      'Apresentam estrutura anfifílica, contendo uma longa cauda hidrofóbica (apolar) e uma cabeça hidrofílica (polar/iônica).',
      'Convertem quimicamente a gordura em hidróxido de sódio corrosivo.',
      'Fazem o óleo evaporar instantaneamente em temperatura ambiente.',
      'Polimerizam as moléculas de água transformando-as em gel insolúvel.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Moléculas de detergentes e sabões são anfifílicas: a cauda apolar interage com o óleo (gordura) por dispersão de London, enquanto a cabeça polar interage com a água por interações eletrostáticas/pontes de hidrogênio, formando micelas.',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q7',
    number: 7,
    yearSource: 'ENEM 2022',
    contextText:
        'Na destilação fracionada do petróleo bruto em refinarias, os componentes são separados em diferentes frações (gás liquefeito, gasolina, querosene, óleo diesel e resíduos).',
    questionText:
        'O princípio físico fundamental que rege a separação dos hidrocarbonetos na torre de destilação fracionada é a diferença entre:',
    options: [
      'As condutividades elétricas das frações metálicas.',
      'Os pontos de ebulição dos hidrocarbonetos, que variam conforme o tamanho da cadeia carbônica e a massa molar.',
      'As taxas de decaimento radioativo das cadeias saturadas.',
      'O índice de acidez e basicidade segundo a teoria de Lewis.',
      'A solubilidade em ácidos clorídricos concentrados.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A destilação fracionada baseia-se na diferença de temperatura de ebulição: hidrocarbonetos menores e de menor massa molar entram em ebulição em temperaturas mais baixas (saindo no topo da torre), enquanto moléculas maiores e mais pesadas condensam nos pratos inferiores.',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q8',
    number: 8,
    yearSource: 'ENEM 2021',
    contextText:
        'Considere os seguintes compostos de massas molares semelhantes: butano (C4H10) e propan-1-ol (C3H7OH). O butano é um gás à temperatura ambiente (PE = -0,5 °C), enquanto o propan-1-ol é um líquido com ponto de ebulição bem mais elevado (PE = 97 °C).',
    questionText:
        'A grande diferença nos pontos de ebulição entre essas duas substâncias é atribuída:',
    options: [
      'À existência de ligações de hidrogênio intermoleculares entre as moléculas de propan-1-ol, muito mais fortes que as forças de dipolo induzido do butano.',
      'À presença de ligações iônicas covalentes no butano gasoso.',
      'Ao fato de o butano apresentar massa molecular 10 vezes maior que a do álcool.',
      'À reatividade espontânea do oxigênio com o nitrogênio do ar.',
      'Ao comportamento metálico condutor apresentado pelos álcoois primários.',
    ],
    correctOptionIndex: 0,
    explanation:
        'O propan-1-ol possui a hidroxila (-OH), estabelecendo pontes de hidrogênio (interações intermoleculares muito intensas que exigem grande energia térmica para quebra). O butano é apolar e realiza apenas forças fracas de dispersão de London (dipolo induzido).',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q9',
    number: 9,
    yearSource: 'ENEM 2020',
    contextText:
        'A aspirina (ácido acetilsalicílico) possui em sua estrutura química duas funções orgânicas oxigenadas de extrema importância terapêutica.',
    questionText:
        'As funções orgânicas presentes na molécula do ácido acetilsalicílico são:',
    options: [
      'Álcool e amina',
      'Ácido carboxílico e éster',
      'Aldeído e cetona',
      'Éter e amida',
      'Fenol e hidrocarboneto aromático isolado',
    ],
    correctOptionIndex: 1,
    explanation:
        'O ácido acetilsalicílico possui o grupo carboxila (-COOH) ligado ao anel benzênico (função ácido carboxílico) e o grupo aciloxila (-O-CO-CH3), caracterizando a função éster aromático.',
  ),
  const EnemQuestionModel(
    id: 'qui-org-q10',
    number: 10,
    yearSource: 'ENEM 2023',
    contextText:
        'A produção de biodiesel a partir de óleos vegetais residuais ou gordura animal envolve a reação com álcool de cadeia curta (metanol ou etanol) na presença de catalisador básico.',
    questionText:
        'Essa reação orgânica de conversão química é classicamente classificada como:',
    options: [
      'Polimerização por adição',
      'Transesterificação',
      'Fermentação lática anaeróbica',
      'Craqueamento catalítico térmico',
      'Saponificação ácida de amidos',
    ],
    correctOptionIndex: 1,
    explanation:
        'A reação de transesterificação consiste na transformação de um triglicerídeo (éster de glicerol) em ésteres metílicos ou etílicos de ácidos graxos (biodiesel) e glicerol (glicerina), mediante reação com álcool sob catálise.',
  ),
];

final List<EnemQuestionModel> biologiaCelularGeneticaQuestions = [
  const EnemQuestionModel(
    id: 'bio-cel-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'A Primeira Lei de Mendel (Lei da Segregação dos Fatores) estabelece que os pares de alelos se separam durante a gametogênese.',
    questionText:
        'No cruzamento entre dois indivíduos heterozigotos para o albinismo (Aa x Aa), sendo o albinismo uma condição autossômica recessiva, a probabilidade de o casal gerar uma criança albina é de:',
    options: [
      '0%',
      '25%',
      '50%',
      '75%',
      '100%',
    ],
    correctOptionIndex: 1,
    explanation:
        'Do cruzamento Aa x Aa obtêm-se os genótipos: 1/4 AA, 2/4 Aa e 1/4 aa. O albinismo recessivo manifesta-se unicamente em indivíduos homozigotos "aa". Portanto, a probabilidade é de 1/4 = 25%.',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'As organelas celulares desempenham papéis especializados fundamentais para a sobrevivência e homeostase dos eucariotos.',
    questionText:
        'A síntese de proteínas destinadas à exportação celular e a síntese de lipídios/esteroides ocorrem, respectivamente, no:',
    options: [
      'Retículo endoplasmático rugoso (granuloso) e retículo endoplasmático liso (não granuloso).',
      'Complexo de Golgi e lisossomo primário.',
      'Cloroplasto estromático e vacúolo autofágico.',
      'Ribossomo mitocondrial e peroxissomo.',
      'Nucléolo carioplasmático e centríolos.',
    ],
    correctOptionIndex: 0,
    explanation:
        'O Retículo Endoplasmático Rugoso (RER), revestido de ribossomos, sintetiza proteínas para exportação, membrana e lisossomos. O Retículo Endoplasmático Liso (REL) é responsável pela síntese de lipídios e esteroides e pela desintoxicação celular.',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q3',
    number: 3,
    yearSource: 'ENEM 2020',
    contextText:
        'A terapia gênica e a transgenia revolucionaram a biotecnologia moderna na agricultura e medicina.',
    questionText:
        'Um organismo é tecnicamente classificado como TRANSGÊNICO quando:',
    options: [
      'Sofre mutação espontânea induzida pela exposição a raios solares ultravioleta.',
      'Recebe e expressa funcionalmente em seu genoma um gene exógeno proveniente de outra espécie biologicamente distinta.',
      'É produzido por clonagem assexuada em laboratório a partir de células-tronco somáticas.',
      'Apresenta duplicação completa do seu número cromossômico por poliploidia.',
      'Produz anticorpos policlonais contra antígenos virais sem adoecer.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Organismo transgênico é um tipo de OGM (Organismo Geneticamente Modificado) que recebeu e integrou ao seu patrimônio genético um ou mais fragmentos de DNA (genes) vindos de outra espécie (ex: soja com gene bacteriano de resistência a herbicidas).',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q4',
    number: 4,
    yearSource: 'ENEM 2023',
    contextText:
        'A respiração celular aeróbica compreende três etapas metabólicas consecutivas: Glicólise, Ciclo de Krebs e Fosforilação Oxidativa (Cadeia Respiratória).',
    questionText:
        'O aceptor final de elétrons e prótons H+ na cadeia respiratória mitocondrial é:',
    options: [
      'O gás carbônico (CO2), que se converte em ácido lático.',
      'O oxigênio molecular (O2), que ao receber elétrons e hidrogênios forma água (H2O).',
      'O NAD+ oxidado na matriz citoplasmática.',
      'A molécula de glicose fosforilada.',
      'O trifosfato de adenosina (ATP).',
    ],
    correctOptionIndex: 1,
    explanation:
        'Na fosforilação oxidativa nas cristas mitocondriais, o gás oxigênio (O2) atua como o aceptor final de elétrons e prótons H+, gerando água (H2O) e permitindo o bombeamento de prótons pela ATP-sintase.',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'Durante a meiose I, na prófase I, os cromossomos homólogos pareados realizam a troca de segmentos de cromátides não irmãs (crossing-over ou permutação).',
    questionText:
        'A consequência evolutiva crucial do crossing-over para as populações de seres vivos é:',
    options: [
      'A duplicação imediata do número diploide de cromossomos na espécie.',
      'O aumento expressivo da variabilidade genética entre os gametas e descendentes.',
      'A reparação definitiva de mutações letais nas células somáticas.',
      'A eliminação total de alelos deletérios recessivos no cariótipo.',
      'A transformação de indivíduos heterozigotos em clones perfeitos da mãe.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O crossing-over recombina alelos maternos e paternos nas cromátides homólogas, gerando novas combinações genéticas nos gametas, o que amplia substancialmente a variabilidade genética da prole.',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'O teste de paternidade por DNA utiliza a técnica de PCR para amplificar regiões polimórficas do genoma humano conhecidas como microssatélites (STRs).',
    questionText:
        'Para que um indivíduo seja reconhecido como filho biológico de um casal, suas bandas eletroforéticas de DNA devem:',
    options: [
      'Ser 100% idênticas às bandas da mãe, dispensando o perfil paterno.',
      'Conter bandas herdadas metade da mãe biológica e metade do pai biológico.',
      'Apresentar peso molecular menor que qualquer fragmento bacteriano.',
      'Ser compostas unicamente por timinas e adeninas puras.',
      'Manifestar compatibilidade apenas com o cromossomo Y materno.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Como o ser humano herda 50% de seus cromossomos da mãe e 50% do pai, cada banda do teste eletroforético de DNA da criança que não for de origem materna deve corresponder obrigatoriamente a uma banda presente no perfil do pai biológico.',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'A técnica de clonagem reprodutiva de mamíferos (como a célebre ovelha Dolly) utilizou a transferência nuclear de células somáticas.',
    questionText:
        'A ovelha Dolly era geneticamente idêntica:',
    options: [
      'À ovelha receptora que gestou o feto em seu útero (mãe de aluguel).',
      'À ovelha doadora do núcleo celular contendo o DNA cromossômico.',
      'À ovelha doadora do óvulo anucleado.',
      'A uma mistura intermediária proporcional entre as três ovelhas.',
      'Ao carneiro reprodutor que forneceu o sêmen criogenado.',
    ],
    correctOptionIndex: 1,
    explanation:
        'O clone nuclear é geneticamente idêntico ao indivíduo doador do núcleo celular somático diploide. O óvulo enucleado e a mãe de aluguel apenas fornecem o citoplasma/energia mitocondrial e as condições gestacionais, respectivamente.',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'Em um heredograma familiar, um casal não afetado por uma determinada anomalia genética tem quatro filhos: três normais e um afetado pela condição.',
    questionText:
        'Essa observação genealógica permite concluir com certeza que o caráter é:',
    options: [
      'Dominante ligado ao cromossomo Y.',
      'Recessivo, pois pais não afetados originaram descendente afetado (pais heterozigotos portadores).',
      'Codominante com penetrância incompleta nos homens.',
      'Mutação letal mitocondrial materna.',
      'Herança holândrica restrita ao sexo feminino.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A regra de ouro dos heredogramas: pais fenotipicamente iguais gerando filho fenotipicamente diferente prova que o caráter é recessivo e que os pais são necessariamente heterozigotos portadores (Aa x Aa -> aa).',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q9',
    number: 9,
    yearSource: 'ENEM 2023',
    contextText:
        'Os lisossomos são vesículas citoplasmáticas delimitadas por membrana única e repletas de enzimas hidrolíticas (hidrolases ácidas).',
    questionText:
        'A principal função biológica desempenhada pelos lisossomos na célula animal é a:',
    options: [
      'Produção e fosforilação de ATP aeróbico.',
      'Digestão intracelular (heterofagia de partículas fagocitadas e autofagia de organelas velhas).',
      'Síntese de RNA ribossômico na carioteca.',
      'Fixação de carbono inorgânico no ciclo de Calvin.',
      'Formação do fuso mitótico de microtúbulos.',
    ],
    correctOptionIndex: 1,
    explanation:
        'Os lisossomos são os responsáveis pela digestão intracelular: digerem substâncias englobadas por fagocitose/pinocitose (heterofagia) e reciclam organelas envelhecidas e componentes celulares danificados (autofagia).',
  ),
  const EnemQuestionModel(
    id: 'bio-cel-q10',
    number: 10,
    yearSource: 'ENEM 2018',
    contextText:
        'O dogma central da biologia molecular sintetiza o fluxo da informação genética nas células:\nDNA -> RNA mensageiro -> Proteína.',
    questionText:
        'Os processos que convertem a sequência de DNA em RNAm e a sequência de RNAm em cadeia polipeptídica funcional denominam-se, respectivamente:',
    options: [
      'Replicação e duplicação semiconservativa.',
      'Transcrição e tradução.',
      'Tradução e mutagênese.',
      'Digestão e absorção ribossômica.',
      'Respiração e glicosilação.',
    ],
    correctOptionIndex: 1,
    explanation:
        'A síntese de uma molécula de RNAm a partir de um molde de DNA chama-se TRANSCRIÇÃO (mediada pela RNA-polimerase). A decodificação dos códons do RNAm pelos ribossomos e RNAt para montar a cadeia de aminoácidos chama-se TRADUÇÃO.',
  ),
];
