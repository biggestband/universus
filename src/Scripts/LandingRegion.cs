using Godot;
using Utility;

[Tool]
public partial class LandingRegion : Area2D {
    float height = 100f, width = 100f;
    Ball connectedBall;
    Tween textTween;
    State currentState;

    [Export]
    RichTextLabel text;
    Node2D textParent;

    [Export]
    Node2D textMovePosition;

    [Export]
    float Height {
        get => height;
        set {
            height = value;
            if (Engine.IsEditorHint() && HasNode("CollisionShape2D") && HasNode("Sprite2D")) {
                collisionShape ??= GetNode<CollisionShape2D>("CollisionShape2D");
                sprite ??= GetNode<Sprite2D>("Sprite2D");
                if (collisionShape == null || sprite == null) return; // this probably doesn't need to be here but just in case
                var rect = new RectangleShape2D();
                rect.Size = new(width, height);
                collisionShape.Shape = rect;
                sprite.Scale = rect.GetRect().Size;
            }
        }
    }

    [Export]
    float Width {
        get => width;
        set {
            width = value;
            if (Engine.IsEditorHint() && HasNode("CollisionShape2D") && HasNode("Sprite2D")) {
                collisionShape ??= GetNode<CollisionShape2D>("CollisionShape2D");
                sprite ??= GetNode<Sprite2D>("Sprite2D");
                if (collisionShape == null || sprite == null) return;
                var rect = new RectangleShape2D();
                rect.Size = new(width, height);
                collisionShape.Shape = rect;
                sprite.Scale = rect.GetRect().Size;
            }
        }
    }

    [Export]
    float snapDistance = 50f;

    CollisionShape2D collisionShape;
    Sprite2D sprite;

    public override void _Ready() {
        if (Engine.IsEditorHint()) return;
        collisionShape = GetNode<CollisionShape2D>("CollisionShape2D");
        sprite = GetNode<Sprite2D>("Sprite2D");
        textParent = text.GetParent<Node2D>();

        Vector2 offset = collisionShape.Position;
        Position += offset;
        collisionShape.Position = Vector2.Zero;
        sprite.Scale = collisionShape.Shape.GetRect().Size;

        BodyEntered += OnBodyEntered;
    }

    public void Setup() {
        textTween?.Kill();
        connectedBall = null;
        text.Modulate = Colors.Black;
        textParent.Position = Vector2.Zero;
        lerpValue = 0f;
        currentState = State.Idle;
    }

    public override void _ExitTree() {
        if (Engine.IsEditorHint()) return;
        BodyEntered -= OnBodyEntered;
    }

    Vector2 initialVelocity;
    double lerpValue;

    void OnBodyEntered(Node2D body) {
        if (body is not Ball ball) return;
        initialVelocity = ball.LinearVelocity;
        ball.DisablePhysics();
        connectedBall = ball;
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
            return State.Shake;
        }
        
        var attractionForce =  ballToSelf.Normalized() * 500;
        
        lerpValue += delta;
        if (lerpValue >= 1f) {
            lerpValue = 1f;
        }
        var transformedLerpValue = (float)(1 - Mathf.Cos(lerpValue * Mathf.Pi / 2)); // transform lerp value to ease in

        connectedBall.LinearVelocity = new(
            Mathf.Lerp(initialVelocity.X, attractionForce.X, transformedLerpValue),
            Mathf.Lerp(initialVelocity.Y, attractionForce.Y, transformedLerpValue)
        );
        
        return State.Attracting;
    }
    State ProcessShake(double delta) {
        lerpValue += delta;
        connectedBall.GlobalPosition = GlobalPosition;
        connectedBall.LinearVelocity = Vector2.Zero;
        connectedBall.Hide();
        if (lerpValue >= 1) {
            connectedBall = null;
            textParent.Position = Vector2.Zero;
            return State.Move;
        }
        var range = (float)((1 - lerpValue) * 25);
        var x = (GD.Randf() - 0.5f) * range;
        var y = (GD.Randf() - 0.5f) * range;
        textParent.Position = new(x, y);
        return State.Shake;
    }
    State ProcessMove(double delta) {
        textTween?.Kill();
        textTween = CreateTween().SetEase(Tween.EaseType.In).SetTrans(Tween.TransitionType.Circ);
        textTween.TweenProperty(textParent, "global_position", textMovePosition.GlobalPosition.With(x: 0), 0.6f);
        textTween.TweenCallback(Callable.From(() => {
            text.Modulate = new(1, 1, 1, 0);
            PachinkoEventManager.Instance.FinalScore(ScoreManager.Score, 5);
        }));
        return State.Idle;
    }

    enum State {
        Idle,
        Attracting,
        Shake,
        Move,
    }
}
