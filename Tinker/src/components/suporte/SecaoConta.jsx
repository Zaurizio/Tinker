import { useEffect, useMemo, useState } from "react";
import { FaPen } from "react-icons/fa";
import estiloConta from "../../pages/Conta.module.css";
import {
  atualizarPerfil,
  ehProfessor,
  obterPerfil,
} from "../../services/perfilService";

const perfilVazio = {
  nome: "",
  sobrenome: "",
  email: "",
  tipoUsuario: "",
  nascimento: "",
};

function formatarTipoUsuario(tipoUsuario) {
  return ehProfessor(tipoUsuario) ? "Professor" : "Aluno";
}

function SecaoConta() {
  const [perfil, setPerfil] = useState(perfilVazio);
  const [carregando, setCarregando] = useState(true);
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState("");
  const [sucesso, setSucesso] = useState("");
  const eProfessor = ehProfessor(perfil.tipoUsuario);

  const iniciais = useMemo(() => {
    const primeiraInicial = perfil.nome.trim().charAt(0);
    const segundaInicial = perfil.sobrenome.trim().charAt(0);
    return `${primeiraInicial}${segundaInicial}`.toUpperCase() || "US";
  }, [perfil.nome, perfil.sobrenome]);

  useEffect(() => {
    let componenteMontado = true;

    async function carregarPerfil() {
      setErro("");

      try {
        const dadosPerfil = await obterPerfil();
        if (componenteMontado) {
          setPerfil({
            nome: dadosPerfil.nome ?? "",
            sobrenome: dadosPerfil.sobrenome ?? "",
            email: dadosPerfil.email ?? "",
            tipoUsuario: dadosPerfil.tipoUsuario ?? "",
            nascimento: dadosPerfil.nascimento ?? "",
          });
        }
      } catch (erroPerfil) {
        if (componenteMontado) {
          setErro(
            erroPerfil instanceof Error
              ? erroPerfil.message
              : "Não foi possível carregar os dados da conta."
          );
        }
      } finally {
        if (componenteMontado) setCarregando(false);
      }
    }

    carregarPerfil();
    return () => {
      componenteMontado = false;
    };
  }, []);

  function atualizarCampo(campo, valor) {
    setPerfil((perfilAtual) => ({ ...perfilAtual, [campo]: valor }));
  }

  async function handleSalvar(evento) {
    evento.preventDefault();
    if (salvando || carregando) return;

    setSalvando(true);
    setErro("");
    setSucesso("");

    try {
      const perfilAtualizado = await atualizarPerfil(perfil);
      setPerfil((perfilAtual) => ({
        ...perfilAtual,
        nome: perfilAtualizado?.nome ?? perfilAtual.nome,
        sobrenome: perfilAtualizado?.sobrenome ?? perfilAtual.sobrenome,
        nascimento: eProfessor
          ? ""
          : perfilAtualizado?.nascimento ?? perfilAtual.nascimento,
      }));
      setSucesso("Dados atualizados com sucesso.");
    } catch (erroAtualizacao) {
      setErro(
        erroAtualizacao instanceof Error
          ? erroAtualizacao.message
          : "Não foi possível atualizar os dados da conta."
      );
    } finally {
      setSalvando(false);
    }
  }

  return (
    <article className={estiloConta.card}>
      <h2 className={estiloConta.tituloCard}>Minha Conta</h2>

      {carregando ? (
        <p className={estiloConta.mensagemConta} role="status">
          Carregando dados da conta...
        </p>
      ) : (
        <div className={estiloConta.contaConteudo}>
          <div className={estiloConta.fotoColuna}>
            <div className={estiloConta.avatar}>{iniciais}</div>
          </div>

          <form className={estiloConta.formularioConta} onSubmit={handleSalvar}>
            <label className={estiloConta.campo}>
              <span>Nome</span>
              <input
                type="text"
                value={perfil.nome}
                disabled={salvando}
                onChange={(evento) => atualizarCampo("nome", evento.target.value)}
              />
            </label>

            <label className={estiloConta.campo}>
              <span>Sobrenome</span>
              <input
                type="text"
                value={perfil.sobrenome}
                disabled={salvando}
                onChange={(evento) => atualizarCampo("sobrenome", evento.target.value)}
              />
            </label>

            <label className={estiloConta.campo}>
              <span>E-mail</span>
              <input type="email" value={perfil.email} readOnly />
            </label>

            <label className={estiloConta.campo}>
              <span>Tipo de conta</span>
              <input type="text" value={formatarTipoUsuario(perfil.tipoUsuario)} readOnly />
            </label>

            {erro && <p className={estiloConta.mensagemErro} role="alert">{erro}</p>}
            {sucesso && <p className={estiloConta.mensagemSucesso} role="status">{sucesso}</p>}

            <div className={estiloConta.acoesConta}>
              <button
                type="submit"
                className={estiloConta.botaoPrimario}
                disabled={salvando}
              >
                {salvando ? "Salvando..." : "Salvar alterações"}
                <FaPen />
              </button>
            </div>
          </form>
        </div>
      )}
    </article>
  );
}

export default SecaoConta;
