import { NavLink } from "react-router"
/*menu*/ import { TiThMenu } from "react-icons/ti"; //<TiThMenu />
/*setinha*/ import { MdKeyboardArrowRight } from "react-icons/md"; //<MdKeyboardArrowRight />
/*home*/ import { FaHome } from "react-icons/fa"; //<FaHome />
/*questoes*/ import { BsCardChecklist } from "react-icons/bs"; //<BsCardChecklist />
/*simulado*/ import { IoDocumentTextOutline } from "react-icons/io5"; //<IoDocumentTextOutline />
/*desempenho*/ import { SiGoogleanalytics } from "react-icons/si"; //<SiGoogleanalytics />
/*calendario*/ import { TbCalendarEvent } from "react-icons/tb"; //<TbCalendarEvent />
/*turma*/ import { MdGroups } from "react-icons/md"; //<MdGroups />
/*conta*/ import { FaUserCircle } from "react-icons/fa"; //<FaUserCircle />

import { RiBarChartFill } from "react-icons/ri";
import { TbTargetArrow } from "react-icons/tb";
import { FaRegNoteSticky } from "react-icons/fa6";
import { FaRegCheckCircle } from "react-icons/fa";
import { FaRegCircleCheck } from "react-icons/fa6";


import estiloSidebar from './Sidebar.module.css'

function Sidebar() {
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
            </nav>
        </aside>
    )
}
export default Sidebar 