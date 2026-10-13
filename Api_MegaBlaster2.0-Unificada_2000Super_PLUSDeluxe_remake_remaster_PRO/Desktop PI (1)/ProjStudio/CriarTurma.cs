using Guna.UI2.WinForms;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ProjStudio
{
    public partial class CriarTurma: Form
    {
        public CriarTurma()
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
                    ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text);
                    MySqlDataReader r = ce.consulta();
                    if (r != null)
                    {
                        r.Read();
                        if (int.Parse(r["ativo"].ToString()) == 1)
                        {
                            try
                            {
                                Conexao.con.Close();
                                ClasseTurma ct = new ClasseTurma(guna2TextBox2.Text, guna2TextBox1.Text);
                                if (ct.Existe())
                                {
                                    MessageBox.Show("Já Existe uma Turma com Esse Nome e Email");
                                }
                                else
                                {
                                    try
                                    {
                                        ClasseTurma ct2 = new ClasseTurma(guna2TextBox2.Text, guna2TextBox1.Text, 1);
                                        if (ct2.Cadastro())
                                        {
                                            MessageBox.Show("Turma Criada com Sucesso");
                                            guna2TextBox1.Text = "";
                                            guna2TextBox2.Text = "";
                                        }
                                        else
                                            MessageBox.Show("Erro ao Criar a Turma");
                                    }
                                    catch (Exception ex)
                                    {
                                        Console.WriteLine(ex.ToString());
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine(ex.ToString());
                                MessageBox.Show("Preencha Todos os Campos Corretamente");
                            }
                        }
                        else
                            MessageBox.Show("O Email Pertence a um Professor Inativo");
                    }
                    else
                    {
                        MessageBox.Show("Escolha um Email de Professor Existente");
                        
                    }
                        
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                }
                Conexao.con.Close();
            }
        }

        private void guna2TextBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if(e.KeyChar == 13)
            {
                if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text))
                    MessageBox.Show("Preencha Todos os Campos Corretamente ");
                else
                {
                    try
                    {
                        Conexao.con.Close();
                        ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text);
                        MySqlDataReader r = ce.consulta();
                        if (r != null && r.Read())
                        {
                            if (int.Parse(r["ativo"].ToString()) == 1)
                            {
                                try
                                {
                                    Conexao.con.Close();
                                    ClasseTurma ct = new ClasseTurma(guna2TextBox2.Text, guna2TextBox1.Text);
                                    if (ct.Existe())
                                    {
                                        MessageBox.Show("Já Existe uma Turma com Esse Nome e Email");
                                    }
                                    else
                                    {
                                        try
                                        {
                                            ClasseTurma ct2 = new ClasseTurma(guna2TextBox2.Text, guna2TextBox1.Text, 1);
                                            if (ct2.Cadastro()) 
                                            { 
                                                MessageBox.Show("Turma Criada com Sucesso");
                                                guna2TextBox1.Text = "";
                                                guna2TextBox2.Text = "";
                                            }
                                            else
                                                MessageBox.Show("Erro ao Criar a Turma");
                                        }
                                        catch (Exception ex)
                                        {
                                            Console.WriteLine(ex.ToString());
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    Console.WriteLine(ex.ToString());
                                    MessageBox.Show("Preencha Todos os Campos Corretamente ");
                                }
                            }
                            else
                                MessageBox.Show("O Email Pertence a um Professor Inativo");
                        }
                        else
                        {
                            MessageBox.Show("Escolha um Email de Professor Existente");

                        }

                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                        MessageBox.Show("Preencha Todos os Campos Corretamente ");
                    }
                    Conexao.con.Close();
                }
            
            }
        }

        private void CriarTurma_Load(object sender, EventArgs e)
        {

        }

        private void buttonHome_Click_1(object sender, EventArgs e)
        {
            // Cria o Form 
            Home formHome = new Home();
            formHome.Show();

            // Esconde o form
            this.Hide();

        }

        private void buttonAdm_Click_1(object sender, EventArgs e)
        {

            // Cria o Form 
            Administrador formAdm = new Administrador();
            formAdm.Show();

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

        private void buttonProf_Click_1(object sender, EventArgs e)
        {
            // Cria o Form 
            Professor formProf = new Professor();
            formProf.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonQuest_Click_1(object sender, EventArgs e)
        {
            // Cria o Form 
            Questoes formQuest = new Questoes();
            formQuest.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonAlunoP_Click_1(object sender, EventArgs e)
        {
            // Cria o Form 
            AlunoProf formAlunoP = new AlunoProf();
            formAlunoP.Show();

            // Esconde o form
            this.Hide();
        }
    }
}
