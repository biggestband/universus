using Godot;

public partial class PachinkoMachine : Node3D {
    Tween tween;
    public override void _EnterTree() {
        Pachinko.Events.OnPachinkoStart += Enter;
    }
    
    public override void _ExitTree() {
        Pachinko.Events.OnPachinkoStart -= Enter;
    }

    public void Setup() {
        tween?.Kill();
        tween = CreateTween().SetEase(Tween.EaseType.InOut).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position:y", -5, 1.5f).From(0);
    }
    
    void Enter() {
        tween?.Kill();
        tween = CreateTween().SetEase(Tween.EaseType.Out).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position:y", 0, 1.5f).From(-5);
    }
}
