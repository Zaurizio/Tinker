using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjStudio
{
    class ClasseLogin
    {
        private string login;
        private int senha;

        public string Login { get => login; set => login = value; }
        public int Senha { get => senha; set => senha = value; }

        public ClasseLogin(string login, int senha)
        {
            Login = login;
            Senha = senha;
        }
        public ClasseLogin(string login)
        {
            Login = login;
        }
        public ClasseLogin()
        {
        }

        public bool Cadastro()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand cadastra = new MySqlCommand("insert into Administrador (login, senha) values ('" + login + "', " + senha + ")", Conexao.con);
                cadastra.ExecuteNonQuery();
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
        public bool Entrada()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand entrar = new MySqlCommand("select * from Administrador where login = '" + login + "' and senha = " + senha + "", Conexao.con);
                MySqlDataReader resultado = entrar.ExecuteReader();
                if (resultado.Read())
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
        public MySqlDataReader buscaTodos()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand busca = new MySqlCommand("select login from Administrador", Conexao.con);
                ctrl = busca.ExecuteReader();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return ctrl;
        }
        public bool excluir()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand exclui = new MySqlCommand("delete from Administrador where login = '" + login + "'", Conexao.con);
                exclui.ExecuteNonQuery();
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
