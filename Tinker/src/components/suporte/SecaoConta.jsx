import { useMemo, useState } from "react";
import { FaCamera, FaPen } from "react-icons/fa";
import estiloSuporte from "../../pages/Suporte.module.css";

function carregarPerfilInicial() {
  const perfilPadrao = {
    nome: "Gustavo",
    sobrenome: "Zaurizio",
  };

  const usuarioSalvo = localStorage.getItem("usuario");

  if (!usuarioSalvo) return perfilPadrao;

  try {
    const usuario = JSON.parse(usuarioSalvo);
    const partesNome = usuario?.nome?.trim().split(" ").filter(Boolean);

    if (!partesNome?.length) return perfilPadrao;

    return {
      nome: partesNome[0],
      sobrenome: partesNome.slice(1).join(" ") || perfilPadrao.sobrenome,
    };
  } catch (error) {
    console.error("Erro ao carregar usuário do localStorage:", error);
    return perfilPadrao;
  }
}

function SecaoConta() {
  const [perfil, setPerfil] = useState(carregarPerfilInicial);
  const { nome, sobrenome } = perfil;

  const iniciais = useMemo(() => {
    const primeiraInicial = nome.trim().charAt(0);
    const segundaInicial = sobrenome.trim().charAt(0);
    return `${primeiraInicial}${segundaInicial}`.toUpperCase() || "US";
  }, [nome, sobrenome]);

  function handleAlterarFoto() {
    console.log("Alterar foto");
  }

  function handleEditarPerfil() {
    console.log("Editar perfil", { nome, sobrenome });
  }

  return (
    <article className={estiloSuporte.card}>
      <h2 className={estiloSuporte.tituloCard}>Minha Conta</h2>

      <div className={estiloSuporte.contaConteudo}>
        <div className={estiloSuporte.fotoColuna}>
          <div className={estiloSuporte.avatar}>{iniciais}</div>
          <button
            type="button"
            className={estiloSuporte.botaoSecundario}
            onClick={handleAlterarFoto}
          >
            <FaCamera />
            Alterar foto
          </button>
        </div>

        <div className={estiloSuporte.formularioConta}>
          <label className={estiloSuporte.campo}>
            <span>Nome</span>
            <input
              type="text"
              value={nome}
              onChange={(evento) =>
                setPerfil((perfilAtual) => ({
                  ...perfilAtual,
                  nome: evento.target.value,
                }))
              }
            />
          </label>

          <label className={estiloSuporte.campo}>
            <span>Sobrenome</span>
            <input
              type="text"
              value={sobrenome}
              onChange={(evento) =>
                setPerfil((perfilAtual) => ({
                  ...perfilAtual,
                  sobrenome: evento.target.value,
                }))
              }
            />
          </label>

          <div className={estiloSuporte.acoesConta}>
            <button
              type="button"
              className={estiloSuporte.botaoPrimario}
              onClick={handleEditarPerfil}
            >
              Editar perfil
              <FaPen />
            </button>
          </div>
        </div>
      </div>
    </article>
  );
}

export default SecaoConta;
