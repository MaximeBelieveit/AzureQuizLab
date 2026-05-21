using Azure.Core;
using Azure.Identity;
using AzureQuizLab.Models;
using AzureQuizLab.Options;
using AzureQuizLab.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddMemoryCache();
builder.Services.AddRazorPages();

builder.Services.Configure<MaintenanceOptions>(builder.Configuration.GetSection(MaintenanceOptions.SectionName));
builder.Services.Configure<DataBaseOptions>(builder.Configuration.GetSection(DataBaseOptions.SectionName));
builder.Services.Configure<StorageOptions>(builder.Configuration.GetSection(StorageOptions.SectionName));

builder.Services.AddDbContext<QuizDbContext>((serviceProvider, options) =>
{
    var dbOptions = serviceProvider.GetRequiredService<IOptions<DataBaseOptions>>().Value;

    options.UseSqlServer(dbOptions.ConnectionString,
        sqlOptions => sqlOptions.EnableRetryOnFailure());
});

if (builder.Environment.IsDevelopment())
    builder.Services.AddSingleton<TokenCredential>(new AzureCliCredential());
else
    builder.Services.AddSingleton<TokenCredential>(new ManagedIdentityCredential(new ManagedIdentityCredentialOptions()));

builder.Services.AddScoped<BlobService>();

//builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddAzureWebAppDiagnostics();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();
app.MapRazorPages()
   .WithStaticAssets();

app.Run();
