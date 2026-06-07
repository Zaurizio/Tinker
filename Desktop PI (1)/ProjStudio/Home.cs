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
    public partial class Home: Form
    {
        public Home()
        {
            InitializeComponent();
            ClasseQuestao q = new ClasseQuestao();
            label8.Text = q.Contagem() + " questões inseridas";
            ClasseAluno a = new ClasseAluno();
            label4.Text = a.Contagem() + " alunos cadastrados";
            ClasseEducador e = new ClasseEducador();
            label5.Text = e.Contagem() + " educadores cadastrados";
            ClasseTurma t = new ClasseTurma();
            label10.Text = t.Contagem() + " turmas cadastradas";
        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void buttonAlunoP_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            AlunoProf formAlunoP = new AlunoProf();
            formAlunoP.Show();

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

        private void buttonProf_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Professor formProf = new Professor();
            formProf.Show();

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

        private void buttonAdm_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Administrador formAdm = new Administrador();
            formAdm.Show();

            // Esconde o form
            this.Hide();
        }

        private void buttonHome_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            Home formHome = new Home();
            formHome.Show();

            // Esconde o form
            this.Hide();
        }

        private void panelSidebar_Paint(object sender, PaintEventArgs e)
        {

        }

        private void label8_Click(object sender, EventArgs e)
        {

        }

        private void guna2Button8_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            CadastroAluno formCadastroAluno = new CadastroAluno();
            formCadastroAluno.Show();

            // Esconde o form
            this.Hide();
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            CadastroProf formCadastroProf = new CadastroProf();
            formCadastroProf.Show();

            // Esconde o form
            this.Hide();
        }

        private void guna2Button2_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            CadastroQuest formCadastroQuest = new CadastroQuest();
            formCadastroQuest.Show();

            // Esconde o form
            this.Hide();
        }

        private void Home_Load(object sender, EventArgs e)
        {

        }
    }
}
