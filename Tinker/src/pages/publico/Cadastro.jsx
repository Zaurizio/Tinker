import { useState } from 'react'
import { useNavigate } from 'react-router'
import { IoIosArrowBack } from 'react-icons/io'
import Card from '../../components/ui/Card'
import estiloLogin from './Login.module.css'
import estiloCad from './Cadastro.module.css'
import { fazerCadastro } from '../../services/autenticacaoService'

function Cadastro() {
  const [nome, setNome] = useState('')
  const [sobrenome, setSobrenome] = useState('')
  const [email, setEmail] = useState('')
  const [senha, setSenha] = useState('')
  const [tipoUsuario, setTipoUsuario] = useState('ALUNO')
  const [nascimento, setNascimento] = useState('')
  const [carregando, setCarregando] = useState(false)
  const [erro, setErro] = useState('')
  const navigate = useNavigate()

  function selecionarTipo(novoTipo) {
    setTipoUsuario(novoTipo)
    if (novoTipo === 'PROFESSOR') setNascimento('')
  }

  async function cadastrar(event) {
    event.preventDefault()
    setCarregando(true)
    setErro('')

    try {
      await fazerCadastro({ nome, sobrenome, email, senha, nascimento: tipoUsuario === 'ALUNO' ? nascimento : null, tipoUsuario })
      navigate('/login')
    } catch (error) {
      setErro(error.message || 'Não foi possível criar a conta. Tente novamente.')
    } finally {
      setCarregando(false)
    }
  }

  return (
    <div className={estiloLogin.pagina}>
      <div className={estiloLogin.topo}>
        <button type="button" className={estiloLogin.voltar} onClick={() => navigate(-1)} aria-label="Voltar">
          <span className={estiloLogin.icone}><IoIosArrowBack /></span>
        </button>
      </div>

      <div className={estiloLogin.centro}>
        <Card className={estiloCad.card}>
          <div className={estiloLogin.logoContainer}>
            <img src="/logoCirc.png" alt="Logo Tinker" className={estiloLogin.logoImage} />
            <span className={estiloLogin.logotipo}>Tinker</span>
          </div>
          <h1 className={estiloLogin.titulo}>Cadastrar</h1>
          <p className={estiloLogin.subtitulo}>Crie sua conta para continuar</p>

          <form className={estiloLogin.formulario} onSubmit={cadastrar}>
            <div className={estiloCad.camposDuplos}>
              <div className={estiloCad.campoDuplo}>
                <label className={estiloLogin.label} htmlFor="cadastro-nome">Nome</label>
                <input id="cadastro-nome" className={estiloLogin.input} type="text" placeholder="seu nome" value={nome} onChange={(event) => setNome(event.target.value)} required />
              </div>
              <div className={estiloCad.campoDuplo}>
                <label className={estiloLogin.label} htmlFor="cadastro-sobrenome">Sobrenome</label>
                <input id="cadastro-sobrenome" className={estiloLogin.input} type="text" placeholder="seu sobrenome" value={sobrenome} onChange={(event) => setSobrenome(event.target.value)} required />
              </div>
            </div>
            <div className={estiloLogin.campo}>
              <label className={estiloLogin.label} htmlFor="cadastro-email">E-mail</label>
              <input id="cadastro-email" className={estiloLogin.input} type="email" placeholder="seu@email.com" value={email} onChange={(event) => setEmail(event.target.value)} required />
            </div>
            <div className={estiloLogin.campo}>
              <label className={estiloLogin.label} htmlFor="cadastro-senha">Senha</label>
              <input id="cadastro-senha" className={estiloLogin.input} type="password" placeholder="sua senha" value={senha} onChange={(event) => setSenha(event.target.value)} required />
            </div>

            <div className={estiloLogin.seletorConta}>
              <span className={estiloLogin.label}>Quero me cadastrar como</span>
              <div className={estiloLogin.opcoesConta}>
                <button type="button" className={estiloLogin.opcaoConta} aria-pressed={tipoUsuario === 'ALUNO'} onClick={() => selecionarTipo('ALUNO')}>Aluno</button>
                <button type="button" className={estiloLogin.opcaoConta} aria-pressed={tipoUsuario === 'PROFESSOR'} onClick={() => selecionarTipo('PROFESSOR')}>Professor</button>
              </div>
              <p className={estiloCad.avisoTipoConta}>
                Você ainda poderá criar outra conta como aluno ou professor com o mesmo e-mail.
              </p>
            </div>

            {tipoUsuario === 'ALUNO' && (
              <div className={estiloLogin.campo}>
                <label className={estiloLogin.label} htmlFor="cadastro-nascimento">Nascimento</label>
                <input id="cadastro-nascimento" className={estiloLogin.input} type="date" value={nascimento} onChange={(event) => setNascimento(event.target.value)} required />
              </div>
            )}

            {erro && <p className={estiloLogin.mensagemErro} role="alert">{erro}</p>}
            <button type="submit" className={estiloLogin.botao} disabled={carregando}>{carregando ? 'Criando conta...' : 'Criar conta'}</button>
          </form>

          <p className={estiloLogin.rodape}>Já tem conta?{' '}<a href="/login" className={estiloLogin.link}>Fazer login</a></p>
        </Card>
      </div>
    </div>
  )
}

export default Cadastro
