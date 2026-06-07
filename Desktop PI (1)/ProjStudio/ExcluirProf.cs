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
    public partial class ExcluirProf: Form
    {
        public ExcluirProf()
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

        private void panelSidebar_Paint(object sender, PaintEventArgs e)
        {

        }

        private void buttonAlunoP_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            AlunoProf formAlunoP = new AlunoProf();
            formAlunoP.Show();

            // Esconde o form
            this.Hide();
        }

        private void maskedTextBox1_Leave(object sender, EventArgs e)
        {
                

        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            try
            {
                ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text);
                if (ce.exclui())
                {
                    MessageBox.Show("Exclusão Realizada com Sucesso");
                    guna2TextBox1.Text = "";
                    guna2TextBox2.Text = "";
                    guna2Button1.Enabled = false;
                }
                else
                    MessageBox.Show("Problema na Exclusão");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }

        private void maskedTextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            
        }

        private void ExcluirProf_Load(object sender, EventArgs e)
        {

        }

        private void guna2TextBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                try
                {
                    ClasseEducador ce = new ClasseEducador(guna2TextBox2.Text);
                    MySqlDataReader r = ce.consulta();
                    if (r.Read())
                    {
                        if (int.Parse(r["ativo"].ToString()) == 1)
                        {
                            guna2TextBox1.Text = r["nome"].ToString();
                            guna2Button1.Enabled = true;
                        }
                        else
                            MessageBox.Show("Digite um Email Ativo no Sistema");
                    }
                    else
                        MessageBox.Show("Digite o Email Corretamente");
                    Conexao.con.Close();
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
        }

        private void guna2TextBox2_Leave(object sender, EventArgs e)
        {
            try
            {
                ClasseEducador ce = new ClasseEducador(guna2TextBox2.Text);
                MySqlDataReader r = ce.consulta();
                if (r.Read())
                {
                    if (int.Parse(r["ativo"].ToString()) == 1)
                    {
                        guna2TextBox1.Text = r["nome"].ToString();
                        guna2Button1.Enabled = true;
                    }
                    else
                        MessageBox.Show("Digite um Email Ativo no Sistema");
                }
                else
                    MessageBox.Show("Digite o Email Corretamente");
                Conexao.con.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }

        private void guna2TextBox2_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
