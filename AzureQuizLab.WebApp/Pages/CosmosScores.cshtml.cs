using Azure.Core;
using AzureQuizLab.Options;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;

namespace AzureQuizLab.Pages;

public class CosmosScoresModel : PageModel
{
    private readonly CosmosOptions cosmosOptions;
    private readonly TokenCredential tokenCredential;

    public List<ScoreRow> Scores { get; set; } = new();

    public CosmosScoresModel(IOptions<CosmosOptions> configuration, TokenCredential tokenCredential)
    {
        this.cosmosOptions = configuration.Value;
        this.tokenCredential = tokenCredential;
    }

    public async Task OnGetAsync()
    {
        var client = new CosmosClient(cosmosOptions.ConnectionString, this.tokenCredential);
        var container = client.GetContainer(cosmosOptions.DatabaseName, cosmosOptions.ContainerName);

        var query = new QueryDefinition(
            """
                SELECT
                    c.userId AS UserId,
                    c.score AS Score 
                FROM c 
                ORDER BY c.score DESC
            """);

        using var iterator = container.GetItemQueryIterator<ScoreRow>(query);

        while (iterator.HasMoreResults)
        {
            var response = await iterator.ReadNextAsync();
            Scores.AddRange(response);
        }
    }

}

public record ScoreRow(string UserId, int Score);