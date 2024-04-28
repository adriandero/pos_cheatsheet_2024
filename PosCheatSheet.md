####  Theory    
  
  
###### Microservices   
> [!WARNING]  
> This is gemini created based on all the notes from teams we have on microservices so if something is missing or wrong please do change !!!


### Code

###### Infrastructure - Context

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

