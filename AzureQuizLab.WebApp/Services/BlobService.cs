using Azure.Core;
using Azure.Storage.Blobs;
using AzureQuizLab.Options;
using Microsoft.Extensions.Options;

namespace AzureQuizLab.Services;

public class BlobService
{
    private readonly BlobContainerClient _container;

	public BlobService(IOptions<StorageOptions> options, TokenCredential tokenCredential)
	{
        var serviceClient = new BlobServiceClient(
            new Uri($"https://{options.Value.BlobName}.blob.core.windows.net/"),
            tokenCredential);

        _container = serviceClient.GetBlobContainerClient(options.Value.ContainerName);
        _container.CreateIfNotExists();
    }

    public async Task<string> UploadAsync(string content)
    {
        var name = $"result-{Guid.NewGuid()}.json";
        var blob = _container.GetBlobClient(name);

        await blob.UploadAsync(BinaryData.FromString(content));

        return name;
    }

    public async Task<List<string>> ListAsync()
    {
        var result = new List<string>();

        await foreach (var blob in _container.GetBlobsAsync())
        {
            result.Add(blob.Name);
        }

        return result;
    }

    public async Task<string> DownloadAsync(string name)
    {
        var blob = _container.GetBlobClient(name);

        var content = await blob.DownloadContentAsync();

        return content.Value.Content.ToString();
    }
}
