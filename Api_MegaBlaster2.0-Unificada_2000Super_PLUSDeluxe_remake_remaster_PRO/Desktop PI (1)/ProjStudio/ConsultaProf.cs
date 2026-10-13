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
    public partial class ConsultaProf: Form
    {
        public ConsultaProf()
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

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            try
            {
                ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text);
                MySqlDataReader r = ce.consulta();
                try
                {
                    if (r.Read())
                    {
                        guna2TextBox2.Text = r["senha"].ToString();
                        guna2TextBox3.Text = r["nome"].ToString();
                        guna2TextBox5.Text = r["sobrenome"].ToString();
                        if (int.Parse(r["ativo"].ToString()) == 1)
                            guna2TextBox4.Text = "Ativo";
                        else
                            guna2TextBox4.Text = "Inativo";
                        if (r["foto"] != DBNull.Value)
                        {
                            byte[] ft = (byte[])r["foto"];
                            using (MemoryStream ms = new MemoryStream(ft))
                            {
                                Image imagem = Image.FromStream(ms);
                                guna2PictureBox1.Image = imagem;
                                guna2PictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
                            }
                        }
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
            catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }

        private void ConsultaProf_Load(object sender, EventArgs e)
        {

        }

        private void maskedTextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            
        }

        private void guna2TextBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                try
                {
                    ClasseEducador ce = new ClasseEducador(guna2TextBox1.Text);
                    MySqlDataReader r = ce.consulta();
                    try
                    {
                        if (r.Read())
                        {
                            guna2TextBox2.Text = r["senha"].ToString();
                            guna2TextBox3.Text = r["nome"].ToString();
                            guna2TextBox5.Text = r["sobrenome"].ToString();
                            if (int.Parse(r["ativo"].ToString()) == 1)
                                guna2TextBox4.Text = "Ativo";
                            else
                                guna2TextBox4.Text = "Inativo";
                            if (r["foto"] != DBNull.Value)
                            {
                                byte[] ft = (byte[])r["foto"];
                                using (MemoryStream ms = new MemoryStream(ft))
                                {
                                    Image imagem = Image.FromStream(ms);
                                    guna2PictureBox1.Image = imagem;
                                    guna2PictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
                                }
                            }
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
    }
}
