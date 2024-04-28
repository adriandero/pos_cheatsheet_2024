#### Theory

###### Microservices

> [!WARNING]  
> Example callout

### Code

#### Infrastructure - Context

```cs
public class InnolabContext : DbContext  
{  
    public InnolabContext(DbContextOptions opt) : base(opt)  
    {    }  
    public DbSet<InnolabUser> Users => Set<InnolabUser>();  
    public DbSet<Reservation> Reservations => Set<Reservation>();  
    protected override void OnModelCreating(ModelBuilder modelBuilder)  
    {        modelBuilder.Entity<InnolabUser>().HasIndex(u => u.Email).IsUnique();  
    }}
```

#### Domain Model

```cs
#pragma warning disable CS8618
protected DefaultConstructor(){}

[Key]
[DatabaseGenerated(DatabaseGeneratedOption.None)]
public int AutoIncKeyWithoutNamingConvention { get; private set; }
[Required]  // not null
[StringLength(25)] // max string length
public string Email { get; set; }
```

Unique constraint + enum conversion:
```cs
modelBuilder.Entity<InnolabUser>().HasIndex(u => u.Email).IsUnique();  
modelBuilder.Entity<Reservation>().Property(r => r.State).HasConversion<string>();
```

Custom enum conversion:
```cs
modelBuilder.Entity<Reservation>().Property(r => r.State)
    .HasConversion(
        // Convert enum to uppercase string when saving to the database
        v => v.ToString().ToUpper(),  
        // Convert from string to enum when reading from the database
        v => (ReservationStates)Enum.Parse(typeof(ReservationStates), v) 
);
```

Tests:
```cs
public class DatabaseTest : IDisposable  
{  
    private readonly SqliteConnection _connection;  
    protected readonly InnolabContext _db;  
  
    public DatabaseTest()  
    {        _connection = new SqliteConnection("DataSource=:memory:");  
        _connection.Open();  
        var options = new DbContextOptionsBuilder<InnolabContext>()  
            .UseSqlite(_connection)  
            .UseLazyLoadingProxies()  
            .LogTo(message => Debug.WriteLine(message), Microsoft.Extensions.Logging.LogLevel.Information)  
            .EnableSensitiveDataLogging()  
            .Options;  
        _db = new InnolabContext(options);  
        _db.Database.EnsureCreated();  
    }  
    public void Dispose()  
    {   
	    db.Dispose();  
        _connection.Dispose();  
    }}
```