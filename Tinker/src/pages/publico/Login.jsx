import { useState } from 'react'
import { useNavigate } from 'react-router'
import { IoIosArrowBack } from 'react-icons/io'
import Card from '../../components/ui/Card'
import estilo from './Login.module.css'
import { fazerLogin, salvarSessao } from '../../services/autenticacaoService'

function Login() {
  const [email, setEmail] = useState('')
  const [senha, setSenha] = useState('')
  const [tipoUsuario, setTipoUsuario] = useState('ALUNO')
  const [carregando, setCarregando] = useState(false)
  const [erro, setErro] = useState('')
  const navigate = useNavigate()

  async function logar(event) {
    event.preventDefault()
    setCarregando(true)
    setErro('')

    try {
      const dadosLogin = await fazerLogin({ email, senha, tipoUsuario })
      salvarSessao(dadosLogin)
      navigate('/home')
    } catch (error) {
      setErro(error.message || 'Não foi possível fazer login. Tente novamente.')
    } finally {
      setCarregando(false)
    }
  }

  return (
    <div className={estilo.pagina}>
      <div className={estilo.topo}>
        <button type="button" className={estilo.voltar} onClick={() => navigate(-1)} aria-label="Voltar">
          <span className={estilo.icone}><IoIosArrowBack /></span>
        </button>
      </div>

      <div className={estilo.centro}>
        <Card className={estilo.card}>
          <div className={estilo.logoContainer}>
            <img src="/logoCirc.png" alt="Logo Tinker" className={estilo.logoImage} />
            <span className={estilo.logotipo}>Tinker</span>
          </div>
          <h1 className={estilo.titulo}>Entrar</h1>
          <p className={estilo.subtitulo}>Acesse sua conta para continuar</p>

          <form className={estilo.formulario} onSubmit={logar}>
            <div className={estilo.campo}>
              <label className={estilo.label} htmlFor="login-email">E-mail</label>
              <input id="login-email" className={estilo.input} type="email" placeholder="seu@email.com" value={email} onChange={(event) => setEmail(event.target.value)} required />
            </div>
            <div className={estilo.campo}>
              <label className={estilo.label} htmlFor="login-senha">Senha</label>
              <input id="login-senha" className={estilo.input} type="password" placeholder="sua senha" value={senha} onChange={(event) => setSenha(event.target.value)} required />
            </div>

            <div className={estilo.seletorConta}>
              <span className={estilo.label}>Quero fazer login como</span>
              <div className={estilo.opcoesConta}>
                <button type="button" className={estilo.opcaoConta} aria-pressed={tipoUsuario === 'ALUNO'} onClick={() => setTipoUsuario('ALUNO')}>Aluno</button>
                <button type="button" className={estilo.opcaoConta} aria-pressed={tipoUsuario === 'PROFESSOR'} onClick={() => setTipoUsuario('PROFESSOR')}>Professor</button>
              </div>
            </div>

            {erro && <p className={estilo.mensagemErro} role="alert">{erro}</p>}
            <button type="submit" className={estilo.botao} disabled={carregando}>{carregando ? 'Entrando...' : 'Entrar'}</button>
          </form>

          <p className={estilo.rodape}>Não tem conta?{' '}<a href="/cadastro" className={estilo.link}>Criar conta</a></p>
        </Card>
      </div>
    </div>
  )
}

export default Login
