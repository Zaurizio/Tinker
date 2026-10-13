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
    public partial class CadastroQuestDis : Form
    {
        public CadastroQuestDis()
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
        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void CadastroQuestDis_Load(object sender, EventArgs e)
        {

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
        private void guna2Button1_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrWhiteSpace(guna2TextBox1.Text) || String.IsNullOrWhiteSpace(guna2TextBox2.Text) || String.IsNullOrWhiteSpace(guna2TextBox3.Text) || String.IsNullOrWhiteSpace(guna2TextBox4.Text) || String.IsNullOrWhiteSpace(guna2TextBox5.Text) ||  String.IsNullOrEmpty(maskedTextBox1.Text) || String.IsNullOrWhiteSpace(guna2ComboBox1.Text))
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
                        byte[] foto = null;
                        if (guna2PictureBox1.Image != null)
                        {
                            foto = ConverterFotoParaByteArray();
                        }
                        ClasseQuestao cq = new ClasseQuestao(guna2TextBox1.Text, int.Parse(maskedTextBox1.Text), guna2ComboBox1.Text, guna2TextBox2.Text, guna2TextBox3.Text, guna2TextBox4.Text, guna2TextBox5.Text, foto, 1);
                        if (cq.Cadastro())
                        {
                            MessageBox.Show("Cadastro Realizado com Sucesso");
                            guna2TextBox1.Text = "";
                            guna2TextBox2.Text = "";
                            guna2TextBox3.Text = "";
                            guna2TextBox4.Text = "";
                            guna2TextBox5.Text = "";
                            guna2ComboBox1.Text = null;
                            guna2PictureBox1.Image = null;
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
            }
        }

        private void guna2Button2_Click(object sender, EventArgs e)
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
    }
}
