/// Configuração de Contas de Administrador / Desenvolvedor do Oráculo.
///
/// Como definir contas administradoras:
/// 1. Adicione os e-mails na lista [defaultAdminEmails] abaixo.
///    Qualquer usuário que fizer login (seja via E-mail/Senha ou via Google)
///    com um desses e-mails terá privilégios de Administrador.
/// 2. Administradores podem inserir livros, editar conteúdo e gerenciar outros admins.
/// 3. Usuários regulares (cujo e-mail não estiver na lista) NÃO podem alterar
///    ou inserir conteúdo de livros, tendo acesso estritamente de leitura.
class AdminConfig {
  static const List<String> defaultAdminEmails = [
    'khloeasp@gmail.com',
    'pessoa@gmail.com',
    // Adicione seus e-mails aqui:
    // 'seuemail@gmail.com',
  ];
}
