using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjStudio
{
    class ClasseAlunoTurma
    {
        private int cod_turma;
        private string email_aluno;
        private int ativo;

        public int Cod_turma { get => cod_turma; set => cod_turma = value; }
        public string Email_aluno { get => email_aluno; set => email_aluno = value; }
        public int Ativo { get => ativo; set => ativo = value; }

        public ClasseAlunoTurma(int cod_turma, string email_aluno, int ativo)
        {
            Cod_turma = cod_turma;
            Email_aluno = email_aluno;
            Ativo = ativo;
        }
        public ClasseAlunoTurma(int cod_turma, string email_aluno)
        {
            Cod_turma = cod_turma;
            Email_aluno = email_aluno;
        }
        public ClasseAlunoTurma(int cod_turma)
        {
            Cod_turma = cod_turma;
        }
        public bool Cadastro()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand cad = new MySqlCommand("insert into Aluno_Turma(cod_turma, email_aluno, ativo) values ("+cod_turma+" , '"+email_aluno+"', 1)", Conexao.con);
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
                MySqlCommand cad = new MySqlCommand("update Aluno_Turma set ativo = 0 where cod_turma = " + cod_turma + " and email_aluno = '"+email_aluno+"'", Conexao.con);
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
                MySqlCommand cad = new MySqlCommand("update Aluno_Turma set ativo = 1 where cod_turma = " + cod_turma + " and email_aluno = '" + email_aluno + "'", Conexao.con);
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
        public MySqlDataReader Consulta()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand con = new MySqlCommand("select email_aluno from Aluno_Turma where cod_turma = " + cod_turma + "", Conexao.con);
                ctrl = con.ExecuteReader();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return ctrl;
        }
        public bool Existe()
        {
            bool ctrl = false;
            try
            {
                Conexao.con.Open();
                MySqlCommand exis = new MySqlCommand("select count(*) from Aluno_Turma where cod_turma = " + cod_turma + " and email_aluno = '" + email_aluno + "'", Conexao.con);
                MySqlDataReader x = exis.ExecuteReader();
                if (x.Read())
                {
                    if (x.GetInt32(0) == 1)
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
        public MySqlDataReader BuscaEmails()
        {
            MySqlDataReader ctrl = null;
            try
            {
                Conexao.con.Open();
                MySqlCommand bus = new MySqlCommand("select email_aluno from Aluno_Turma where cod_turma = " + cod_turma + " and ativo = 1 order by email_aluno ASC", Conexao.con);
                ctrl = bus.ExecuteReader();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return ctrl;
        }
    }
}
