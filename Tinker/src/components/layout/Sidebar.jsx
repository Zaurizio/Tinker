import { useState } from "react"
import { NavLink, useNavigate } from "react-router"
/*menu*/ import { TiThMenu } from "react-icons/ti"; //<TiThMenu />
/*setinha*/ import { MdKeyboardArrowRight } from "react-icons/md"; //<MdKeyboardArrowRight />
/*home*/ import { FaHome } from "react-icons/fa"; //<FaHome />
/*questoes*/ import { BsCardChecklist } from "react-icons/bs"; //<BsCardChecklist />
/*simulado*/ import { IoDocumentTextOutline } from "react-icons/io5"; //<IoDocumentTextOutline />
/*desempenho*/ import { SiGoogleanalytics } from "react-icons/si"; //<SiGoogleanalytics />
/*calendario*/ import { TbCalendarEvent } from "react-icons/tb"; //<TbCalendarEvent />
/*turma*/ import { MdGroups } from "react-icons/md"; //<MdGroups />
/*conta*/ import { FaUserCircle } from "react-icons/fa"; //<FaUserCircle />
/*sair*/ import { IoIosLogOut } from "react-icons/io"; //<IoIosLogOut />

import { RiBarChartFill } from "react-icons/ri";
import { TbTargetArrow } from "react-icons/tb";
import { FaRegNoteSticky } from "react-icons/fa6";
import { FaRegCheckCircle } from "react-icons/fa";
import { FaRegCircleCheck } from "react-icons/fa6";

import ModalConfirmarAcaoTurma from "../turma/ModalConfirmarAcaoTurma";
import { encerrarSessao } from "../../services/autenticacaoService";

import estiloSidebar from './Sidebar.module.css'

function Sidebar() {
    const navigate = useNavigate();
    const [confirmandoSaida, setConfirmandoSaida] = useState(false);

    function handleSair() {
        encerrarSessao();
        navigate("/login");
    }

    return(
        <aside className={estiloSidebar.sidebar}> {/*conteudo lateral*/}
            <div className={estiloSidebar.topo}>
                <div className={estiloSidebar.logoContainer}>
                    <img src="/logoCirc.png" alt="Logo Tinker" className={estiloSidebar.logoImage} />
                    <h1 className={estiloSidebar.logoText}>Tinker</h1> {/*colocar fonte*/}
                </div>
            </div>

            {/*navegação*/}
            <nav className={estiloSidebar.nav}>
                {/*HOME*/}
                <NavLink
                to="/home"
                end
                className={({ isActive }) => /*true se tiver ativo*/
                    isActive
                    ? `${estiloSidebar.link} ${estiloSidebar.ativo}` /*se tiver ativo*/
                    : estiloSidebar.link /*se n tiver*/
                }
                >
                <span className={estiloSidebar.icone}>
                    <FaHome />
                </span>
                <span className={estiloSidebar.texto}>Home</span>
                </NavLink>

                {/*QUESTÕES*/}
                <NavLink
                to="/questoes"
                className={({ isActive }) =>
                    isActive
                    ? `${estiloSidebar.link} ${estiloSidebar.ativo}`
                    : estiloSidebar.link
                }
                >
                <span className={estiloSidebar.icone}>
                    <FaRegCircleCheck />
                </span>
                <span className={estiloSidebar.texto}>Questões</span>
                </NavLink>

                {/*SIMULADOS*/}
                <NavLink
                to="/simulados"
                className={({ isActive }) =>
                    isActive
                    ? `${estiloSidebar.link} ${estiloSidebar.ativo}`
                    : estiloSidebar.link
                }
                >
                <span className={estiloSidebar.icone}>
                    <IoDocumentTextOutline />
                </span>
                <span className={estiloSidebar.texto}>Simulados</span>
                </NavLink>

                {/*DESEMPENHO*/}
                <NavLink
                to="/desempenho"
                className={({ isActive }) =>
                    isActive
                    ? `${estiloSidebar.link} ${estiloSidebar.ativo}`
                    : estiloSidebar.link
                }
                >
                <span className={estiloSidebar.icone}>
                    {/*<RiBarChartFill />*/}
                    <TbTargetArrow />
                </span>
                <span className={estiloSidebar.texto}>Desempenho</span>
                </NavLink>

                {/*CALENDÁRIO*/}
                <NavLink
                to="/calendario"
                className={({ isActive }) =>
                    isActive
                    ? `${estiloSidebar.link} ${estiloSidebar.ativo}`
                    : estiloSidebar.link
                }
                >
                <span className={estiloSidebar.icone}>
                    <TbCalendarEvent />
                </span>
                <span className={estiloSidebar.texto}>Calendário</span>
                </NavLink>

                {/*TURMA*/}
                <NavLink
                to="/turma"
                className={({ isActive }) =>
                    isActive
                    ? `${estiloSidebar.link} ${estiloSidebar.ativo}`
                    : estiloSidebar.link
                }
                >
                <span className={estiloSidebar.icone}>
                    <MdGroups />
                </span>
                <span className={estiloSidebar.texto}>Turma</span>
                </NavLink>

                {/*CONTA*/}
                <NavLink
                to="/conta"
                className={({ isActive }) =>
                    isActive
                    ? `${estiloSidebar.link} ${estiloSidebar.ativo}`
                    : estiloSidebar.link
                }
                >
                <span className={estiloSidebar.icone}>
                    <FaUserCircle />
                </span>
                <span className={estiloSidebar.texto}>Conta</span>
                </NavLink>

                {/*SAIR*/}
                <button
                type="button"
                className={`${estiloSidebar.linkButton} ${estiloSidebar.linkSair}`}
                onClick={() => setConfirmandoSaida(true)}
                >
                <span className={estiloSidebar.icone}>
                    <IoIosLogOut />
                </span>
                <span className={estiloSidebar.texto}>Sair</span>
                </button>
            </nav>

            {confirmandoSaida && (
                <ModalConfirmarAcaoTurma
                titulo="Sair"
                descricao="Tem certeza que deseja sair da sua conta?"
                textoConfirmar="Sair"
                onFechar={() => setConfirmandoSaida(false)}
                onConfirmar={handleSair}
                />
            )}
        </aside>
    )
}
export default Sidebar 