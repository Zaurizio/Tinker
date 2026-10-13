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
    public partial class Login: Form
    {
        public Login()
        {
            InitializeComponent();
            if (Conexao.getConexao("143.106.241.4", "cl204179", "cl204179", "cl*27042009"))
                Console.WriteLine("Conectado");
            else
                Console.WriteLine("Erro de Conexão");

            if (Conexao.getConexao1("143.106.241.4", "cl204179", "cl204179", "cl*27042009"))
                Console.WriteLine("Conectado 2");
            else
                Console.WriteLine("Erro de Conexão 2");
        }

        private void Login_Load(object sender, EventArgs e)
        {
            
        }

        private void guna2Panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void timerSidebar_Tick(object sender, EventArgs e)
        {
           
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            
        }

        private void PrepararBotoesFechada()
        {
            
        }

        private void guna2Button8_Click(object sender, EventArgs e)
        {
            try
            {
                ClasseLogin cl = new ClasseLogin(guna2TextBox1.Text, int.Parse(guna2TextBox2.Text));
                if (cl.Entrada())
                {
                    // Cria o Form principal
                    Home formHome = new Home();
                    formHome.Show();

                    // Esconde o form de login
                    this.Hide();
                }
                else
                {
                    MessageBox.Show("Erro ao Logar. Tente Novamente.");
                }
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Preencha Todos os Campos Corretamente");
            }

        }

        private void guna2TextBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                guna2TextBox2.Focus();
            }

        }

        private void guna2TextBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void guna2TextBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                try
                {
                    ClasseLogin cl = new ClasseLogin(guna2TextBox1.Text, int.Parse(guna2TextBox2.Text));
                    if (cl.Entrada())
                    {
                        // Cria o Form principal
                        Home formHome = new Home();
                        formHome.Show();

                        // Esconde o form de login
                        this.Hide();
                    }
                    else
                    {
                        MessageBox.Show("Erro ao Logar. Tente Novamente.");
                    }
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
