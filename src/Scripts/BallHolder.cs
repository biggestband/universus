using Godot;

public partial class BallHolder : Node3D {
    Tween tween;
    [Export]
    Ball ball;
    bool active;

    [Export]
    float range = 100;

    [Export]
    float tweenTime = 1;

    public override void _Ready() {
        // below is legacy code for multiple balls

        // var children = ballContainer.GetChildren();
        // balls = new Ball[children.Count];
        // for (int i = 0; i < children.Count; i++) {
        //     if (children[i] is not Ball ball) continue;
        //     balls[i] = ball;
        // }
    }

    public override void _EnterTree() {
        Pachinko.Events.OnBallDrop += DropBall;
    }
    
    public override void _ExitTree() {
        Pachinko.Events.OnBallDrop -= DropBall;
        tween?.Kill();
    }

    public override void _Process(double delta) {
        if (!active) return;
        ball.GlobalPosition = GlobalPosition;
    }
    void DropBall() {
        tween.Kill();
        ball.Freeze = false;
        active = false;
    }
    public void Setup() {
        tween?.Kill();
        tween = CreateTween().SetLoops().SetEase(Tween.EaseType.InOut).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position:x", range, tweenTime).From(-range);
        tween.TweenProperty(this, "position:x", -range, tweenTime).From(range);
        active = true;

        ball.Freeze = true;
        ball.Setup();
    }
}
