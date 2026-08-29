import { Navigate, Outlet } from "react-router";
import { estaAutenticado } from "../../services/autenticacaoService";

function RotaProtegida() {
  if (!estaAutenticado()) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}

export default RotaProtegida;
