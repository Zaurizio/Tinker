import { useRef } from "react";
import { obterSessaoArmazenada } from "../services/sessaoStorage";

function Jogo() {
  const iframeRef = useRef(null);

  // manda o token do login para o jogo conseguir buscar as questoes
  const token = obterSessaoArmazenada()?.token ?? "";
  const src = `/game/index.html?token=${encodeURIComponent(token)}`;

  return (
    <iframe
      ref={iframeRef}
      src={src}
      title="Tinker Game"
      allow="fullscreen"
      onLoad={() => iframeRef.current?.focus()}
      style={{ width: "100%", height: "100vh", border: "none", display: "block" }}
    />
  );
}

export default Jogo;