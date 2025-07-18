using Godot;
public partial class Pachinko : Node {
	public static Pachinko Instance { get; private set; } 
	public static PachinkoEventManager Events => PachinkoEventManager.Instance;

	State state;
	
	[Export]
	BallHolder ballHolder;

	[Export]
	PegManager pegContainer;
	
	[Export]
	Node landingRegionContainer;

	[Export]
	PachinkoMachine machine;
	
	public void Setup() {
		state = State.Wait;
		machine?.Setup();
		ballHolder?.Setup();
		pegContainer?.Setup();
		foreach (var node in landingRegionContainer.GetChildren()) {
			var landingRegion = node as LandingRegion;
			landingRegion?.Setup();
		}
		ScoreManager.ResetScore();
	}
	
	public override void _Process(double delta) {
		if (Input.IsActionJustPressed("BiggestButton")) {
			if (state == State.Wait) {
				state = State.Play;
				Events.PachinkoStart();
			} else if (state == State.Play) {
				Events.BallDrop();
			}
		}
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
		Events.OnFinalScore += FinalScore;
	}
	public override void _ExitTree() {
		Events.OnFinalScore -= FinalScore;
	}
	void FinalScore(float baseScore, float multiplier) {
		machine?.Setup();
	}


	enum State {
		Wait,
		Play,
	}
}
