namespace AzureQuizLab.Options;

public class DataBaseOptions
{
    public const string SectionName = "DataBase";

    public required string DefaultCatalog { get; set; }

    public required string Server { get; set; }

    public string ConnectionString => $"server=tcp:{Server},1433;Initial Catalog={DefaultCatalog};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Default;"; //ApplicationIntent=ReadOnly
}
