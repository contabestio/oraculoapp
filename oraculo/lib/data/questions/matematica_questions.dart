import '../../models/enem_question_model.dart';

/// Questões ENEM para os conteúdos de Matemática:
/// 1. Matemática e Funções ('matematica-e-funcoes') - 10 questões
/// 2. Geometria Espacial ('geometria-espacial') - 10 questões

final List<EnemQuestionModel> matematicaEFuncoesQuestions = [
  const EnemQuestionModel(
    id: 'mat-fun-q1',
    number: 1,
    yearSource: 'ENEM 2021',
    contextText:
        'Um aplicativo de transporte cobra uma taxa fixa de bandeirada no valor de R\$ 5,00 acrescida de R\$ 2,40 por quilômetro rodado. Um passageiro deseja realizar uma viagem de 15 km utilizando esse serviço.',
    questionText:
        'A função linear que descreve o valor total V(x) da corrida em função dos quilômetros x percorridos e o custo final dessa viagem de 15 km são, respectivamente:',
    options: [
      'V(x) = 5x + 2,40 e R\$ 77,40',
      'V(x) = 2,40x + 5 e R\$ 41,00',
      'V(x) = 2,40x - 5 e R\$ 31,00',
      'V(x) = 7,40x e R\$ 111,00',
      'V(x) = 15x + 5 e R\$ 230,00',
    ],
    correctOptionIndex: 1,
    explanation:
        'A lei de formação da função afim é V(x) = ax + b, onde "a" é o custo variável por km (2,40) e "b" é a taxa fixa (5,00). Logo: V(x) = 2,40x + 5. Para x = 15 km: V(15) = 2,40 · 15 + 5 = 36 + 5 = R\$ 41,00.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q2',
    number: 2,
    yearSource: 'ENEM 2020',
    contextText:
        'O lucro L (em milhares de reais) de uma pequena fábrica de calçados varia em função da quantidade x (em centenas de pares) produzida e vendida segundo a lei quadrática L(x) = -2x² + 16x - 14.',
    questionText:
        'Para obter o lucro máximo, a quantidade de centenas de pares que a fábrica deve produzir e o valor do lucro máximo atingido (em milhares de reais) são:',
    options: [
      'x = 4 e L = 18',
      'x = 8 e L = 32',
      'x = 4 e L = 14',
      'x = 2 e L = 10',
      'x = 6 e L = 22',
    ],
    correctOptionIndex: 0,
    explanation:
        'A coordenada Xv do vértice da parábola indica a quantidade para o lucro máximo: Xv = -b / (2a) = -16 / (2 · (-2)) = -16 / (-4) = 4. Substituindo na função para encontrar o lucro máximo: L(4) = -2(4)² + 16(4) - 14 = -32 + 64 - 14 = 18 mil reais.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q3',
    number: 3,
    yearSource: 'ENEM 2022',
    contextText:
        'O reservatório de água de um condomínio começou o dia com 20.000 litros. Devido a um consumo constante, o volume V (em litros) diminui linearmente com o tempo t (em horas) de acordo com a função V(t) = 20.000 - 800t.',
    questionText:
        'Em quantas horas o reservatório estará completamente esgotado (V = 0)?',
    options: [
      '15 horas',
      '20 horas',
      '25 horas',
      '30 horas',
      '40 horas',
    ],
    correctOptionIndex: 2,
    explanation:
        'Para calcular o tempo até o esvaziamento total, igualamos V(t) a zero: 20.000 - 800t = 0 => 800t = 20.000 => t = 20.000 / 800 = 25 horas.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q4',
    number: 4,
    yearSource: 'ENEM 2019',
    contextText:
        'A trajetória de um projétil lançado a partir do solo descreve uma parábola dada por h(t) = -5t² + 40t, onde h é a altura em metros e t é o tempo em segundos após o disparo.',
    questionText:
        'A altura máxima atingida pelo projétil e o tempo decorrido até ele atingir novamente o solo são, respectivamente:',
    options: [
      '40 m e 4 s',
      '80 m e 8 s',
      '80 m e 4 s',
      '100 m e 10 s',
      '60 m e 6 s',
    ],
    correctOptionIndex: 1,
    explanation:
        'O instante de altura máxima ocorre em t = -b / (2a) = -40 / (2 · (-5)) = 4 segundos. A altura máxima é h(4) = -5(16) + 40(4) = -80 + 160 = 80 metros. O projétil atinge o solo quando h(t) = 0: -5t(t - 8) = 0 => t = 0 (lançamento) ou t = 8 s (queda).',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q5',
    number: 5,
    yearSource: 'ENEM 2023',
    contextText:
        'Uma empresa de telefonia oferece dois planos: Plano Alfa com mensalidade fixa de R\$ 30,00 mais R\$ 0,50 por minuto de ligação; Plano Beta sem mensalidade fixa, porém cobrando R\$ 1,00 por minuto falado.',
    questionText:
        'A partir de quantos minutos de ligações mensais o Plano Alfa se torna mais vantajoso economicamente do que o Plano Beta?',
    options: [
      '30 minutos',
      '45 minutos',
      'Mais de 60 minutos',
      'Mais de 90 minutos',
      '120 minutos',
    ],
    correctOptionIndex: 2,
    explanation:
        'Custo Alfa: Ca(x) = 30 + 0,50x. Custo Beta: Cb(x) = 1,00x. Alfa é mais vantajoso quando Ca(x) < Cb(x) => 30 + 0,50x < 1,00x => 0,50x > 30 => x > 60 minutos.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q6',
    number: 6,
    yearSource: 'ENEM 2021',
    contextText:
        'Considere a função afim f(x) = ax + b representada em um plano cartesiano ortogonal. Observa-se que a reta passa pelos pontos P(0, -6) e Q(3, 0).',
    questionText:
        'Os coeficientes linear (b) e angular (a) dessa função são, respectivamente:',
    options: [
      'b = -6 e a = 2',
      'b = 0 e a = -6',
      'b = 3 e a = -2',
      'b = -6 e a = -2',
      'b = 6 e a = 3',
    ],
    correctOptionIndex: 0,
    explanation:
        'Como a reta cruza o eixo Y no ponto P(0, -6), o coeficiente linear é b = -6. O coeficiente angular é dado por a = (y2 - y1) / (x2 - x1) = (0 - (-6)) / (3 - 0) = 6 / 3 = 2. A função é f(x) = 2x - 6.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q7',
    number: 7,
    yearSource: 'ENEM 2020',
    contextText:
        'Um comerciante comprou um produto por R\$ 80,00 e o colocou à venda por um preço p. A quantidade q de unidades vendidas mensalmente varia linearmente com o preço segundo a relação q = 200 - 2p.',
    questionText:
        'O lucro mensal L(p) do comerciante é dado por (p - 80) · q. Para que o lucro seja maximizado, o preço de venda p deve ser estipulado em:',
    options: [
      'R\$ 85,00',
      'R\$ 90,00',
      'R\$ 95,00',
      'R\$ 100,00',
      'R\$ 110,00',
    ],
    correctOptionIndex: 1,
    explanation:
        'L(p) = (p - 80)(200 - 2p) = 200p - 2p² - 16.000 + 160p = -2p² + 360p - 16.000. O vértice ocorre em p = -b / (2a) = -360 / (2 · (-2)) = -360 / (-4) = R\$ 90,00.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q8',
    number: 8,
    yearSource: 'ENEM 2018',
    contextText:
        'Duas variáveis X e Y são inversamente proporcionais. Quando X vale 4, o valor de Y é 15.',
    questionText:
        'Qual será o valor de Y quando X for igual a 10?',
    options: [
      '6',
      '8',
      '12',
      '25',
      '37,5',
    ],
    correctOptionIndex: 0,
    explanation:
        'Grandezas inversamente proporcionais têm produto constante: X · Y = k. Assim, 4 · 15 = 60 (k = 60). Quando X = 10: 10 · Y = 60 => Y = 6.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q9',
    number: 9,
    yearSource: 'ENEM 2022',
    contextText:
        'No gráfico de uma função quadrática f(x) = ax² + bx + c com concavidade voltada para baixo, o vértice localiza-se no ponto V(2, 9) e o gráfico intercepta o eixo vertical no ponto (0, 5).',
    questionText:
        'As raízes reais dessa função são:',
    options: [
      'x = -1 e x = 5',
      'x = 1 e x = 5',
      'x = -2 e x = 4',
      'x = 0 e x = 6',
      'x = -3 e x = 3',
    ],
    correctOptionIndex: 0,
    explanation:
        'Pela forma canônica do vértice: f(x) = a(x - Xv)² + Yv = a(x - 2)² + 9. Como passa em (0, 5): 5 = a(0 - 2)² + 9 => 5 = 4a + 9 => 4a = -4 => a = -1. Logo f(x) = -(x - 2)² + 9. Igualando a zero: -(x - 2)² + 9 = 0 => (x - 2)² = 9 => x - 2 = ±3 => x = 5 ou x = -1.',
  ),
  const EnemQuestionModel(
    id: 'mat-fun-q10',
    number: 10,
    yearSource: 'ENEM 2023',
    contextText:
        'Uma gráfica estipulou o custo C de impressão de x exemplares de um livro escolar pela função afim C(x) = 12x + 1.500, onde 1.500 é o custo fixo de matriz gráfica e R\$ 12 é o custo variável por unidade impressa.',
    questionText:
        'Se o orçamento disponível pela escola contratante é de no máximo R\$ 7.500, o número máximo de exemplares que poderão ser impressos é:',
    options: [
      '400 exemplares',
      '500 exemplares',
      '600 exemplares',
      '625 exemplares',
      '750 exemplares',
    ],
    correctOptionIndex: 1,
    explanation:
        '12x + 1.500 ≤ 7.500 => 12x ≤ 6.000 => x ≤ 6.000 / 12 => x ≤ 500 exemplares.',
  ),
];

