#### Theory

###### Microservices

> [!WARNING]  
> Example callout

### Code

#### Infrastructure - Context

```cs
public class InnolabContext : DbContext  
{  
    public InnolabContext(DbContextOptions opt) : base(opt) {    }  
    public DbSet<InnolabUser> Users => Set<InnolabUser>();  
    public DbSet<Reservation> Reservations => Set<Reservation>();  
    protected override void OnModelCreating(ModelBuilder modelBuilder)  
    {        modelBuilder.Entity<InnolabUser>().HasIndex(u => u.Email).IsUnique();  
    }}
```

#### Infrastructure - Repository

```cs
public class Repository<TEntity, TKey> where TEntity : class, IEntity<TKey> where TKey : struct 
{ 
    protected readonly InnoLabContext _db; 
    public IQueryable<TEntity> Set => _db.Set<TEntity>(); 
    public Repository(InnoLabContext db) => _db = db; 
    public virtual (bool success, string message) InsertOne(TEntity entity) 
    { 
        _db.Set<TEntity>().Add(entity); 
        // _db.Set<TEntity>().Remove(entity);  <- DELETE 
        // _db.Set<TEntity>().Update(entity);  <- UPDATE 
        try 
        { 
            _db.SaveChanges(); 
        } 
        catch (DbUpdateException e) 
        { 
            return (false, e.InnerException?.Message ?? e.Message); 
        } 
        return (true, string.Empty);    
    } 

    public (bool success, string message, TEntity? entity) GetById(TKey id) 
    { 
        try 
        { 
            var entity = _db.Set<TEntity>().Local.FirstOrDefault(e => e.Id.Equals(id)) ?? _db.Set<TEntity>().Find(id); 
            return entity == null ? (true, $"No entity with ID {id} found.", null) : (true, string.Empty, entity); 
        } 
        catch (DbUpdateException e) 
        { 
            return (false, e.InnerException?.Message ?? e.Message, null); 
        }     
    } 
}
```

#### Domain Model

```cs
public interface IEntity<TKey> where TKey : struct 
{ TKey Id { get; } } 
```

```cs
[Index(nameof(Email), IsUnique = true)] // unique constraint on email
public class MyClass: IEntity<int> {  // inherit from IEntity
    #pragma warning disable CS8618
    protected DefaultConstructor(){}

    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.None)]
    public int AutoIncKeyWithoutNamingConvention { get; private set; }
    [Required]  // not null
    [StringLength(25)] // max string length
    public string Email { get; set; }
}
```

Fluent api equivalent + **enum conversion**:
```cs
modelBuilder.Entity<InnolabUser>().HasIndex(u => u.Email).IsUnique();  
modelBuilder.Entity<Reservation>().Property(r => r.State).HasConversion<string>();
modelBuilder.Entity<Reservation>().Property(r => r.State).HasConversion<string>().HasMaxLength(25);
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

Value objects:
```cs
public record Address(
    string Street, 
    string City, 
    string ZipCode
);
---
modelBuilder.Entity<Order>().OwnsOne(p => p.ShippingAddress);
modelBuilder.Entity<User>().OwnsMany(p => p.Address)
```

Setting up a **1:1** relation between class `MyClassA` and `MyClassB`.
```cs
modelBuilder
    .Entity<MyClassA>()
    .HasOne<MyClassB>(a => a.B)
    .WithOne(b => b.A)
    .HasForeignKey<MyClassB>(b => b.AId);
```

Setting up an **1:N** relation between class `MyClassA` and `MyClassB`.
```cs
modelBuilder
    .Entity<MyClassA>()
    .HasMany<MyClassB>(a => a.Bs)
    .WithOne(b => b.A)
    .HasForeignKey(b => b.AId);
```

Setting up an **M:N** relation between class `MyClassA` and `MyClassB` with `MyClassC` in the middle.
```cs
modelBuilder
    .Entity<MyClassA>()
    .HasMany<MyClassB>(a => a.Bs)
    .WithMany(b => b.As)
    .UsingEntity<MyClassC>();
```



Discriminator column for **inheritance**:
```cs
modelBuilder.Entity<Human>()
    .HasDiscriminator<string>("type")
    .HasValue<Teacher>("teacher")
    .HasValue<Student>("student");
```

Table per type:
```cs
modelBuilder.Entity<Blog>().ToTable("Human");
modelBuilder.Entity<RssBlog>().ToTable("Teacher");
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

#### NSUbstitute

```cs
[Fact]
public async Task GetIngredients_ReturnsOkResultWithCorrectList()
{
    // Mock the IRepository
    var repository = Substitute.For<IRepository<Ingredient>>();
    repository.GetAllAsync().Returns(new List<Ingredient> { new Ingredient("Vegan")
    });
    var controller = new MyController(repository);
    // Convert the Result to a usable object
    var result1 = await controller.GetIngredients();
    var result2 = (OkObjectResult) result1;
    // Assert the correct statements
    Assert.Equal(result2.StatusCode, 200);
    Assert.Equal(1, result2.Value as List<Ingredient>).Count());
}
```


#### Linq
when doing queries that access other class properties do this to include all of their information:
```cs
_dbc.DividerBoxes.Include(a => a.DividerBoxLocations).ThenInclude(a =>
a.StorageRoomNavigation);
```

SingleOrDefault: Returns a single specific element or default if none or more than one element exists.
```cs
var student = context.Students.SingleOrDefault(s => s.StudentId == 1);
```
Count: Returns the total number of elements in a sequence.
```cs
int count = context.Students.Count();
```
Any: Checks if any elements in a sequence satisfy a condition.
```cs
bool exists = context.Students.Any(s => s.Grade > 3);
```

Sum: Computes the sum of a sequence of numeric values.
```cs
int totalScore = context.Students.Sum(s => s.Score);
```
Max and Min: Finds the maximum or minimum value in a sequence.
```cs
var maxScore = context.Students.Max(s => s.Score);
var minScore = context.Students.Min(s => s.Score);
```
ToList: Converts an IQueryable or IEnumerable to a List.
```cs
var studentList = context.Students.ToList();
```
First / FirstOrDefault: Returns the first element of a sequence, or a default value if no element is found.
```cs
var student = context.Students.FirstOrDefault(s => s.Name == "John");
```
OrderBy / OrderByDescending: Sorts the elements of a sequence in ascending or descending order.
```cs
var sortedStudents = context.Students.OrderBy(s => s.Name);
```
GroupBy: Groups the elements of a sequence.
```cs
var groupedByStandard = context.Students.GroupBy(s => s.StandardId);
```


#### Web API

Basic structure of a controller:
```cs
    // Necessary attributes
    [Route("api/[controller]")]
    [ApiController]
    public class MyController : ControllerBase
    {
    // Inject the necessary dependencies
    private readonly MyContext _context;
    public MyController(MyContext context)
    {
        _context = context;
    }
    // Define a route
    [HttpGet("{id:int}")]
    public IActionResult GetSingle(int id)
    {
        return Ok(null!);
    }
}
```
