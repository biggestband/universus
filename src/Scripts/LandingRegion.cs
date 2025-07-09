using Godot;


[Tool]
public partial class LandingRegion : Area2D {
    [Export]
    float height = 100f, width = 100f;
    
    CollisionShape2D collisionShape;
    Sprite2D sprite;

    public override void _Ready() {
        collisionShape = GetNode<CollisionShape2D>("CollisionShape2D");
        sprite = GetNode<Sprite2D>("Sprite2D");

        Vector2 offset = collisionShape.Position;
        Position += offset;
        collisionShape.Position = Vector2.Zero;
        sprite.Scale = collisionShape.Shape.GetRect().Size;

        BodyEntered += OnBodyEntered;
    }
    
    public override void _ExitTree() {
        BodyEntered -= OnBodyEntered;
    }
    
    void OnBodyEntered(Node2D body) {
        if (body is Ball ball) {
            GD.Print("VAR");
            ball.GravityScale = 0;
            ball.LinearVelocity = Vector2.Zero;
            ball.Freeze = true;
        }
    }

    public override void _Process(double delta) {
        if (Engine.IsEditorHint()) {
            collisionShape ??= GetNode<CollisionShape2D>("CollisionShape2D");
            collisionShape.Position = Vector2.Zero;
        }
    }
    
}