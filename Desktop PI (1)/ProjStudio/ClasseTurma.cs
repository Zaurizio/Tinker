using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjStudio
{
    class ClasseTurma
    {
        private int cod_turma;
        private string nome_turma;
        private string email_prof;
        private int ativo;

        public int Cod_turma { get => cod_turma; set => cod_turma = value; }
        public string Nome_turma { get => nome_turma; set => nome_turma = value; }
        public string Email_prof { get => email_prof; set => email_prof = value; }
        public int Ativo { get => ativo; set => ativo = value; }

        public ClasseTurma(string nome_turma, string email_prof, int ativo)
        {
            Nome_turma = nome_turma;
            Email_prof = email_prof;
            Ativo = ativo;
        }
        public ClasseTurma(string nome_turma, string email_prof)
        {
            Nome_turma = nome_turma;
            Email_prof = email_prof;
        }
        public ClasseTurma(int cod_turma)
        {
            Cod_turma = cod_turma;
        }
        public ClasseTurma()
        {

        }

        public int Contagem()
        {
            int ctrl = 0;
            try
            {
                Conexao.con.Open();
                MySqlCommand cont = new MySqlCommand("select count(*) from Turma", Conexao.con);
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
                MySqlCommand cad = new MySqlCommand("insert into Turma(nome_turma, email_prof, ativo) values ('" + nome_turma + "', '" + email_prof + "', 1)", Conexao.con);
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

        public bool Exclui()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand cad = new MySqlCommand("update Turma set ativo = 0 where nome_turma = '" + nome_turma+"' and email_prof = '"+email_prof+"'", Conexao.con);
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

        public bool Reativa()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand cad = new MySqlCommand("update Turma set ativo = 1 where nome_turma = '" + nome_turma + "' and email_prof = '" + email_prof + "'", Conexao.con);
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
        public bool Existe()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand exi = new MySqlCommand("select count(*) from Turma where nome_turma = '" + nome_turma + "' and email_prof = '" + email_prof + "'", Conexao.con);
                MySqlDataReader y = exi.ExecuteReader();
                if (y.Read())
                {
                    if (y.GetInt32(0) == 1)
                        ctrl = true;
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
        public bool ExisteAtivo()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand exi = new MySqlCommand("select count(*) from Turma where cod_turma = " + cod_turma + " and ativo = 1", Conexao.con);
                MySqlDataReader y = exi.ExecuteReader();
                if (y.Read())
                {
                    int qtd = Convert.ToInt32(y[0]);
                    if (qtd == 1)
                        ctrl = true;
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
        public bool Status()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand cons = new MySqlCommand("select ativo from Turma where nome_turma = '" + nome_turma + "' and email_prof = '" + email_prof + "'", Conexao.con);
                MySqlDataReader y = cons.ExecuteReader();
                if (y.Read())
                {
                    if (y.GetInt32(0) == 1)
                        ctrl = true;
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

       
        public MySqlDataReader Consulta()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand cons = new MySqlCommand("select * from Turma where nome_turma = '" + nome_turma + "' and email_prof = '" + email_prof + "'", Conexao.con);
                Console.WriteLine("select * from Turma where nome_turma = '" + nome_turma + "' and email_prof = '" + email_prof + "'");
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
