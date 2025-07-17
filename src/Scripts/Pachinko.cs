using Godot;
public partial class Pachinko : Node {
    public static Pachinko Instance { get; private set; } 
    public static PachinkoEventManager Events => PachinkoEventManager.Instance;
    
    [Export]
    BallHolder ballHolder;

    [Export]
    PegContainer pegContainer;
    
    [Export]
    LandingRegion landingRegion;
    
    public void Setup() {
        ballHolder.Setup();
        pegContainer.Setup();
        landingRegion.Setup();
        ScoreManager.ResetScore();
    }

    public override void _Ready() {
        Setup();
    }

    public override void _EnterTree() {
        if (Instance != null) {
            QueueFree();
            return;
        }
        Instance = this;
    }
}
