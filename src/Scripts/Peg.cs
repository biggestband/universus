using Godot;

public partial class Peg : Node2D {
    Sprite2D sprite;
    Color startColor;
    Tween punchTween;

    bool alreadyHit;

    [Export]
    Color hitColor;

    [Export]
    Vector2 hitScale = Vector2.One * 1.5f;
    
    [Export]
    float hitDuration = 0.25f, 
          hitDelay = 0.05f;
    
    public override void _Ready() {
        sprite = GetNode<Sprite2D>("Sprite2D");
        startColor = sprite.Modulate;
    }

    public void Punch() {
        punchTween?.Kill();
        punchTween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Back)
            .SetParallel();
        
        sprite.Scale = hitScale;
        sprite.Modulate = hitColor;
        
        punchTween.TweenProperty(sprite, "scale", Vector2.One, hitDuration).SetDelay(hitDelay);
        punchTween.TweenProperty(sprite, "modulate", startColor, hitDuration).SetDelay(hitDelay);
        
        ScoreManager.IncreaseScore(alreadyHit ? HitType.ReHit : HitType.NewHit);
        alreadyHit = true;
    }
}
