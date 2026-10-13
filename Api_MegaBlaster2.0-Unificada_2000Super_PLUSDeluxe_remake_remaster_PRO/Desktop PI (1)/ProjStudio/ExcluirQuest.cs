using Guna.UI2.WinForms;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ProjStudio
{
    public partial class ExcluirQuest: Form
    {
        public ExcluirQuest()
        {
            InitializeComponent();
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

        private void guna2Button2_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrWhiteSpace(guna2TextBox1.Text))
            {
                MessageBox.Show("Preencha o campo ID antes");
            }
            else
            {
                try
                {
                    ClasseQuestao ce = new ClasseQuestao(int.Parse(guna2TextBox1.Text));
                    MySqlDataReader r = ce.Consulta();
                    try
                    {
                        if (r.Read())
                        {
                            guna2TextBox4.Text = r["vestibular"].ToString();
                            guna2TextBox2.Text = r["disciplina"].ToString();
                            guna2TextBox3.Text = r["conteudo"].ToString();
                            guna2TextBox7.Text = r["enunciado"].ToString();
                            guna2TextBox5.Text = r["ano"].ToString();
                            guna2TextBox6.Text = r["fase"].ToString();
                        }
                        else
                            MessageBox.Show("Digite o Email Corretamente");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                    }
                    Conexao.con.Close();
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            
            try
            {
                ClasseQuestao ce = new ClasseQuestao(int.Parse(guna2TextBox1.Text));
                if (ce.Exclui())
                {
                    MessageBox.Show("Exclusão Realizada com Sucesso");
                    guna2TextBox1.Text = "";
                    guna2TextBox2.Text = "";
                    guna2TextBox3.Text = "";
                    guna2TextBox4.Text = "";
                    guna2TextBox5.Text = "";
                    guna2TextBox6.Text = "";
                    guna2TextBox7.Text = "";
                }
                else
                    MessageBox.Show("Errro na Exclusão");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Preencha o ID Corretamente");
            }
        }

        private void ExcluirQuest_Load(object sender, EventArgs e)
        {

        }
    }
}
