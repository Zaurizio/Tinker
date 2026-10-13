using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjStudio
{
    class ClasseAluno
    {
        private string email;
        private string senha;
        private byte[] foto;
        private string nome;
        private string sobrenome;
        private string nascimento;
        private int ativo;

        public string Email { get => email; set => email = value; }
        public string Senha { get => senha; set => senha = value; }
        public byte[] Foto { get => foto; set => foto = value; }
        public string Nome { get => nome; set => nome = value; }
        public string Sobrenome { get => sobrenome; set => sobrenome = value; }
        public string Nascimento { get => nascimento; set => nascimento = value; }
        public int Ativo { get => ativo; set => ativo = value; }

        public ClasseAluno(string email, string senha, string nome, string sobrenome, string nascimento, byte[] foto, int ativo)
        {
            Email = email;
            Senha = senha;
            Foto = foto;
            Nome = nome;
            Sobrenome = sobrenome;
            Nascimento = nascimento;
            Ativo = ativo;

        }
        public ClasseAluno(string email, string senha, string nome, string sobrenome, string nascimento, int ativo)
        {
            Email = email;
            Senha = senha;
            Nome = nome;
            Sobrenome = sobrenome;
            Nascimento = nascimento;
            Ativo = ativo;

        }
        public ClasseAluno(string email)
        {
            Email = email;
        }
        public ClasseAluno()
        {

        }
        public int Contagem()
        {
            int ctrl = 0;
            try
            {
                Conexao.con.Open();
                MySqlCommand cont = new MySqlCommand("select count(*) from Aluno", Conexao.con);
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
                MySqlCommand cad = new MySqlCommand("insert into Aluno(email, senha, nome, sobrenome, nascimento, foto, ativo) values ('" + email + "', '" + senha + "', '" + nome + "', '" + sobrenome + "', '"  + nascimento + "', '" + foto + "', 1)", Conexao.con);
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
                MySqlCommand atu = new MySqlCommand("update Aluno set senha = '" + senha + "', nome = '" + nome + "', sobrenome = '" + sobrenome + "', nascimento = '" + nascimento + "', foto = '" + foto + "', ativo = " + ativo + " where email = '" + email + "'", Conexao.con);
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
        
        public bool Exclui()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand exc = new MySqlCommand("update Aluno set ativo = 0 where email = '" + email + "'", Conexao.con);
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

        public MySqlDataReader Consulta()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand cons = new MySqlCommand("select * from Aluno where email = '" + email + "'", Conexao.con);
                ctrl = cons.ExecuteReader();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return ctrl;
        }
        public MySqlDataReader ConsultaAtivo()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand cons = new MySqlCommand("select * from Aluno where email = '" + email + "' and ativo = 1", Conexao.con);
                ctrl = cons.ExecuteReader();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return ctrl;
        }
        
    }
}
