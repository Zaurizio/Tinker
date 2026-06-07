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
    public partial class ExcluirTurma: Form
    {
        public ExcluirTurma()
        {
            InitializeComponent();
        }

        private void ExcluirTurma_Load(object sender, EventArgs e)
        {

        }

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if(e.KeyChar == 13)
            {
                guna2TextBox2.Focus();
            }
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text))
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            else
            {
                try
                {
                    ClasseTurma ct = new ClasseTurma(guna2TextBox2.Text, guna2TextBox1.Text);
                    if (ct.Status())
                    {
                        if (ct.Exclui()) 
                        { 
                            MessageBox.Show("Exclusão Realizada com Sucesso");
                            guna2TextBox1.Text = "";
                            guna2TextBox2.Text = "";
                        }
                        else
                            MessageBox.Show("Erro na Exclusão");
                    }
                    else
                        MessageBox.Show("Esta Turma é Inexistente ou Inativa");
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                    MessageBox.Show("Preencha Todos os Campos");
                }
            }
                
        }

        private void guna2TextBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text))
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                else
                {
                    try
                    {
                        ClasseTurma ct = new ClasseTurma(guna2TextBox2.Text, guna2TextBox1.Text);
                        if (ct.Status())
                        {
                            if (ct.Exclui())
                            {
                                MessageBox.Show("Exclusão Realizada com Sucesso");
                                guna2TextBox1.Text = "";
                                guna2TextBox2.Text = "";
                            }
                            else
                                MessageBox.Show("Erro na Exclusão");
                        }
                        else
                            MessageBox.Show("Esta Turma é Inexistente ou Inativa");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                        MessageBox.Show("Preencha Todos os Campos");
                    }
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
    }
}
