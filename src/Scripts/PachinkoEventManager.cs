using Godot;

public partial class PachinkoEventManager : Node {
    public static PachinkoEventManager Instance { get; private set; }

    Variant[] variantArr1;
    Variant[] variantArr2;

    [Signal]
    public delegate void OnHitEventHandler(int hitType);

    [Signal]
    public delegate void OnScoreEventHandler(float oldScore, float newScore);

    [Signal]
    public delegate void OnHighScoreEventHandler(float score);

    [Signal]
    public delegate void OnBallDropEventHandler();
    
    [Signal]
    public delegate void OnPachinkoStartEventHandler();

    [Signal]
    public delegate void OnFinalScoreEventHandler(float baseScore, float multiplier);
    

    public void Hit(HitType hitType) {
        variantArr1 ??= new Variant[1];
        variantArr1[0] = (int)hitType;
        EmitSignal(SignalName.OnHit, variantArr1);
    }

    public void Score(float oldScore, float newScore) {
        variantArr2 ??= new Variant[2];
        variantArr2[0] = oldScore;
        variantArr2[1] = newScore;
        EmitSignal(SignalName.OnScore, variantArr2);
    }

    public void BallDrop() => EmitSignal(SignalName.OnBallDrop);
    public void PachinkoStart() => EmitSignal(SignalName.OnPachinkoStart);

    public void FinalScore(float baseScore, float multiplier) {
        variantArr2 ??= new Variant[2];
        variantArr2[0] = baseScore;
        variantArr2[1] = multiplier;
        EmitSignal(SignalName.OnFinalScore, variantArr2);
    }

    public void AddScore(float score) {
        variantArr1 ??= new Variant[1];
        variantArr1[0] = score;
        EmitSignal(SignalName.OnHighScore, variantArr1);
    }
    
    public void HighScore(float score) {
        variantArr1 ??= new Variant[1];
        variantArr1[0] = score;
        EmitSignal(SignalName.OnHighScore, variantArr1);
    }

    public override void _EnterTree() {
        if (Instance != null) {
            QueueFree();
            return;
        }
        Instance = this;
    }
}
