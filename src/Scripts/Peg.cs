using Godot;

public partial class Peg : Node2D {
    Sprite2D sprite;
    Color startColor;
    Tween punchTween;

    bool alreadyHit;


    [Export]
    Color hitColor;

    [Export]
    float hitScale = 1.5f,
          unHitScale = 1.2f,
          reHitScale = 1.0f;

    [Export]
    float hitDuration = 0.25f,
          hitDelay = 0.05f;

    public override void _Ready() {
        sprite = GetNode<Sprite2D>("Sprite2D");
        startColor = sprite.Modulate;
        sprite.Scale = Vector2.One * unHitScale;
    }

    public void Punch() {
        punchTween?.Kill();
        punchTween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Back)
            .SetParallel();

        var targetScale = Vector2.One * reHitScale;
        sprite.Scale = hitScale * targetScale;
        sprite.Modulate = hitColor;

        punchTween.TweenProperty(sprite, "scale", targetScale, hitDuration).SetDelay(hitDelay);
        punchTween.TweenProperty(sprite, "modulate", startColor, hitDuration).SetDelay(hitDelay);

        PachinkoEventManager.Instance.Hit(alreadyHit ? HitType.ReHit : HitType.NewHit);
        alreadyHit = true;
    }
}
