// Dados simulados de usuários
const usuariosSimulados = [
  {
    id: 1,
    nome: "João",
    sobrenome: "Silva",
    email: "joao@email.com",
    senha: "123456"
  },
  {
    id: 2,
    nome: "Maria",
    sobrenome: "Santos",
    email: "maria@email.com",
    senha: "1234567"
  }
];

// Simula login
export function fazerLogin(email, senha) {
  return new Promise((resolve) => {
    setTimeout(() => {
      const usuario = usuariosSimulados.find(
        u => u.email === email && u.senha === senha
      );

      if (usuario) {
        resolve({
          sucesso: true,
          usuario: {
            id: usuario.id,
            nome: usuario.nome,
            sobrenome: usuario.sobrenome,
            email: usuario.email
          }
        });
      } 
      else {
        resolve({
          sucesso: false,
          mensagem: "Email ou senha incorretos"
        });
      }
    }, 1000); // Simula 1 segundo de delay
  });
}

// Simula cadastro
export function fazerCadastro(nome, sobrenome, email, senha) {
  return new Promise((resolve) => {
    setTimeout(() => {
      // Verifica se email já existe
      const emailExiste = usuariosSimulados.some(u => u.email === email);

      if (emailExiste) {
        resolve({
          sucesso: false,
          mensagem: "Este email já está cadastrado"
        });
      } else {
        // Cria novo usuário
        const novoUsuario = {
          id: usuariosSimulados.length + 1,
          nome,
          sobrenome,
          email,
          senha
        };

        usuariosSimulados.push(novoUsuario);

        resolve({
          sucesso: true,
          mensagem: "Cadastro realizado com sucesso",
          usuario: {
            id: novoUsuario.id,
            nome: novoUsuario.nome,
            sobrenome: novoUsuario.sobrenome,
            email: novoUsuario.email
          }
        });
      }
    }, 1000); // Simula 1 segundo de delay
  });
}