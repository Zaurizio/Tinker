import { useNavigate } from "react-router";
import estiloIntro from "./Introducao.module.css";

function Introducao() {
  const navigate = useNavigate();

  return (
    <div className={estiloIntro.pagina}>
      <div className={estiloIntro.conteudo}>

        <div className={estiloIntro.hero}>        
            
            <div className={estiloIntro.logoContainer}>
                <img src="/logoCirc.png" alt="Logo Tinker" className={estiloIntro.logoImage} />
                <span className={estiloIntro.logotipo}>Tinker</span>
            </div>

            <h1 className={estiloIntro.titulo}>
                Estude com mais foco.<br />Chegue mais longe.
            </h1>
            <p className={estiloIntro.descricao}>
                Questões de vestibular, simulados, desempenho e colaboração
                com sua turma — tudo em um só lugar.
            </p>

            <div className={estiloIntro.acoes}>
                <button
                className={estiloIntro.botaoPrimario}
                onClick={() => navigate("/cadastro")}
                >
                Criar conta
                </button>
                <button
                className={estiloIntro.botaoSecundario}
                onClick={() => navigate("/login")}
                >
              Já tenho conta
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}

export default Introducao;