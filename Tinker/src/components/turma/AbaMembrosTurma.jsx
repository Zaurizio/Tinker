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

function AbaMembrosTurma({ codigo, usuarioAdministrador }) {
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
        ) : membros.length === 0 ? (
          <div className={estiloMembros.estado}>Nenhum membro encontrado.</div>
        ) : (
          membros.map((membro) => (
            <div key={membro.email} className={estiloMembros.membro}>
              <div className={estiloMembros.foto}>
                <MdPerson aria-hidden="true" />
              </div>

              <div className={estiloMembros.identificacao}>
                <span className={estiloMembros.nome}>{membro.nomeCompleto}</span>
                <span className={estiloMembros.papel}>{membro.email}</span>
              </div>

              {usuarioAdministrador && (
                <button
                  type="button"
                  className={estiloMembros.botaoRemover}
                  onClick={() => {
                    setErroRemocao("");
                    setMembroParaRemover(membro);
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
