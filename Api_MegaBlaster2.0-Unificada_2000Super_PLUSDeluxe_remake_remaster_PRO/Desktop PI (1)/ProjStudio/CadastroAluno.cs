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
    public partial class CadastroAluno: Form
    {
        public CadastroAluno()
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

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                guna2TextBox2.Focus();
            }
        }

        private void guna2TextBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                guna2TextBox3.Focus();
            }
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

        private void CadastroAluno_Load(object sender, EventArgs e)
        {

        }
        


        private void guna2Button2_Click(object sender, EventArgs e)
        {
            
        }

        private void guna2Button2_Click_1(object sender, EventArgs e)
        {
         
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text) || String.IsNullOrEmpty(guna2TextBox3.Text) || String.IsNullOrEmpty(guna2TextBox4.Text) || String.IsNullOrEmpty(maskedTextBox1.Text))
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            else
            {
                if (!guna2TextBox1.Text.Contains("@") || guna2TextBox3.Text.Any(char.IsDigit) || guna2TextBox4.Text.Any(char.IsDigit)) 
                {
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                }
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
                                    ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, 1);
                                    if (ca.Cadastro())
                                    {
                                        MessageBox.Show("Cadastro Realizado com Sucesso");
                                        guna2TextBox1.Text = "";
                                        guna2TextBox2.Text = "";
                                        guna2TextBox3.Text = ""; 
                                        guna2TextBox4.Text = "";
                                        maskedTextBox1.Text = string.Empty;
                                    }
                                    else
                                        MessageBox.Show("Errro no Cadastro");
                                }
                                catch (Exception ex)
                                {
                                    Console.WriteLine(ex.ToString());
                                    MessageBox.Show("Preencha Todos os Campos Corretamente");
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
                                    ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, 1);
                                    if (ca.Cadastro())
                                    {
                                        MessageBox.Show("Cadastro Realizado com Sucesso");
                                        guna2TextBox1.Text = "";
                                        guna2TextBox2.Text = "";
                                        guna2TextBox3.Text = "";
                                        guna2TextBox4.Text = "";
                                        maskedTextBox1.Text = string.Empty;
                                    }
                                    else
                                        MessageBox.Show("Errro no Cadastro");
                                }
                                catch (Exception ex)
                                {
                                    Console.WriteLine(ex.ToString());
                                    MessageBox.Show("Preencha Todos os Campos Corretamente");
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
                                    ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, 1);
                                    if (ca.Cadastro())
                                    {
                                        MessageBox.Show("Cadastro Realizado com Sucesso");
                                        guna2TextBox1.Text = "";
                                        guna2TextBox2.Text = "";
                                        guna2TextBox3.Text = "";
                                        guna2TextBox4.Text = "";
                                        maskedTextBox1.Text = string.Empty;
                                    }
                                    else
                                        MessageBox.Show("Errro no Cadastro");
                                }
                                catch (Exception ex)
                                {
                                    Console.WriteLine(ex.ToString());
                                    MessageBox.Show("Preencha Todos os Campos Corretamente");
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
        }

        private void maskedTextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text) || String.IsNullOrEmpty(guna2TextBox3.Text) || String.IsNullOrEmpty(guna2TextBox4.Text) || String.IsNullOrEmpty(maskedTextBox1.Text))
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                else
                {
                    if (!guna2TextBox1.Text.Contains("@") || guna2TextBox3.Text.Any(char.IsDigit) || guna2TextBox4.Text.Any(char.IsDigit))
                    {
                        MessageBox.Show("Preencha Todos os Campos Corretamente");
                    }
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
                                        ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, 1);
                                        if (ca.Cadastro())
                                        {
                                            MessageBox.Show("Cadastro Realizado com Sucesso");
                                            guna2TextBox1.Text = "";
                                            guna2TextBox2.Text = "";
                                            guna2TextBox3.Text = "";
                                            guna2TextBox4.Text = "";
                                            maskedTextBox1.Text = string.Empty;
                                        }
                                        else
                                            MessageBox.Show("Errro no Cadastro");
                                    }
                                    catch (Exception ex)
                                    {
                                        Console.WriteLine(ex.ToString());
                                        MessageBox.Show("Preencha Todos os Campos Corretamente");
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
                                        ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, 1);
                                        if (ca.Cadastro())
                                        {
                                            MessageBox.Show("Cadastro Realizado com Sucesso");
                                            guna2TextBox1.Text = "";
                                            guna2TextBox2.Text = "";
                                            guna2TextBox3.Text = "";
                                            guna2TextBox4.Text = "";
                                            maskedTextBox1.Text = string.Empty;
                                        }
                                        else
                                            MessageBox.Show("Errro no Cadastro");
                                    }
                                    catch (Exception ex)
                                    {
                                        Console.WriteLine(ex.ToString());
                                        MessageBox.Show("Preencha Todos os Campos Corretamente");
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
                                        ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, nascF, 1);
                                        if (ca.Cadastro())
                                        {
                                            MessageBox.Show("Cadastro Realizado com Sucesso");
                                            guna2TextBox1.Text = "";
                                            guna2TextBox2.Text = "";
                                            guna2TextBox3.Text = "";
                                            guna2TextBox4.Text = "";
                                            maskedTextBox1.Text = string.Empty;
                                        }
                                        else
                                            MessageBox.Show("Errro no Cadastro");
                                    }
                                    catch (Exception ex)
                                    {
                                        Console.WriteLine(ex.ToString());
                                        MessageBox.Show("Preencha Todos os Campos Corretamente");
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
            }
        }
    }
}
