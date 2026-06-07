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
    public partial class AlunoProf: Form
    {
        public AlunoProf()
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

        private void guna2Button8_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            CadastroAlunoProf formCadAlunoP = new CadastroAlunoProf();
            formCadAlunoP.Show();

            // Esconde o form
            this.Hide();
        }

        private void guna2Button2_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            ExcluirAlunoProf formExAlunoP = new ExcluirAlunoProf();
            formExAlunoP.Show();

            // Esconde o form
            this.Hide();
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            AtualizaAlunoProf formAtAlunoP = new AtualizaAlunoProf();
            formAtAlunoP.Show();

            // Esconde o form
            this.Hide();
        }

        private void AlunoProf_Load(object sender, EventArgs e)
        {

        }

        private void guna2Button1_Click_1(object sender, EventArgs e)
        {
            // Cria o Form 
            CriarTurma criarTurma = new CriarTurma();
            criarTurma.Show();

            // Esconde o form
            this.Hide();
        }

        private void guna2Button4_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            ExcluirTurma excluirTurma = new ExcluirTurma();
            excluirTurma.Show();

            // Esconde o form
            this.Hide();
        }

        private void guna2Button3_Click(object sender, EventArgs e)
        {
            // Cria o Form 
            ConsultaTurma consultaTurma = new ConsultaTurma();
            consultaTurma.Show();

            // Esconde o form
            this.Hide();
        }
    }
}
