using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Drawing.Printing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ListView;

namespace ProjStudio
{
    class ClasseQuestao
    {
        private int cod;
        private string vestibular;
        private int ano;
        private string fase;
        private string disciplina;
        private string conteudo;
        private string enunciado;
        private byte[] imagem;
        private string alternativaA;
        private string alternativaB;
        private string alternativaC;
        private string alternativaD;
        private string alternativaE;
        private string resposta;
        private int ativo;

        public int Cod { get => cod; set => cod = value; }
        public string Vestibular { get => vestibular; set => vestibular = value; }
        public int Ano { get => ano; set => ano = value; }
        public string Fase { get => fase; set => fase = value; }
        public string Disciplina { get => disciplina; set => disciplina = value; }
        public string Conteudo { get => conteudo; set => conteudo = value; }
        public string Enunciado { get => enunciado; set => enunciado = value; }
        public byte[] Imagem { get => imagem; set => imagem = value; }
        public string AlternativaA { get => alternativaA; set => alternativaA = value; }
        public string AlternativaB { get => alternativaB; set => alternativaB = value; }
        public string AlternativaC { get => alternativaC; set => alternativaC = value; }
        public string AlternativaD { get => alternativaD; set => alternativaD = value; }
        public string AlternativaE { get => alternativaE; set => alternativaE = value; }
        public string Resposta { get => resposta; set => resposta = value; }
        public int Ativo { get => ativo; set => ativo = value; }

        public ClasseQuestao()
        {

        }

        public ClasseQuestao(int cod, string vestibular, int ano, string fase, string disciplina, string conteudo, string enunciado, string alternativaA, string alternativaB, string alternativaC, string alternativaD, string alternativaE, string resposta, byte[] imagem, int ativo)
        {   
            this.cod = cod;
            this.vestibular = vestibular;
            this.ano = ano;
            this.fase = fase;
            this.disciplina = disciplina;
            this.conteudo = conteudo;
            this.enunciado = enunciado;
            this.alternativaA = alternativaA;
            this.alternativaB = alternativaB;
            this.alternativaC = alternativaC;
            this.alternativaD = alternativaD;
            this.alternativaE = alternativaE;
            this.resposta = resposta;
            this.imagem = imagem;
            this.ativo = ativo;
        }
        public ClasseQuestao(string vestibular, int ano, string fase, string disciplina, string conteudo, string enunciado, string alternativaA, string alternativaB, string alternativaC, string alternativaD, string alternativaE, string resposta, byte[] imagem, int ativo)
        {
            this.vestibular = vestibular;
            this.ano = ano;
            this.fase = fase;
            this.disciplina = disciplina;
            this.conteudo = conteudo;
            this.enunciado = enunciado;
            this.alternativaA = alternativaA;
            this.alternativaB = alternativaB;
            this.alternativaC = alternativaC;
            this.alternativaD = alternativaD;
            this.alternativaE = alternativaE;
            this.resposta = resposta;
            this.imagem = imagem;
            this.ativo = ativo;
        }
        public ClasseQuestao(string vestibular, int ano, string fase, string disciplina, string conteudo, string enunciado,  string resposta, byte[] imagem, int ativo)
        {
            this.vestibular = vestibular;
            this.ano = ano;
            this.fase = fase;
            this.disciplina = disciplina;
            this.conteudo = conteudo;
            this.enunciado = enunciado;
            this.resposta = resposta;
            this.imagem = imagem;
            this.ativo = ativo;
        }
        public ClasseQuestao(int cod, string vestibular, int ano, string fase, string disciplina, string conteudo, string enunciado, string resposta, byte[] imagem, int ativo)
        {
            this.cod = cod;
            this.vestibular = vestibular;
            this.ano = ano;
            this.fase = fase;
            this.disciplina = disciplina;
            this.conteudo = conteudo;
            this.enunciado = enunciado;
            this.resposta = resposta;
            this.imagem = imagem;
            this.ativo = ativo;
        }
        public ClasseQuestao(int cod)
        {
            this.cod = cod;
        }

        public int Contagem()
        {
            int ctrl = 0;
            try
            {
                Conexao.con.Open();
                MySqlCommand cont = new MySqlCommand("select count(*) from Questao", Conexao.con);
                MySqlDataReader resultado = cont.ExecuteReader();
                if (resultado.Read())
                {
                    ctrl = resultado.GetInt32(0);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                Conexao.con.Close();
            }
            return ctrl;
        }

        public bool Cadastro()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                Console.WriteLine("Teste1");
                MySqlCommand cad = new MySqlCommand("insert into Questao(vestibular, ano, fase, disciplina, conteudo, enunciado, imagem, alternativaA, alternativaB, alternativaC, alternativaD, alternativaE, resposta, ativo) values ('" + vestibular + "', '" + ano + "', '" + fase + "', '" + disciplina + "', '" + conteudo + "', '" + enunciado + "',  '" + imagem + "', '" + alternativaA + "', '" + alternativaB + "', '" + alternativaC + "', '" + alternativaD + "', '" + alternativaE + "', '" + resposta + "', 1)", Conexao.con);
                Console.WriteLine("Teste2");
                cad.ExecuteNonQuery();
                ctrl = true;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                Conexao.con.Close();
            }
            return ctrl;
        }

        public bool Atualiza()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand atu = new MySqlCommand("update Questao set vestibular = '" + vestibular + "', ano = '" + ano + "', fase = '" + fase + "', disciplina = '" + disciplina + "', conteudo = '" + conteudo + "', enunciado = '" + enunciado + "', imagem = '" + imagem + "', alternativaA = '" + alternativaA + "', alternativaB = '" + alternativaB + "', alternativaC = '" + alternativaC + "', alternativaD = '" + alternativaD + "', alternativaE = '" + alternativaE + "', resposta = '" + resposta + "', ativo = " + ativo + "  where cod_questao = " + cod + "", Conexao.con);
                atu.ExecuteNonQuery();
                ctrl = true;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                Conexao.con.Close();
            }
            return ctrl;
        }

        public MySqlDataReader Consulta()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand cons = new MySqlCommand("select * from Questao where cod_questao = " + cod + "", Conexao.con);
                ctrl = cons.ExecuteReader();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return ctrl;
        }

        public bool Exclui()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand exc = new MySqlCommand("update Questao set ativo = 0 where cod_questao = " + cod + "", Conexao.con);
                exc.ExecuteNonQuery();
                ctrl = true;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                Conexao.con.Close();
            }
            return ctrl;
        }
    }
}
