using Godot;
using Utility;

public partial class LandingRegion : Area3D {
    Ball connectedBall;
    Tween textTween;
    State currentState;

    [Export]
    Node3D textMovePosition;

    [Export]
    float snapDistance = 50f, attractionForce = 500f, shakeDistance = 60f;

    [Export]
    CollisionShape3D collisionShape;

    [Export]
    Label3D text;

    public override void _Ready() {
        var offset = collisionShape.Position;
        BodyEntered += OnBodyEntered;
    }

    public void Setup() {
        textTween?.Kill();
        connectedBall = null;
        ResetTextState();
        lerpValue = 0f;
        currentState = State.Idle;
    }
    void ResetTextState() {
        text.Visible = true;
        text.Position = Vector3.Zero;
    }

    public override void _ExitTree() {
        if (Engine.IsEditorHint()) return;
        BodyEntered -= OnBodyEntered;
    }

    Vector3 initialVelocity;
    double lerpValue;

    void OnBodyEntered(Node3D body) {
        if (body is not Ball ball) return;
        if (!ball.Enabled) return;
        initialVelocity = ball.LinearVelocity;
        ball.DisablePhysics();
        connectedBall = ball;
        lerpValue = 0;
        currentState = State.Attracting;
    }

    public override void _PhysicsProcess(double delta) {
        ProcessState(delta);
    }

    void ProcessState(double delta) {
        currentState = currentState switch {
            State.Attracting => ProcessAttracting(delta),
            State.Shake => ProcessShake(delta),
            State.Move => ProcessMove(delta),
            _ => State.Idle,
        };
    }

    State ProcessAttracting(double delta) {
        var ballToSelf = GlobalPosition - connectedBall.GlobalPosition;
        if (ballToSelf.Length() <= snapDistance) {
            lerpValue = 0;
            ResetTextState();
            return State.Shake;
        }

        var force =  ballToSelf.Normalized() * attractionForce;

        lerpValue += delta;
        if (lerpValue >= 1f) {
            lerpValue = 1f;
        }
        var transformedLerpValue = (float)(1 - Mathf.Cos(lerpValue * Mathf.Pi / 2)); // transform lerp value to ease in

        connectedBall.LinearVelocity = new(
            Mathf.Lerp(initialVelocity.X, force.X, transformedLerpValue),
            Mathf.Lerp(initialVelocity.Y, force.Y, transformedLerpValue),
            0
        );

        return State.Attracting;
    }
    State ProcessShake(double delta) {
        if (connectedBall == null) {
            GD.Print("um why is connectedBall null?");
            return State.Shake;
        }
        lerpValue += delta;
        var transformedLerpValue = EaseOutExpo(lerpValue + 0.2);
        connectedBall.GlobalPosition = GlobalPosition;
        connectedBall.LinearVelocity = Vector3.Zero;
        connectedBall.SetInvisible();
        if (lerpValue >= 0.6) {
            connectedBall = null;
            text.Position = Vector3.Zero;
            return State.Move;
        }
        var range = (float)((1 - transformedLerpValue) * shakeDistance);
        var x = (GD.Randf() - 0.5f) * range;
        var y = (GD.Randf() - 0.5f) * range;
        text.Position = new(x, y, 0);
        return State.Shake;
    }
    State ProcessMove(double delta) {
        textTween?.Kill();
        textTween = CreateTween().SetEase(Tween.EaseType.In).SetTrans(Tween.TransitionType.Circ);
        textTween.TweenProperty(text, "global_position", textMovePosition.GlobalPosition.With(x: 0), 0.6f);
        textTween.TweenCallback(Callable.From(() => {
            text.Visible = false;
            PachinkoEventManager.Instance.FinalScore(ScoreManager.Score, 5);
        }));
        return State.Idle;
    }

    double EaseOutExpo(double x) {
        return x >= 1 ? 1 : 1 - Mathf.Pow(2, -10 * x);
    }

    enum State {
        Idle,
        Attracting,
        Shake,
        Move,
    }
}
