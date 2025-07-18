using Godot;

public partial class PachinkoMachine : Node3D {
	[Export]
	float inPosY, outPosY;
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
		tween.TweenProperty(this, "position:y", outPosY, 1.5f);
	}
	
	void Enter() {
		tween?.Kill();
		tween = CreateTween().SetEase(Tween.EaseType.Out).SetTrans(Tween.TransitionType.Quad);
		tween.TweenProperty(this, "position:y", inPosY, 1.5f);
	}
}
