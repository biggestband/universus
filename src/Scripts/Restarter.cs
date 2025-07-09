using Godot;

public partial class Restarter : Node {
    public override void _Process(double delta) {
        if (Input.IsKeyPressed(Key.R)) GetTree().ReloadCurrentScene();
    }
}
