using System;
using Godot;

public partial class ScoreText : RichTextLabel {
    Tween tween;
    Random random;
    Color startColor;
    public override void _Ready() {
        random = new();
        startColor = Modulate;
        ScoreManager.OnScoreChanged += UpdateScoreText;
        UpdateScoreText(new(0, 0));
    }
    public override void _ExitTree() {
        ScoreManager.OnScoreChanged -= UpdateScoreText;
    }
    void UpdateScoreText(ScoreData data) {
        tween?.Kill();
        tween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Back)
            .SetParallel();
        var fontSize = data.Type switch {
            HitType.NewHit => 120,
            _ => 80,
        };
        const int POSITION_OFFSET = 20;
        Color color = data.Type switch {
            HitType.NewHit => new(0.5f, 1f, 0.5f),
            _ => new(1,1,1),
        };
        tween.TweenMethod(Callable.From<int>(ChangeFontSize), fontSize, 75, 0.5f);
        tween.TweenProperty(this, "position", Vector2.Zero, 0.75f)
            .From(new Vector2(random.Next(-POSITION_OFFSET, POSITION_OFFSET), random.Next(-POSITION_OFFSET, POSITION_OFFSET)));
        Modulate = color;
        tween.TweenProperty(this, "modulate", startColor,  0.75).SetDelay(0.1f);
        Text = $"[b]{data.Score:F2}[/b]";
    }
    void ChangeFontSize(int value) => AddThemeFontSizeOverride("bold_font_size", value);
}
