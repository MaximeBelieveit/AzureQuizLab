namespace AzureQuizLab.Options;

public class CosmosOptions
{
    public const string SectionName = "Cosmos";
    public required string ConnectionString { get; set; }
    public required string DatabaseName { get; set; }
    public required string ContainerName { get; set; }
}
