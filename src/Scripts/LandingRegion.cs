using Godot;
using Utility;

[Tool]
public partial class LandingRegion : Area2D {
    float height = 100f, width = 100f;
    bool active;
    Ball connectedBall;

    Tween textTween;

    [Export]
    RichTextLabel text;

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
                if (collisionShape == null || sprite == null) return; // this probably doesnt need to be here but just in case
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

        Vector2 offset = collisionShape.Position;
        Position += offset;
        collisionShape.Position = Vector2.Zero;
        sprite.Scale = collisionShape.Shape.GetRect().Size;

        BodyEntered += OnBodyEntered;

        active = true;
    }

    public void Setup() {
        textTween?.Kill();
        active = true;
        connectedBall = null;
        text.Modulate = Colors.Black;
        text.GetParent<Node2D>().Position = Vector2.Zero;
        lerpValue = 0f;
    }

    public override void _ExitTree() {
        if (Engine.IsEditorHint()) return;
        BodyEntered -= OnBodyEntered;
    }

    Vector2 initialVelocity;
    float lerpValue;

    void OnBodyEntered(Node2D body) {
        if (body is not Ball ball) return;
        initialVelocity = ball.LinearVelocity;
        ball.DisablePhysics();
        connectedBall = ball;
    }

    public override void _PhysicsProcess(double delta) {
        if (connectedBall == null || !active) return;
        lerpValue += (float)delta;
        if (lerpValue >= 1f) {
            lerpValue = 1f;
        }
        var transformedLerpValue = 1 - Mathf.Cos(lerpValue * Mathf.Pi / 2); // transform lerp value to ease in

        var ballToSelf = GlobalPosition - connectedBall.GlobalPosition;
        if (ballToSelf.Length() <= snapDistance) {
            connectedBall.GlobalPosition = GlobalPosition;
            connectedBall.LinearVelocity = Vector2.Zero;
            connectedBall.Hide();
            connectedBall = null;
            textTween = CreateTween().SetEase(Tween.EaseType.In).SetTrans(Tween.TransitionType.Back);
            textTween.TweenProperty(text.GetParent<Node2D>(), "global_position", textMovePosition.GlobalPosition.With(x: 0), 1);
            textTween.TweenCallback(Callable.From(() => {
                text.Modulate = new(1, 1, 1, 0);
                PachinkoEventManager.Instance.FinalScore(ScoreManager.Score, 5);
            }));
            active = false;
            return;
        }

        var attractionForce =  ballToSelf.Normalized() * 500;

        connectedBall.LinearVelocity = new(
            Mathf.Lerp(initialVelocity.X, attractionForce.X, transformedLerpValue),
            Mathf.Lerp(initialVelocity.Y, attractionForce.Y, transformedLerpValue)
        );
    }
}
