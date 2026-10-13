using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjStudio
{
    class ClasseEducador
    {
        private string email;
        private string senha;
        private string nome;
        private string sobrenome;
        private byte[] foto;
        private int ativo;

        public string Email { get => email; set => email = value; }
        public string Senha { get => senha; set => senha = value; }
        public string Nome { get => nome; set => nome = value; }
        public int Ativo { get => ativo; set => ativo = value; }
        public string Sobrenome { get => sobrenome; set => sobrenome = value; }
        public byte[] Foto { get => foto; set => foto = value; }

        public ClasseEducador(string email, string senha, string nome, string sobrenome, byte[] foto, int ativo)
        {
            Email = email;
            Senha = senha;
            Nome = nome;
            Sobrenome = sobrenome;
            Foto = foto;
            Ativo = ativo;
        }
        public ClasseEducador(string email, string senha, string nome, string sobrenome, int ativo)
        {
            Email = email;
            Senha = senha;
            Nome = nome;
            Sobrenome = sobrenome;
            Ativo = ativo;
        }
        public ClasseEducador(string email)
        {
            Email = email;
        }
        public ClasseEducador()
        {
        }
        public int Contagem()
        {
            int ctrl = 0;
            try
            {
                Conexao.con.Open();
                MySqlCommand cont = new MySqlCommand("select count(*) from Professor", Conexao.con);
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
        public bool cadastro()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand cad = new MySqlCommand("insert into Professor(email, senha, nome, sobrenome, foto, ativo) values ('" + email + "', '" + senha + "', '" + nome + "', '" + sobrenome + "', '" + foto + "', 1)", Conexao.con);
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

        public MySqlDataReader consulta()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand consu = new MySqlCommand("select * from Professor where email = '" + email + "'", Conexao.con);
                ctrl = consu.ExecuteReader();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return ctrl;
        }

        public bool atualiza()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand atu = new MySqlCommand("update Professor set senha = '" + senha + "', nome = '" + nome + "', ativo = " + ativo + ", sobrenome = '" + sobrenome + "', foto = '" + foto + "' where email = '" + email + "'", Conexao.con);
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

        public bool exclui()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand excluir = new MySqlCommand("update Professor set ativo = 0 where email = '" + email + "'", Conexao.con);
                excluir.ExecuteNonQuery();
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
