using System;
using Godot;

public partial class Ball : RigidBody2D {

    [Export]
    float randomAngleDegrees;

    [Export]
    float bounceFactor;

    [Export]
    float minSpeed = 40f;

    [Export]
    float preferDownwardAngleFactor = 0.2f;

    Random random;
    float randomAngle;

    Tween pegTween;
    Sprite2D sprite;

    public bool Enabled;

    public override void _Ready() {
        sprite = GetNode<Sprite2D>("Sprite2D");
        BodyEntered += OnBodyEntered;
        random = new();
        randomAngle = float.DegreesToRadians(randomAngleDegrees);
    }

    public void Setup() {
        pegTween?.Kill();
        Enabled = true;
        GravityScale = 0.3f;
        sprite.Visible = true;
        Position = Vector2.Zero;
        Rotation = 0f;
        LinearVelocity = Vector2.Zero;
        PhysicsServer2D.Singleton.BodySetState(GetRid(), PhysicsServer2D.BodyState.Transform, GlobalPosition);
    }
    
    public override void _ExitTree() {
        BodyEntered -= OnBodyEntered;
    }
    void OnBodyEntered(Node body) {
        if (body.GetParent() is not Peg peg) return;
        peg.Punch();
    }

    public override void _IntegrateForces(PhysicsDirectBodyState2D state) {
        if (!Enabled || state.GetContactCount() == 0) return;
        var normal = state.GetContactLocalNormal(0);
        var incomingVelocity = state.LinearVelocity.Normalized();
        var bounceDirection = incomingVelocity.Bounce(normal);
        var offsetFactor = 2 * random.NextSingle() - 1;
        var bounceAngle = normal
            .Rotated(randomAngle * offsetFactor) // add random angle to the bounce direction
            .Slerp(bounceDirection, preferDownwardAngleFactor); // add a downward bias to the bounce direction
        var currentSpeed = state.LinearVelocity.Length();
        currentSpeed = Math.Max(currentSpeed, minSpeed); // this could be combined with the above line but im separating it for clarity
        state.LinearVelocity = bounceAngle * bounceFactor * currentSpeed;
    }
    public void DisablePhysics() {
        Enabled = false;
        GravityScale = 0;
    }

    public void Hide() {
        sprite.Visible = false;
    }
}
