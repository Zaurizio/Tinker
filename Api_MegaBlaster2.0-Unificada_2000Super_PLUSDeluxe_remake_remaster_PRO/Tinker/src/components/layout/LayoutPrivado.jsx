import { Outlet } from "react-router";
import Sidebar from "./Sidebar";
import estiloLayout from "./LayoutPrivado.module.css";

function LayoutPrivado() {
  return (
    <div className={estiloLayout.container}>
      <Sidebar />
      <main className={estiloLayout.conteudo}>
        <Outlet />
      </main>
    </div>
  );
}

export default LayoutPrivado;