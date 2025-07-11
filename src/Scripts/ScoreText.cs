using System;
using Godot;

public partial class ScoreText : RichTextLabel {
    Tween tween;
    Random random;
    Color startColor;
    public override void _Ready() {
        random = new();
        startColor = Modulate;
        PachinkoEventManager.Instance.OnScore += UpdateScoreText;
        PachinkoEventManager.Instance.OnHit += TweenText;
        UpdateScoreText(0,0);
    }
    public override void _ExitTree() {
        PachinkoEventManager.Instance.OnScore -= UpdateScoreText;
        PachinkoEventManager.Instance.OnHit -= TweenText;
    }
    void UpdateScoreText(float oldScore, float newScore) {
        Text = $"[b]{newScore:F1}[/b]";
    }
    void TweenText(int type) {
        var hitType = (HitType)type;
        tween?.Kill();
        tween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Back)
            .SetParallel();
        var fontSize = hitType switch {
            HitType.NewHit => 120,
            _ => 80,
        };
        Color color = hitType switch {
            HitType.NewHit => new(0.5f, 1f, 0.5f),
            _ => new(1,1,1),
        };
        const int POSITION_OFFSET = 20;
        tween.TweenMethod(Callable.From<int>(ChangeFontSize), fontSize, 75, 0.5f);
        tween.TweenProperty(this, "position", Vector2.Zero, 0.75f)
            .From(new Vector2(random.Next(-POSITION_OFFSET, POSITION_OFFSET), random.Next(-POSITION_OFFSET, POSITION_OFFSET)));
        Modulate = color;
        tween.TweenProperty(this, "modulate", startColor,  0.75).SetDelay(0.1f);
    }
    void ChangeFontSize(int value) => AddThemeFontSizeOverride("bold_font_size", value);
}
