using Godot;

public partial class Peg : Node2D {
    Sprite2D sprite;
    Tween punchTween;

    public override void _Ready() {
        sprite = GetNode<Sprite2D>("Sprite2D");
    }

    public void Punch() {
        punchTween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Circ);
        punchTween.TweenProperty(sprite, "scale", Vector2.One * 1.6f, 0);
        punchTween.TweenProperty(sprite, "scale", Vector2.One, 0.25f).From(Vector2.One * 1.5f).SetDelay(0.05f);
    }
}