final List<EnemQuestionModel> geometriaEspacialQuestions = [
  const EnemQuestionModel(
    id: 'mat-geo-q1',
    number: 1,
    yearSource: 'ENEM 2022',
    contextText:
        'Uma lata de refrigerante cilíndrica tem raio da base medindo 3 cm e altura igual a 12 cm. Para fins de cálculo, utilize a aproximação π = 3,1.',
    questionText:
        'O volume interno total de líquido suportado por essa lata de refrigerante é de:',
    options: [
      '111,6 cm³',
      '223,2 cm³',
      '334,8 cm³',
      '446,4 cm³',
      '558,0 cm³',
    ],
    correctOptionIndex: 2,
    explanation:
        'O volume de um cilindro reto é V = Ab · h = π · r² · h. Substituindo os valores: V = 3,1 · (3)² · 12 = 3,1 · 9 · 12 = 3,1 · 108 = 334,8 cm³.',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q2',
    number: 2,
    yearSource: 'ENEM 2021',
    contextText:
        'Uma caixa d\'água de formato paralelepipédico retangular possui as seguintes dimensões internas: 2 metros de comprimento, 1,5 metro de largura e 1,2 metro de profundidade.',
    questionText:
        'Sabendo que 1 m³ equivale a 1.000 litros, a capacidade máxima dessa caixa d\'água é de:',
    options: [
      '1.800 litros',
      '2.400 litros',
      '3.600 litros',
      '4.200 litros',
      '5.000 litros',
    ],
    correctOptionIndex: 2,
    explanation:
        'O volume do paralelepípedo reto-retângulo é V = a · b · c = 2 · 1,5 · 1,2 = 3,6 m³. Convertendo para litros: 3,6 · 1.000 = 3.600 litros.',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q3',
    number: 3,
    yearSource: 'ENEM 2020',
    contextText:
        'Um silo para armazenamento de grãos tem o formato de um cilindro circular reto sobreposto por um cone de mesma base circular de raio R = 3 m. A altura da parte cilíndrica é de 8 m e a altura da parte cônica superior é de 3 m. Adote π = 3.',
    questionText:
        'O volume total de grãos suportado por esse silo em sua capacidade total é:',
    options: [
      '216 m³',
      '243 m³',
      '270 m³',
      '297 m³',
      '324 m³',
    ],
    correctOptionIndex: 1,
    explanation:
        'Volume do cilindro: Vcil = π · r² · hcil = 3 · 3² · 8 = 3 · 9 · 8 = 216 m³. Volume do cone: Vcone = (1/3) · π · r² · hcone = (1/3) · 3 · 3² · 3 = 27 m³. Volume total = 216 + 27 = 243 m³.',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q4',
    number: 4,
    yearSource: 'ENEM 2023',
    contextText:
        'A projeção ortogonal de uma figura tridimensional sobre um plano bidimensional é tema recorrente na prova de matemática do ENEM.',
    questionText:
        'Ao projetar ortogonalmente uma esfera opaca iluminada por raios de luz paralelos sobre um plano perpendicular aos feixes de luz, a sombra obtida no plano corresponde a um:',
    options: [
      'Triângulo isósceles',
      'Segmento de reta linear',
      'Círculo perfeito',
      'Quadrilátero circunscrito',
      'Elipsoide de revolução aberta',
    ],
    correctOptionIndex: 2,
    explanation:
        'A projeção ortogonal de uma esfera sobre qualquer plano bidimensional é sempre um círculo de mesmo raio que a seção equatorial da esfera.',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q5',
    number: 5,
    yearSource: 'ENEM 2019',
    contextText:
        'Uma fábrica de brinquedos produz dados cúbicos perfeitos de madeira maciça com aresta medindo 4 cm. Deseja-se pintar completamente todas as seis faces externas de cada dado.',
    questionText:
        'A área total da superfície a ser pintada em cada dado é de:',
    options: [
      '64 cm²',
      '96 cm²',
      '128 cm²',
      '144 cm²',
      '192 cm²',
    ],
    correctOptionIndex: 1,
    explanation:
        'O cubo tem 6 faces quadradas idênticas. A área de cada face é A = a² = 4² = 16 cm². A área total é At = 6 · 16 = 96 cm².',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q6',
    number: 6,
    yearSource: 'ENEM 2022',
    contextText:
        'Um fabricante de perfumes reduziu as dimensões lineares do frasco de um produto em 50% mantendo a mesma semelhança geométrica (escala linear k = 1/2).',
    questionText:
        'Com essa redução proporcional em todas as três dimensões, o volume de perfume contido no novo frasco será igual a:',
    options: [
      'Metade (1/2) do volume original',
      'Um quarto (1/4) do volume original',
      'Um oitavo (1/8) do volume original',
      'Um terço (1/3) do volume original',
      'Um décimo sexto (1/16) do volume original',
    ],
    correctOptionIndex: 2,
    explanation:
        'A razão entre volumes de sólidos geométricos semelhantes é igual ao cubo da razão linear de escala: V2 / V1 = k³ = (1/2)³ = 1/8. Portanto, o novo volume é 1/8 do original.',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q7',
    number: 7,
    yearSource: 'ENEM 2021',
    contextText:
        'Uma pirâmide regular de base quadrada tem o lado da base medindo 6 metros e altura h = 4 metros.',
    questionText:
        'O apótema lateral da pirâmide (altura de cada face triangular lateral) e o volume dessa pirâmide valem, respectivamente:',
    options: [
      '5 m e 48 m³',
      '6 m e 72 m³',
      '5 m e 144 m³',
      '4 m e 36 m³',
      '7 m e 96 m³',
    ],
    correctOptionIndex: 0,
    explanation:
        'Pelo Teorema de Pitágoras no triângulo retângulo interno: (apótema lateral)² = h² + (lado/2)² = 4² + 3² = 16 + 9 = 25 => apótema = 5 m. O volume é V = (1/3) · Ab · h = (1/3) · (6²) · 4 = (1/3) · 36 · 4 = 48 m³.',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q8',
    number: 8,
    yearSource: 'ENEM 2020',
    contextText:
        'Deseja-se construir uma embalagem cilíndrica com tampa cujo raio da base seja 5 cm e altura 10 cm. Adote π = 3.',
    questionText:
        'A quantidade total de papelão necessária para construir a superfície externa total (base inferior, tampa superior e superfície lateral) dessa embalagem é de:',
    options: [
      '300 cm²',
      '450 cm²',
      '500 cm²',
      '600 cm²',
      '750 cm²',
    ],
    correctOptionIndex: 1,
    explanation:
        'Área das duas bases circulares: 2 · (π · r²) = 2 · (3 · 25) = 150 cm². Área lateral: 2 · π · r · h = 2 · 3 · 5 · 10 = 300 cm². Área total: 150 + 300 = 450 cm².',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q9',
    number: 9,
    yearSource: 'ENEM 2023',
    contextText:
        'Uma esfera maciça de raio R = 6 cm é fundida e transformada em pequenos cilindros de raio r = 2 cm e altura h = 3 cm. O volume da esfera é V = (4/3) · π · R³ e o do cilindro é V = π · r² · h. Considere não haver perda de material.',
    questionText:
        'O número exato de cilindros que podem ser produzidos com o material dessa esfera é:',
    options: [
      '18',
      '24',
      '27',
      '36',
      '48',
    ],
    correctOptionIndex: 1,
    explanation:
        'Volume da esfera: Vesf = (4/3) · π · 6³ = (4/3) · π · 216 = 288π cm³. Volume de cada cilindro: Vcil = π · 2² · 3 = 12π cm³. Quantidade de cilindros = 288π / 12π = 24 cilindros.',
  ),
  const EnemQuestionModel(
    id: 'mat-geo-q10',
    number: 10,
    yearSource: 'ENEM 2019',
    contextText:
        'Um prisma hexagonal regular reto tem altura igual a 10 cm e o lado do hexágono da base mede 4 cm. Sabe-se que a área de um hexágono regular de lado L é 6 · (L²√3 / 4). Considere a aproximação √3 = 1,7.',
    questionText:
        'O volume desse prisma hexagonal regular é mais próximo de:',
    options: [
      '204 cm³',
      '340 cm³',
      '408 cm³',
      '512 cm³',
      '680 cm³',
    ],
    correctOptionIndex: 2,
    explanation:
        'Área da base hexagonal: Ab = 6 · (4² · 1,7 / 4) = 6 · (16 · 1,7 / 4) = 6 · (4 · 1,7) = 6 · 6,8 = 40,8 cm². Volume: V = Ab · h = 40,8 · 10 = 408 cm³.',
  ),
];
