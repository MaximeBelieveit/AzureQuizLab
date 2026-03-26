using AzureQuizLab.Models;
using AzureQuizLab.Options;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace AzureQuizLab.Pages
{
    public class IndexModel : PageModel
    {
        private readonly QuizDbContext context;

        public bool MaintenanceMode { get; set; }

        public int QuizCount { get; set; }
        public int QuestionCount { get; set; }

        public IndexModel(QuizDbContext context, IOptionsMonitor<MaintenanceOptions> maintenanceOptions)
        {
            MaintenanceMode = maintenanceOptions.CurrentValue.Enabled;

            maintenanceOptions.OnChange(HandleOptionChange);
            this.context = context;
        }

        private void HandleOptionChange(MaintenanceOptions options, string? arg2)
        {
            MaintenanceMode = options.Enabled;
        }

        public void OnGet()
        {
            QuizCount = this.context.Quizzes.Count();
            QuestionCount = this.context.Questions.Count();
        }
    }
}
