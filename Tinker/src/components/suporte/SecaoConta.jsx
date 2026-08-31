import { useEffect, useMemo, useRef, useState } from "react";
import { FaPen } from "react-icons/fa";
import estiloConta from "../../pages/Conta.module.css";
import Skeleton from "../ui/Skeleton";
import {
  atualizarPerfil,
  ehProfessor,
  enviarFotoPerfil,
  obterPerfil,
  TAMANHO_MAXIMO_FOTO,
  TIPOS_FOTO_PERMITIDOS,
} from "../../services/perfilService";
import { obterCache, definirCache } from "../../services/cacheStore";
import { CHAVE_PERFIL } from "../../services/cacheChaves";
import { useEsqueletoAtrasado } from "../../hooks/useEsqueletoAtrasado";

const perfilVazio = {
  nome: "",
  sobrenome: "",
  email: "",
  tipoUsuario: "",
  nascimento: "",
  foto: null,
};

function formatarTipoUsuario(tipoUsuario) {
  return ehProfessor(tipoUsuario) ? "Professor" : "Aluno";
}

function SecaoConta() {
  const [perfil, setPerfil] = useState(() => obterCache(CHAVE_PERFIL) ?? perfilVazio);
  const [carregando, setCarregando] = useState(() => obterCache(CHAVE_PERFIL) === undefined);
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState("");
  const [sucesso, setSucesso] = useState("");
  const [enviandoFoto, setEnviandoFoto] = useState(false);
  const [erroFoto, setErroFoto] = useState("");
  const inputFotoRef = useRef(null);
  const eProfessor = ehProfessor(perfil.tipoUsuario);
  const mostrarEsqueleto = useEsqueletoAtrasado(carregando);

  const iniciais = useMemo(() => {
    const primeiraInicial = perfil.nome.trim().charAt(0);
    const segundaInicial = perfil.sobrenome.trim().charAt(0);
    return `${primeiraInicial}${segundaInicial}`.toUpperCase() || "US";
  }, [perfil.nome, perfil.sobrenome]);

  useEffect(() => {
    let componenteMontado = true;

    async function carregarPerfil() {
      const emCache = obterCache(CHAVE_PERFIL);
      setCarregando(emCache === undefined);
      setErro("");

      try {
        const dadosPerfil = await obterPerfil();
        if (componenteMontado) {
          const perfilCarregado = {
            nome: dadosPerfil.nome ?? "",
            sobrenome: dadosPerfil.sobrenome ?? "",
            email: dadosPerfil.email ?? "",
            tipoUsuario: dadosPerfil.tipoUsuario ?? "",
            nascimento: dadosPerfil.nascimento ?? "",
            foto: dadosPerfil.foto ?? null,
          };
          setPerfil(perfilCarregado);
          definirCache(CHAVE_PERFIL, perfilCarregado);
        }
      } catch (erroPerfil) {
        if (componenteMontado && emCache === undefined) {
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
      setPerfil((perfilAtual) => {
        const perfilAtualizadoCompleto = {
          ...perfilAtual,
          nome: perfilAtualizado?.nome ?? perfilAtual.nome,
          sobrenome: perfilAtualizado?.sobrenome ?? perfilAtual.sobrenome,
          nascimento: eProfessor
            ? ""
            : perfilAtualizado?.nascimento ?? perfilAtual.nascimento,
        };
        definirCache(CHAVE_PERFIL, perfilAtualizadoCompleto);
        return perfilAtualizadoCompleto;
      });
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

  function handleEscolherFoto() {
    inputFotoRef.current?.click();
  }

  async function handleFotoSelecionada(evento) {
    const arquivo = evento.target.files?.[0];
    evento.target.value = "";
    if (!arquivo || enviandoFoto) return;

    setErroFoto("");

    if (!TIPOS_FOTO_PERMITIDOS.includes(arquivo.type)) {
      setErroFoto("A foto deve estar no formato JPG ou PNG.");
      return;
    }
    if (arquivo.size > TAMANHO_MAXIMO_FOTO) {
      setErroFoto("A foto deve ter no máximo 2MB.");
      return;
    }

    setEnviandoFoto(true);

    try {
      const perfilAtualizado = await enviarFotoPerfil(arquivo);
      setPerfil((perfilAtual) => {
        const perfilAtualizadoCompleto = {
          ...perfilAtual,
          foto: perfilAtualizado?.foto ?? perfilAtual.foto,
        };
        definirCache(CHAVE_PERFIL, perfilAtualizadoCompleto);
        return perfilAtualizadoCompleto;
      });
    } catch (erroEnvio) {
      setErroFoto(
        erroEnvio instanceof Error
          ? erroEnvio.message
          : "Não foi possível enviar a foto."
      );
    } finally {
      setEnviandoFoto(false);
    }
  }

  return (
    <article className={estiloConta.card}>
      <h2 className={estiloConta.tituloCard}>Minha Conta</h2>

      {carregando ? (
        mostrarEsqueleto ? (
          <div className={estiloConta.contaConteudo} aria-hidden="true">
            <div className={estiloConta.fotoColuna}>
              <Skeleton width="138px" height="138px" radius="50%" />
              <Skeleton width="140px" height="44px" radius="12px" />
            </div>

            <div className={estiloConta.formularioConta}>
              <Skeleton height="48px" radius="12px" />
              <Skeleton height="48px" radius="12px" />
              <Skeleton height="48px" radius="12px" />
              <Skeleton height="48px" radius="12px" />
            </div>
          </div>
        ) : null
      ) : (
        <div className={estiloConta.contaConteudo}>
          <div className={estiloConta.fotoColuna}>
            <div className={estiloConta.avatar}>
              {perfil.foto ? (
                <img src={perfil.foto} alt="Foto de perfil" />
              ) : (
                iniciais
              )}
            </div>

            <input
              type="file"
              ref={inputFotoRef}
              accept="image/jpeg,image/png"
              onChange={handleFotoSelecionada}
              hidden
            />
            <button
              type="button"
              className={estiloConta.botaoSecundario}
              onClick={handleEscolherFoto}
              disabled={enviandoFoto}
            >
              {enviandoFoto ? "Enviando..." : "Escolher foto"}
            </button>

            {erroFoto && (
              <p className={estiloConta.mensagemErro} role="alert">
                {erroFoto}
              </p>
            )}
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
