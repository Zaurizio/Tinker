import { useEffect } from "react";
import { BrowserRouter, Navigate, Routes, Route } from "react-router";

// Layouts
import LayoutPublico from "./components/layout/LayoutPublico";
import LayoutPrivado from "./components/layout/LayoutPrivado";
import RotaProtegida from "./components/rotas/RotaProtegida";

// Páginas públicas
import Introducao from "./pages/publico/Introducao";
import Login from "./pages/publico/Login";
import Cadastro from "./pages/publico/Cadastro";
//import Planos from "./pages/publico/Planos";

// Páginas privadas
import Home from "./pages/Home";
import Questoes from "./pages/Questoes";
import Simulados from "./pages/Simulados";
import DetalhesSimulado from "./pages/DetalhesSimulado";
import Desempenho from "./pages/Desempenho";
import Calendario from "./pages/Calendario";
import Turma from "./pages/Turma";
import DetalhesTurma from "./pages/DetalhesTurma";
import ExecutarSimuladoTurma from "./pages/ExecutarSimuladoTurma";
import Suporte from "./pages/Suporte";

function App() {
  useEffect(() => {
    const temaSalvo = localStorage.getItem("tema");
    document.body.classList.toggle("dark-mode", temaSalvo === "escuro");
  }, []);

  return (
    <BrowserRouter>
      <Routes>
        <Route element={<LayoutPublico />}>
          <Route path="/" element={<Introducao />} />
          <Route path="/login" element={<Login />} />
          
          <Route path="/cadastro" element={<Cadastro />} />
          {/*
          <Route path="/planos" element={<Planos />} />
          */}
        </Route>

        <Route element={<RotaProtegida />}>
          <Route element={<LayoutPrivado />}>
            <Route path="/home" element={<Home />} />
            <Route path="/questoes" element={<Questoes />} />
            <Route path="/simulados" element={<Simulados />} />
            <Route path="/simulados/:simuladoId" element={<DetalhesSimulado />} />
            <Route path="/desempenho" element={<Desempenho />} />

            <Route path="/calendario" element={<Calendario />} />
            <Route path="/turma" element={<Turma />} />
            <Route
              path="/turma/:codigo"
              element={<Navigate to="simulados" replace />}
            />
            <Route path="/turma/:codigo/simulados" element={<DetalhesTurma />} />
            <Route
              path="/turma/:codigo/simulados/:idPublicacao"
              element={<ExecutarSimuladoTurma />}
            />
            <Route
              path="/turma/:codigo/eventos"
              element={<Navigate to="../simulados" relative="path" replace />}
            />
            <Route path="/turma/:codigo/membros" element={<DetalhesTurma />} />
            <Route path="/suporte" element={<Suporte />} />
          </Route>
        </Route>

      </Routes>
    </BrowserRouter>
  );
}

export default App;
