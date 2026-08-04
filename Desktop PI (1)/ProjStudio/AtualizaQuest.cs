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
    public partial class AtualizaQuest: Form
    {
        public AtualizaQuest()
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

        private void guna2PictureBox1_Click(object sender, EventArgs e)
        {

        }

        private void label11_Click(object sender, EventArgs e)
        {

        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrWhiteSpace(guna2TextBox10.Text))
            {
                MessageBox.Show("Preencha o campo ID antes");
            }
            else
            {
                try
                {
                    ClasseQuestao ce = new ClasseQuestao(int.Parse(guna2TextBox10.Text));
                    MySqlDataReader r = ce.Consulta();
                    try
                    {
                        if (r.Read())
                        {
                            guna2TextBox1.Text = r["vestibular"].ToString();
                            maskedTextBox1.Text = r["ano"].ToString();
                            guna2ComboBox1.Text = r["fase"].ToString();
                            guna2ComboBox2.Text = r["resposta"].ToString();
                            guna2TextBox2.Text = r["disciplina"].ToString();
                            guna2TextBox3.Text = r["conteudo"].ToString();
                            guna2TextBox4.Text = r["enunciado"].ToString();
                            guna2TextBox5.Text = r["alternativaA"].ToString();
                            guna2TextBox6.Text = r["alternativaB"].ToString();
                            guna2TextBox7.Text = r["alternativaC"].ToString();
                            guna2TextBox8.Text = r["alternativaD"].ToString();
                            guna2TextBox9.Text = r["alternativaE"].ToString();
                            if (int.Parse(r["ativo"].ToString()) == 1)
                                guna2ComboBox3.Text = "Ativo";
                            else
                                guna2ComboBox3.Text = "Inativo";
                            if (r["imagem"] != DBNull.Value)
                            {
                                byte[] ft = (byte[])r["imagem"];
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

        private byte[] ConverterFotoParaByteArray()
        {
            using (var stream = new System.IO.MemoryStream())
            {
                guna2PictureBox1.Image.Save(stream, System.Drawing.Imaging.ImageFormat.Jpeg);
                stream.Seek(0, System.IO.SeekOrigin.Begin);
                byte[] bArray = new byte[stream.Length];
                stream.Read(bArray, 0, System.Convert.ToInt32(stream.Length));
                return bArray;
            }
        }
        private void guna2Button2_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrWhiteSpace(guna2TextBox1.Text) || String.IsNullOrWhiteSpace(guna2TextBox2.Text) || String.IsNullOrWhiteSpace(guna2TextBox3.Text) || String.IsNullOrWhiteSpace(guna2TextBox4.Text) || String.IsNullOrWhiteSpace(guna2TextBox5.Text) || String.IsNullOrWhiteSpace(guna2TextBox6.Text) || String.IsNullOrWhiteSpace(guna2TextBox7.Text) || String.IsNullOrWhiteSpace(guna2TextBox8.Text) || String.IsNullOrWhiteSpace(guna2TextBox9.Text) || String.IsNullOrEmpty(maskedTextBox1.Text) || String.IsNullOrWhiteSpace(guna2ComboBox1.Text) || String.IsNullOrWhiteSpace(guna2ComboBox2.Text) || String.IsNullOrWhiteSpace(guna2ComboBox3.Text))
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            else
            {
                if (guna2TextBox1.Text.Any(char.IsDigit) || guna2TextBox2.Text.Any(char.IsDigit) || !(1930 < int.Parse(maskedTextBox1.Text) && 2027 > int.Parse(maskedTextBox1.Text)))
                {
                    MessageBox.Show("Preencha Todos os Campos Corretamente");
                }
                else
                {
                    try
                    {
                        int ativo = 0;
                        if (guna2ComboBox3.Text == "Ativo")
                        {
                            ativo = 1;
                        }
                        byte[] foto = null;
                        if (guna2PictureBox1.Image != null)
                        {
                            foto = ConverterFotoParaByteArray();
                        }
                        ClasseQuestao cq = new ClasseQuestao(int.Parse(guna2TextBox10.Text), guna2TextBox1.Text, int.Parse(maskedTextBox1.Text), guna2ComboBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, guna2TextBox5.Text, guna2TextBox6.Text, guna2TextBox7.Text, guna2TextBox8.Text, guna2TextBox9.Text, guna2ComboBox2.Text, foto, ativo);
                        if (cq.Atualiza())
                        {
                            MessageBox.Show("Atualização Realizada com Sucesso");
                            guna2TextBox1.Text = "";
                            guna2TextBox2.Text = "";
                            guna2TextBox3.Text = "";
                            guna2TextBox4.Text = "";
                            guna2TextBox5.Text = "";
                            guna2TextBox6.Text = "";
                            guna2TextBox7.Text = "";
                            guna2TextBox8.Text = "";
                            guna2TextBox9.Text = "";
                            guna2TextBox10.Text = "";
                            guna2ComboBox1.Text = null;
                            guna2ComboBox2.Text = null;
                            guna2ComboBox3.Text = null;
                            guna2PictureBox1.Image = null;
                            maskedTextBox1.Text = string.Empty;
                        }
                        else
                            MessageBox.Show("Errro na Atualização");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                        MessageBox.Show("Preencha Todos os Campos Corretamente");
                    }
                }
            }
        }

        private void guna2Button3_Click(object sender, EventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog();

            dialog.Title = "Abrir Foto";
            dialog.Filter = "JPG (*.jpg)|*.jpg" + "|All files (*.*)|*.*";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    guna2PictureBox1.Image = new Bitmap(dialog.OpenFile());
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Não foi possível carregar a foto: " + ex.Message);
                }
            }
            dialog.Dispose();
        }

        private void guna2TextBox3_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
