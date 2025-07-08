using System;
using Godot;

public partial class Ball : RigidBody2D {

    [Export]
    float randomAngleDegrees;

    [Export]
    float bounceFactor;

    [Export]
    float minSpeed = 40f;

    Random random;
    float randomAngle;

    Tween pegTween;
    public override void _Ready() {
        random = new();
        randomAngle = float.DegreesToRadians(randomAngleDegrees);
        BodyEntered += OnBodyEntered;
    }

    public override void _ExitTree() {
        BodyEntered -= OnBodyEntered;
    }
    void OnBodyEntered(Node body) {
        if (!(body.GetParent() is Peg peg)) return;
        pegTween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Circ);
        pegTween.TweenProperty(peg.Sprite, "scale", Vector2.One * 1.6f, 0);
        pegTween.TweenProperty(peg.Sprite, "scale", Vector2.One, 0.25f).From(Vector2.One * 1.5f).SetDelay(0.05f);
    }

    public override void _IntegrateForces(PhysicsDirectBodyState2D state) {
        if (state.GetContactCount() == 0) return;
        var normal = state.GetContactLocalNormal(0);
        var offsetFactor = 2 * random.NextSingle() - 1;
        var bounceAngle = normal.Rotated(randomAngle * offsetFactor);
        var currentSpeed = state.LinearVelocity.Length();
        currentSpeed = Math.Max(currentSpeed, minSpeed);
        state.LinearVelocity = bounceAngle * bounceFactor * currentSpeed;

    }

    public override void _Process(double delta) {
        if (Position.Y > 1000) {
            GetTree().ReloadCurrentScene();
        }
    }
}
