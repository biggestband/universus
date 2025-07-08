using Godot;

public partial class Peg : Node2D {
    public Sprite2D Sprite;

    public override void _Ready() {
        Sprite = GetNode<Sprite2D>("Sprite2D");
    }
}
