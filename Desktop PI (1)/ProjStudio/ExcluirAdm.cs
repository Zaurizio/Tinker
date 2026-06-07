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
    public partial class ExcluirAdm: Form
    {
        public ExcluirAdm()
        {
            InitializeComponent();
            ClasseLogin cl = new ClasseLogin();
            MySqlDataReader leitor = cl.buscaTodos();
            while (leitor.Read())
            {
                guna2ComboBox1.Items.Add(leitor["login"].ToString());
            }
            Conexao.con.Close();
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

        private void ExcluirAdm_Load(object sender, EventArgs e)
        {

        }

        private void guna2Button1_Click(object sender, EventArgs e)
        { 
            if(string.IsNullOrWhiteSpace(guna2ComboBox1.Text) == false)
            {
                try
                {
                    ClasseLogin cl = new ClasseLogin(guna2ComboBox1.Text);
                    if (cl.excluir())
                        MessageBox.Show("Exclusão Realizada com Sucesso");
                    else
                        MessageBox.Show("Problema na Exclusão");
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
                guna2ComboBox1.Items.Clear();
                ClasseLogin ci = new ClasseLogin();
                MySqlDataReader leitor = ci.buscaTodos();
                while (leitor.Read())
                {
                    guna2ComboBox1.Items.Add(leitor["login"].ToString());
                }
                Conexao.con.Close();
            }
            else
            {
                MessageBox.Show("Selecione um administrador");
            }
            
        }

        private void guna2ComboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            guna2Button1.Enabled = true;
        }
    }
}
