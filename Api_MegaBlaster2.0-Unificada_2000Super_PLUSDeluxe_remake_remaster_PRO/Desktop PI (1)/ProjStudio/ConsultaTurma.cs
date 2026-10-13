using Guna.UI2.WinForms;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ProjStudio
{
    public partial class ConsultaTurma: Form
    {
        public ConsultaTurma()
        {
            InitializeComponent();
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text))
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            else
            {
                try
                {
                    ClasseTurma ct = new ClasseTurma(guna2TextBox1.Text, guna2TextBox2.Text);
                    MySqlDataReader r = null;
                    r = ct.Consulta();
                    if (r != null && r.Read())
                    {
                        guna2TextBox3.Text = r["cod_turma"].ToString();
                        if (int.Parse(r["ativo"].ToString()) == 1)
                            guna2TextBox4.Text = "Ativo";
                        else
                            guna2TextBox4.Text = "Inativo";
                        Conexao.con.Close();
                        ClasseAlunoTurma cat = new ClasseAlunoTurma(int.Parse(guna2TextBox3.Text));
                        MySqlDataReader r2 = cat.BuscaEmails();
                        guna2DataGridView1.Rows.Clear();
                        while (r2.Read())
                        {
                            guna2DataGridView1.Rows.Add(r2["email_aluno"].ToString());
                        }
                        Conexao.con.Close();
                    }
                    else
                        MessageBox.Show("Erro ao Consultar");
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                    MessageBox.Show("Nome da Turma ou Email do Professor Digitado Incorretamente");
                }
            }
        }

        private void ConsultaTurma_Load(object sender, EventArgs e)
        {

        }

        private void guna2Button2_Click(object sender, EventArgs e)
        {
            if (guna2TextBox4.Text == "Inativo")
            {
                try
                {
                    ClasseTurma ct = new ClasseTurma(guna2TextBox1.Text, guna2TextBox2.Text);
                    bool g = ct.Reativa();
                    guna2TextBox4.Text = "Ativo";
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
            
        }

        private void buttonHome_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Home formHome = new Home();
            formHome.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonAdm_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Administrador formAdm = new Administrador();
            formAdm.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonAluno_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Aluno formAluno = new Aluno();
            formAluno.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonProf_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Professor formProf = new Professor();
            formProf.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonQuest_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Questoes formQuest = new Questoes();
            formQuest.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonAlunoP_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            AlunoProf formAlunoP = new AlunoProf();
            formAlunoP.Show();

            // Esconde o form
            this.Hide();
        }

        private void guna2Button3_Click(object sender, EventArgs e)
        {
            guna2TextBox1.Text = "";
            guna2TextBox2.Text = "";
            guna2TextBox3.Text = "";
            guna2TextBox4.Text = "";
            guna2DataGridView1.Rows.Clear();
        }
    }
}
