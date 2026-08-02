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
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Window;

namespace ProjStudio
{
    public partial class AtualizaProf: Form
    {
        public AtualizaProf()
        {
            InitializeComponent();
            guna2ComboBox1.DropDownStyle = ComboBoxStyle.DropDownList;
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
            try
            {
                ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text);
                MySqlDataReader r = ce.consulta();
                if (r.Read())
                {
                    guna2TextBox2.Text = r["senha"].ToString();
                    guna2TextBox3.Text = r["nome"].ToString();
                    guna2TextBox4.Text = r["sobrenome"].ToString();
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

        private void AtualizaProf_Load(object sender, EventArgs e)
        {

        }

        private void guna2Button2_Click(object sender, EventArgs e)
        {
            Conexao.con.Close();
            int at = 0;
            if (guna2ComboBox1.Text == "Ativo")
                at = 1;
            if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text) || String.IsNullOrEmpty(guna2TextBox3.Text) || String.IsNullOrEmpty(guna2TextBox4.Text) || guna2TextBox3.Text.Any(char.IsDigit) || guna2TextBox4.Text.Any(char.IsDigit))
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            else 
            {
                try
                {
                    ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, at);
                    if (ce.atualiza())
                    {
                        MessageBox.Show("Atualização Realizada com Sucesso");
                        guna2TextBox1.Text = "";
                        guna2TextBox2.Text = "";
                        guna2TextBox3.Text = "";
                        guna2TextBox4.Text = "";
                        guna2ComboBox1.Text = null;
                    }
                    else
                        MessageBox.Show("Erro na Atualização");
                }
                catch(Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
        }

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
                if (e.KeyChar == 13)
                {
                    try
                    {
                        ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text);
                        MySqlDataReader r = ce.consulta();
                        if (r.Read())
                        {
                            guna2TextBox2.Text = r["senha"].ToString();
                            guna2TextBox3.Text = r["nome"].ToString();
                            guna2TextBox4.Text = r["sobrenome"].ToString();
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

        private void guna2ComboBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            Conexao.con.Close();
            if (e.KeyChar == 13)
            {
                int at = 0;
                if (guna2ComboBox1.Text == "Ativo")
                    at = 1;
                if (String.IsNullOrEmpty(guna2TextBox1.Text) || String.IsNullOrEmpty(guna2TextBox2.Text) || String.IsNullOrEmpty(guna2TextBox3.Text) || String.IsNullOrEmpty(guna2TextBox4.Text) || guna2TextBox3.Text.Any(char.IsDigit) || guna2TextBox4.Text.Any(char.IsDigit))
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                else
                {
                    try
                    {
                        ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, at);
                        if (ce.atualiza())
                        {
                            MessageBox.Show("Atualização Realizada com Sucesso");
                            guna2TextBox1.Text = "";
                            guna2TextBox2.Text = "";
                            guna2TextBox3.Text = "";
                            guna2TextBox4.Text = "";
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
            }
        }

        private void guna2TextBox4_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                guna2ComboBox1.Focus();
                guna2ComboBox1.DroppedDown = true;
            }
        }

        private void guna2Button3_Click(object sender, EventArgs e)
        {
        }
        

        private void maskedTextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            
        }

        private void guna2TextBox3_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
