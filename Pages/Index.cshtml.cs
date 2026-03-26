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
        private readonly ILogger logger;

        public bool MaintenanceMode { get; set; }

        public int QuizCount { get; set; }
        public int QuestionCount { get; set; }

        public IndexModel(
            QuizDbContext context,
            ILogger<IndexModel> logger,
            IOptionsMonitor<MaintenanceOptions> maintenanceOptions)
        {
            this.context = context ?? throw new ArgumentNullException(nameof(context));
            this.logger = logger ?? throw new ArgumentNullException(nameof(logger));

            MaintenanceMode = maintenanceOptions.CurrentValue.Enabled;

            maintenanceOptions.OnChange(HandleOptionChange);
        }

        private void HandleOptionChange(MaintenanceOptions options, string? arg2)
        {
            MaintenanceMode = options.Enabled;
        }

        public void OnGet()
        {
            this.logger.LogInformation("Chargement de la page d'accueil à {Time}", DateTime.UtcNow);

            QuizCount = this.context.Quizzes.Count();
            QuestionCount = this.context.Questions.Count();

            this.logger.LogInformation("Nombre de quiz : {QuizCount}", QuizCount);
            this.logger.LogInformation("Nombre de questions : {QuestionCount}", QuestionCount);
        }
    }
}
