using Godot;

public partial class BallHolder : Node2D {
    Tween tween;
    Ball[] balls;

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
            ball.Freeze = true;
        }
        tween = CreateTween().SetLoops().SetEase(Tween.EaseType.InOut).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position:x", range, tweenTime).From(-range);
        tween.TweenProperty(this, "position:x", -range, tweenTime).From(range);
    }

    public override void _Process(double delta) {
        if (Input.IsActionPressed("BiggestButton")) {
            tween.Kill();
            foreach (var ball in balls) {
                ball.Freeze = false;
            }
        }
    }
}
