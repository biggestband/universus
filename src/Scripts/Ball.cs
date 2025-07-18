using System;
using Godot;
using Utility;

public partial class Ball : RigidBody3D {
    [Export]
    float randomAngleDegrees,
          bounceFactor,
          minSpeed = 40f,
          gravityTiltAngle = 0.1f;

    float gravityTileRad;
    float gravityScale = 0;

    [Export]
    float preferDownwardAngleFactor = 0.2f;

    [Export]
    public bool Enabled;

    [Export]
    MeshInstance3D mesh;

    Random random;
    float randomAngle;

    Tween pegTween;

    public override void _EnterTree() {
        BodyEntered += OnBodyEntered;
        random = new();
        randomAngle = float.DegreesToRadians(randomAngleDegrees);
        gravityTileRad = float.DegreesToRadians(gravityTiltAngle);
        gravityScale = GravityScale;
    }

    public void Setup() {
        pegTween?.Kill();
        Enabled = true;
        mesh.Visible = true;
        Rotation = Vector3.Zero;
        LinearVelocity = Vector3.Zero;
        GravityScale = gravityScale;
        OverridePhysicsPosition(GlobalPosition);
    }

    public void OverridePhysicsPosition(Vector3 position) {
        PhysicsServer3D.Singleton.BodySetState(GetRid(), PhysicsServer3D.BodyState.Transform, position);
    }

    public override void _ExitTree() {
        BodyEntered -= OnBodyEntered;
    }
    void OnBodyEntered(Node body) {
        if (body is not Peg peg) return;
        peg.Punch();
    }

    public override void _IntegrateForces(PhysicsDirectBodyState3D state) {
        if (!Enabled) return;
        LinearVelocity += ConformToGravity(Vector3.Down) * GravityScale * state.Step;
        if (state.GetContactCount() == 0) return;
        var normal = state.GetContactLocalNormal(0);
        var incomingVelocity = state.LinearVelocity
            .With(z:0)
            .Normalized();
        var bounceDirection = incomingVelocity
            .Bounce(normal)
            .With(z: 0);
        var offsetFactor = 2 * random.NextSingle() - 1;
        var bounceAngle = normal
            .Rotated(Vector3.Up, randomAngle * offsetFactor) // add random angle to the bounce direction
            .With(z: 0)
            .Normalized()
            .Slerp(bounceDirection, preferDownwardAngleFactor); // add a downward bias to the bounce direction
        var currentSpeed = state.LinearVelocity.Length();
        currentSpeed = Math.Max(currentSpeed, minSpeed); // this could be combined with the above line but im separating it for clarity
        state.LinearVelocity = ConformToGravity(bounceAngle * bounceFactor * currentSpeed);
    }

    Vector3 ConformToGravity(Vector3 vector) {
        return vector.Rotated(Vector3.Right, gravityTileRad);
    }
    public void DisablePhysics() {
        Enabled = false;
        GravityScale = 0;
    }

    public void SetInvisible() {
        mesh.Visible = false;
    }
}
