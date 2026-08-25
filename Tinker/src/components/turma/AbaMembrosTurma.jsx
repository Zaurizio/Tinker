import { useEffect, useState } from "react";
import { MdPerson } from "react-icons/md";
import { listarMembrosDaTurma } from "../../services/turmaService";
import estiloMembros from "./AbaMembrosTurma.module.css";

const ROTULOS_PAPEIS = {
  administrador: "Administrador",
  professor: "Professor",
  aluno: "Aluno",
};

function AbaMembrosTurma({ turmaId }) {
  const [membros, setMembros] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarMembros() {
      setCarregando(true);
      setErro("");

      try {
        const membrosCarregados = await listarMembrosDaTurma(turmaId);
        if (carregamentoAtivo) setMembros(membrosCarregados);
      } catch {
        if (carregamentoAtivo) {
          setErro("Não foi possível carregar os membros.");
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarMembros();

    return () => {
      carregamentoAtivo = false;
    };
  }, [turmaId]);

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
          membros.map((membro) => {
            const administrador = membro.tipo === "administrador";

            return (
              <div
                key={membro.id}
                className={`${estiloMembros.membro} ${
                  administrador ? estiloMembros.administrador : ""
                }`}
              >
                <div className={estiloMembros.foto}>
                  {membro.fotoPerfil ? (
                    <img src={membro.fotoPerfil} alt="" />
                  ) : (
                    <MdPerson aria-hidden="true" />
                  )}
                </div>

                <div className={estiloMembros.identificacao}>
                  <span className={estiloMembros.nome}>{membro.nome}</span>
                  <span className={estiloMembros.papel}>
                    {ROTULOS_PAPEIS[membro.tipo] ?? membro.tipo}
                  </span>
                </div>
              </div>
            );
          })
        )}
      </div>
    </section>
  );
}

export default AbaMembrosTurma;
