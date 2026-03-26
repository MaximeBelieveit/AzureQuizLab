using AzureQuizLab.Options;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;

namespace AzureQuizLab.Pages
{
    public class IndexModel : PageModel
    {
        public bool MaintenanceMode { get; set; }

        public IndexModel(IOptionsMonitor<MaintenanceOptions> maintenanceOptions)
        {
            
            MaintenanceMode = maintenanceOptions.CurrentValue.Enabled;

            maintenanceOptions.OnChange(HandleOptionChange);
        }

        private void HandleOptionChange(MaintenanceOptions options, string? arg2)
        {
            MaintenanceMode = options.Enabled;
        }

        public void OnGet()
        {
        }
    }
}
