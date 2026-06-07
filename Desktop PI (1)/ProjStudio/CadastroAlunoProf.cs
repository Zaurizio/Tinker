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
    public partial class CadastroAlunoProf: Form
    {
        public CadastroAlunoProf()
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

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text))
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            else
            {
                int cod = 0;
                try
                {
                    cod = int.Parse(guna2TextBox2.Text);
                    try
                    {
                        bool ctrlA = false;
                        bool ctrlB = false;
                        ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text);
                        MySqlDataReader r = ca.ConsultaAtivo();
                        if (r.Read())
                            ctrlA = true;
                        r.Close();
                        Conexao.con.Close();

                        ClasseTurma ct = new ClasseTurma(cod);
                        ctrlB = ct.ExisteAtivo();
                        if (ctrlA && ctrlB)
                        {
                            ClasseAlunoTurma cat = new ClasseAlunoTurma(int.Parse(guna2TextBox2.Text), guna2TextBox1.Text);
                            if (cat.Existe())
                            {
                                if (cat.Reativa())
                                {
                                    MessageBox.Show("Cadastro Realizado com Sucesso");
                                    guna2TextBox1.Text = "";
                                    guna2TextBox2.Text = "";
                                }
                                else
                                    MessageBox.Show("Erro no cadastro");
                            }
                            else
                            {
                                if (cat.Cadastro())
                                {
                                    MessageBox.Show("Cadastro Realizado com Sucesso");
                                    guna2TextBox1.Text = "";
                                    guna2TextBox2.Text = "";
                                }
                                else
                                    MessageBox.Show("Erro no cadastro");
                            }
                        }
                        else if (ctrlA && ctrlB == false)
                        {
                            MessageBox.Show("Esta Turma não existe ou está inativa");
                        }
                        else if (ctrlA == false && ctrlB)
                        {
                            MessageBox.Show("Este Aluno não existe ou está inativo");
                        }
                        else
                            MessageBox.Show("Esse Aluno ou Turma não existe");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                    MessageBox.Show("Digite Apenas Números no Campo Código");
                }

            }
        }

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if(e.KeyChar == 13)
            {
                guna2TextBox2.Focus();
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
                    int cod = 0;
                    try
                    {
                        cod = int.Parse(guna2TextBox2.Text);
                        try
                        {
                            bool ctrlA = false;
                            bool ctrlB = false;
                            ClasseAluno ca = new ClasseAluno(guna2TextBox1.Text);
                            MySqlDataReader r = ca.ConsultaAtivo();
                            if (r.Read())
                                ctrlA = true;
                            r.Close();
                            Conexao.con.Close();

                            ClasseTurma ct = new ClasseTurma(cod);
                            ctrlB = ct.ExisteAtivo();
                            if (ctrlA && ctrlB)
                            {
                                ClasseAlunoTurma cat = new ClasseAlunoTurma(int.Parse(guna2TextBox2.Text), guna2TextBox1.Text);
                                if (cat.Existe())
                                {
                                    if (cat.Reativa())
                                    {
                                        MessageBox.Show("Cadastro Realizado com Sucesso");
                                        guna2TextBox1.Text = "";
                                        guna2TextBox2.Text = "";
                                    }
                                    else
                                        MessageBox.Show("Erro no cadastro");
                                }
                                else
                                {
                                    if (cat.Cadastro())
                                    {
                                        MessageBox.Show("Cadastro Realizado com Sucesso");
                                        guna2TextBox1.Text = "";
                                        guna2TextBox2.Text = "";
                                    }
                                    else
                                        MessageBox.Show("Erro no cadastro");
                                }
                            }
                            else if (ctrlA && ctrlB == false)
                            {
                                MessageBox.Show("Esta Turma não existe ou está inativa");
                            }
                            else if (ctrlA == false && ctrlB)
                            {
                                MessageBox.Show("Este Aluno não existe ou está inativo");
                            }
                            else
                                MessageBox.Show("Esse Aluno ou Turma não existe");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine(ex.ToString());
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                        MessageBox.Show("Digite Apenas Números no Campo Código");
                    }

                }
            }
        }

        private void CadastroAlunoProf_Load(object sender, EventArgs e)
        {

        }
    }
}
