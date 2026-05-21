namespace AzureQuizLab.Options;

public class StorageOptions
{
    public const string SectionName = "Storage";

    public required string BlobName { get; set; }
    public required string ContainerName { get; set; }
}
