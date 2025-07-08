using System;
using Godot;

public partial class Ball : RigidBody2D {
    [Export]
    float randomAngleDegrees;

    [Export]
    float bounceStrength;
    
    Random random;
    float randomAngle;
    public override void _Ready() {
        random = new();
        randomAngle = float.DegreesToRadians(randomAngleDegrees);
    }

    public override void _IntegrateForces(PhysicsDirectBodyState2D state) {
        if (state.GetContactCount() == 0) return;
        var normal = state.GetContactLocalNormal(0);
        var offsetFactor = 2 * random.NextSingle() - 1;
        var bounceAngle = normal.Rotated(randomAngle * offsetFactor);
        state.LinearVelocity = bounceAngle * bounceStrength;
    }

    public override void _Process(double delta) {
        if (Position.Y > 350) {
            GetTree().ReloadCurrentScene();
        }
    }
}