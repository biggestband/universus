using Godot;
public partial class PachinkoCamera : Camera3D {
    Tween tween;
    [Export]
    Vector3 zoomInPosition;
    Vector3 zoomOutPosition;
    public override void _EnterTree() {
        zoomOutPosition = Position;
        Pachinko.Events.OnPachinkoStart += ZoomIn;
    }

    public override void _ExitTree() {
        tween?.Kill();
        Pachinko.Events.OnPachinkoStart -= ZoomIn;
    }

    public void Setup() {
        ZoomOut();
    }

    void ZoomIn() {
        tween?.Kill();
        tween = CreateTween().SetEase(Tween.EaseType.InOut).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position", zoomInPosition, 1f);
    }

    void ZoomOut() {
        tween?.Kill();
        tween = CreateTween().SetEase(Tween.EaseType.InOut).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position", zoomOutPosition, 1f);
    }
}
