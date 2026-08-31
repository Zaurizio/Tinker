import { useEffect, useRef, useState } from "react";
import { MdPerson } from "react-icons/md";
import {
  listarMembrosDaTurmaDaConta,
  removerMembroDaTurmaDaConta,
} from "../../services/turmasApiService";
import ModalConfirmarAcaoTurma from "./ModalConfirmarAcaoTurma";
import estiloMembros from "./AbaMembrosTurma.module.css";

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function AbaMembrosTurma({
  codigo,
  usuarioAdministrador,
  professorCriador,
  fotoProfessorCriador,
}) {
  const [membros, setMembros] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [membroParaRemover, setMembroParaRemover] = useState(null);
  const [removendo, setRemovendo] = useState(false);
  const [erroRemocao, setErroRemocao] = useState("");
  const removendoRef = useRef(false);

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarMembros() {
      setCarregando(true);
      setErro("");

      try {
        const membrosCarregados = await listarMembrosDaTurmaDaConta(codigo);
        if (carregamentoAtivo) setMembros(membrosCarregados);
      } catch (erroCarregamento) {
        if (carregamentoAtivo) {
          setErro(
            formatarErroApi(
              erroCarregamento,
              "Não foi possível carregar os membros.",
            ),
          );
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarMembros();
    return () => {
      carregamentoAtivo = false;
    };
  }, [codigo]);

  async function handleRemoverMembro() {
    if (!membroParaRemover || removendoRef.current) return;

    removendoRef.current = true;
    setRemovendo(true);
    setErroRemocao("");

    try {
      await removerMembroDaTurmaDaConta(codigo, membroParaRemover.email);
      setMembros((membrosAtuais) =>
        membrosAtuais.filter(
          (membro) => membro.email !== membroParaRemover.email,
        ),
      );
      setMembroParaRemover(null);
    } catch (erroOperacao) {
      setErroRemocao(
        formatarErroApi(erroOperacao, "Não foi possível remover o membro."),
      );
    } finally {
      removendoRef.current = false;
      setRemovendo(false);
    }
  }

  const cardProfessor = professorCriador
    ? {
        chave: "professor",
        nomeCompleto: professorCriador,
        papel: "Professor",
        foto: fotoProfessorCriador ?? null,
        ehProfessor: true,
      }
    : null;
  const cardsAlunos = membros.map((membro) => ({
    chave: membro.email,
    nomeCompleto: membro.nomeCompleto,
    papel: membro.email,
    foto: membro.foto ?? null,
    ehProfessor: false,
    membro,
  }));
  const listaExibida = cardProfessor
    ? [cardProfessor, ...cardsAlunos]
    : cardsAlunos;

  return (
    <section aria-labelledby="titulo-membros">
      <h2 id="titulo-membros">Membros</h2>
      <p>Participantes desta turma</p>

      <div className={estiloMembros.lista}>
        {carregando ? (
          <div className={estiloMembros.estado} role="status">
            Carregando membros...
          </div>
        ) : erro ? (
          <div className={estiloMembros.estado} role="alert">
            {erro}
          </div>
        ) : listaExibida.length === 0 ? (
          <div className={estiloMembros.estado}>Nenhum membro encontrado.</div>
        ) : (
          listaExibida.map((item) => (
            <div
              key={item.chave}
              className={`${estiloMembros.membro} ${
                item.ehProfessor ? estiloMembros.administrador : ""
              }`}
            >
              <div className={estiloMembros.foto}>
                {item.foto ? (
                  <img src={item.foto} alt="" />
                ) : (
                  <MdPerson aria-hidden="true" />
                )}
              </div>

              <div className={estiloMembros.identificacao}>
                <span className={estiloMembros.nome}>{item.nomeCompleto}</span>
                <span className={estiloMembros.papel}>{item.papel}</span>
              </div>

              {usuarioAdministrador && !item.ehProfessor && (
                <button
                  type="button"
                  className={estiloMembros.botaoRemover}
                  onClick={() => {
                    setErroRemocao("");
                    setMembroParaRemover(item.membro);
                  }}
                  disabled={removendo}
                >
                  Remover
                </button>
              )}
            </div>
          ))
        )}
      </div>

      {membroParaRemover && (
        <ModalConfirmarAcaoTurma
          titulo="Remover membro"
          descricao={`Remover ${membroParaRemover.nomeCompleto} desta turma?`}
          textoConfirmar="Remover"
          processando={removendo}
          erro={erroRemocao}
          onConfirmar={handleRemoverMembro}
          onFechar={() => {
            if (!removendo) setMembroParaRemover(null);
          }}
        />
      )}
    </section>
  );
}

export default AbaMembrosTurma;
