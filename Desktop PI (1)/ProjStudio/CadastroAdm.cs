using Guna.UI2.WinForms;
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
    public partial class CadastroAdm: Form
    {
        public CadastroAdm()
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

        private void buttonAluno_Click_1(object sender, EventArgs e)
        {
            // Cria o Form 
            Aluno formAluno = new Aluno();
            formAluno.Show();

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

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                guna2TextBox2.Focus();
            }
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(guna2TextBox1.Text) == false && string.IsNullOrWhiteSpace(guna2TextBox2.Text) == false)
            {
                try
                {
                    ClasseLogin cl = new ClasseLogin(guna2TextBox1.Text, int.Parse(guna2TextBox2.Text));
                    if (cl.Cadastro()) 
                    {
                        MessageBox.Show("Cadastro Ralizado com Sucesso");
                        guna2TextBox1.Text = "";
                        guna2TextBox2.Text = "";
                    }
                    else
                        MessageBox.Show("Erro no Cadastro");
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                }
            }
            else
            {
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            }
        }

        private void CadastroAdm_Load(object sender, EventArgs e)
        {

        }

        private void guna2TextBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                try
                {
                    ClasseLogin cl = new ClasseLogin(guna2TextBox1.Text, int.Parse(guna2TextBox2.Text));
                    if (cl.Cadastro())
                    {
                        MessageBox.Show("Cadastro Ralizado com Sucesso");
                        guna2TextBox1.Text = "";
                        guna2TextBox2.Text = "";
                    }
                    else
                        MessageBox.Show("Erro no Cadastro");
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                }
            }
        }
    }
}
