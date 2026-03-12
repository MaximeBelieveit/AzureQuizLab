using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace AzureQuizLab.Pages
{
    public class IndexModel : PageModel
    {
        private readonly IConfiguration configuration;

        public string MaintenanceMode { get; set; }

        public IndexModel(IConfiguration configuration)
        {
            this.configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            MaintenanceMode = string.Empty;
        }

        public void OnGet()
        {
           MaintenanceMode = this.configuration.GetValue<string>("MaintenanceMode")!;
        }
    }
}
