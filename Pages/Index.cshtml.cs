using AzureQuizLab.Options;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;

namespace AzureQuizLab.Pages
{
    public class IndexModel : PageModel
    {
        public bool MaintenanceMode { get; set; }

        public IndexModel(IOptions<MaintenanceOptions> maintenanceOptions)
        {
            MaintenanceMode = maintenanceOptions.Value.Enabled;
        }

        public void OnGet()
        {
        }
    }
}
