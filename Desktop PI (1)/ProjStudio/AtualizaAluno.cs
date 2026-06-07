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
    public partial class AtualizaAluno: Form
    {
        public AtualizaAluno()
        {
            InitializeComponent();
        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void AtualizaAluno_Load(object sender, EventArgs e)
        {

        }
        
        private void guna2Button1_Click(object sender, EventArgs e)
        {
            try
            {
                ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text);
                MySqlDataReader r = ca.Consulta();
                if (r.Read())
                {
                    guna2TextBox2.Text = r["senha"].ToString();
                    guna2TextBox3.Text = r["nome"].ToString();
                    guna2TextBox4.Text = r["sobrenome"].ToString();
                    maskedTextBox1.Text = r["nascimento"].ToString();
                    if (int.Parse(r["ativo"].ToString()) == 1)
                        guna2ComboBox1.Text = "Ativo";
                    else
                        guna2ComboBox1.Text = "Inativo";
                }
                else
                    MessageBox.Show("Digite o Email Corretamente");
                Conexao.con.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            guna2TextBox2.Focus();
        }

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if(e.KeyChar == 13)
            {
                try
                {
                    ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text);
                    MySqlDataReader r = ca.Consulta();
                    if (r.Read())
                    {
                        guna2TextBox2.Text = r["senha"].ToString();
                        guna2TextBox3.Text = r["nome"].ToString();
                        guna2TextBox4.Text = r["sobrenome"].ToString();
                        maskedTextBox1.Text = r["nascimento"].ToString();
                        if (int.Parse(r["ativo"].ToString()) == 1)
                            guna2ComboBox1.Text = "Ativo";
                        else
                            guna2ComboBox1.Text = "Inativo";
                    }
                    else
                        MessageBox.Show("Digite o Email Corretamente");
                    Conexao.con.Close();
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
                guna2TextBox2.Focus();
            }
        }

        private void guna2TextBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if(e.KeyChar == 13)
            {
                guna2TextBox3.Focus();
            }
        }

        private void guna2TextBox3_TextChanged(object sender, EventArgs e)
        {

        }

        private void guna2TextBox3_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                guna2TextBox4.Focus();
            }
        }

        private void guna2TextBox4_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                maskedTextBox1.Focus();
            }
        }

        private void guna2Button2_Click(object sender, EventArgs e)
        {
            Conexao.con.Close();
            int at = 0;
            if (guna2ComboBox1.Text == "Ativo")
                at = 1;
            if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text) || String.IsNullOrEmpty(guna2TextBox3.Text) || String.IsNullOrEmpty(guna2TextBox4.Text) || String.IsNullOrEmpty(maskedTextBox1.Text) || guna2TextBox3.Text.Any(char.IsDigit) || guna2TextBox4.Text.Any(char.IsDigit) || String.IsNullOrWhiteSpace(maskedTextBox1.Text))
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            else
            {
                string[] nasc = maskedTextBox1.Text.Split('/');
                string nascF = nasc[2] + nasc[1] + nasc[0];
                if ((int.Parse(nasc[2]) <= 2015 && int.Parse(nasc[2]) >= 1950) && (int.Parse(nasc[1]) <= 12 && int.Parse(nasc[1]) >= 1))
                {
                    if (int.Parse(nasc[1]) == 4 || int.Parse(nasc[1]) == 6 || int.Parse(nasc[1]) == 9 || int.Parse(nasc[1]) == 11)
                    {
                        if (int.Parse(nasc[0]) <= 30 && int.Parse(nasc[0]) >= 1)
                        {
                            try
                            {
                                ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, at);
                                if (ca.Atualiza()) 
                                {
                                    MessageBox.Show("Atualização Realizada com Sucesso");
                                    guna2TextBox1.Text = "";
                                    guna2TextBox2.Text = "";
                                    guna2TextBox3.Text = "";
                                    guna2TextBox4.Text = "";
                                    maskedTextBox1.Text = "";
                                    guna2ComboBox1.Text = null;
                                }
                                else
                                    MessageBox.Show("Erro na Atualização");
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine(ex.ToString());
                            }
                        }
                        else
                        {
                            MessageBox.Show("Digite um dia compatível com o mês");
                        }
                    }
                    else if (int.Parse(nasc[1]) == 2)
                    {
                        if (int.Parse(nasc[0]) <= 28 && int.Parse(nasc[0]) >= 1)
                        {
                            try
                            {
                                ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, at);
                                if (ca.Atualiza())
                                    MessageBox.Show("Atualização Realizada com Sucesso");
                                else
                                    MessageBox.Show("Erro na Atualização");
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine(ex.ToString());
                            }
                        }
                        else
                        {
                            MessageBox.Show("Digite um dia compatível com o mês");
                        }
                    }
                    else
                    {
                        if (int.Parse(nasc[0]) <= 31 && int.Parse(nasc[0]) >= 1)
                        {
                            try
                            {
                                ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, at);
                                if (ca.Atualiza())
                                    MessageBox.Show("Atualização Realizada com Sucesso");
                                else
                                    MessageBox.Show("Erro na Atualização");
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine(ex.ToString());
                            }
                        }
                        else
                        {
                            MessageBox.Show("Digite um dia compatível com o mês");
                        }
                    }
                }
                else
                {
                    MessageBox.Show("Preencha Todos os Campos Corretamente (erro no ano ou mês)");
                }
            }
        }
        private void guna2Button3_Click(object sender, EventArgs e)
        {
        }

        private void guna2TextBox5_KeyPress(object sender, KeyPressEventArgs e)
        {
            guna2ComboBox1.Focus();
            guna2ComboBox1.DroppedDown = true;
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
