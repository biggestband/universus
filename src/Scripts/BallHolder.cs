using Godot;

public partial class BallHolder : Node2D {
    Tween tween;
    Ball[] balls;
    bool active;

    [Export]
    float range = 100;

    [Export]
    float tweenTime = 1;

    public override void _Ready() {
        var children = GetChildren();
        balls = new Ball[children.Count];
        for (int i = 0; i < children.Count; i++) {
            if (children[i] is not Ball ball) continue;
            balls[i] = ball;
        }
    }

    public override void _Process(double delta) {
        if (!active || !Input.IsActionPressed("BiggestButton")) return;
        tween.Kill();
        foreach (var ball in balls) {
            ball.Freeze = false;
        }
        active = false;
    }
    public void Setup() {
        tween?.Kill();
        tween = CreateTween().SetLoops().SetEase(Tween.EaseType.InOut).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position:x", range, tweenTime).From(-range);
        tween.TweenProperty(this, "position:x", -range, tweenTime).From(range);
        active = true;

        foreach (Ball ball in balls) {
            ball.Freeze = true;
            ball.Setup();
        }
    }
}
