using Godot;

[Tool]
public partial class testtool : Sprite2D {
    public override void _Process(double delta) {
        Rotation += Mathf.Pi * (float)delta;
    }
}
