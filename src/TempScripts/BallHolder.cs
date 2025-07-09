using Godot;

public partial class BallHolder : Node2D {
    Tween tween;
    Ball ball;

    [Export]
    float range = 100;
    
    [Export]
    float tweenTime = 1;

    public override void _Ready() {
        ball = GetNode<Ball>("Ball");
        ball.Freeze = true;
        tween = CreateTween().SetLoops().SetEase(Tween.EaseType.InOut).SetTrans(Tween.TransitionType.Quad);
        tween.TweenProperty(this, "position:x", range, tweenTime).From(-range);
        tween.TweenProperty(this, "position:x", -range, tweenTime).From(range);
    }

    public override void _Process(double delta) {
        if (Input.IsActionPressed("BiggestButton")) {
            tween.Kill();
            ball.Freeze = false;
        }
    }
}
