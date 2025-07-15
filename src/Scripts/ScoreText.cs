using System;
using Godot;

public partial class ScoreText : RichTextLabel {
    const int DEFAULT_FONT_SIZE = 75;
    Tween tween;
    Random random;
    Color startColor;
    int currentValue;

    public override void _Ready() {
        random = new();
        startColor = Modulate;
        PachinkoEventManager.Instance.OnScore += UpdateScoreText;
        PachinkoEventManager.Instance.OnFinalScore += FinalScore;
        PachinkoEventManager.Instance.OnHit += TweenText;
        UpdateScoreText(0, 0);
        currentValue = DEFAULT_FONT_SIZE;
    }
    public override void _ExitTree() {
        PachinkoEventManager.Instance.OnScore -= UpdateScoreText;
        PachinkoEventManager.Instance.OnFinalScore -= FinalScore;
        PachinkoEventManager.Instance.OnHit -= TweenText;
    }
    void FinalScore(float baseScore, float multiplier) {
        var finalScore = baseScore * multiplier;
        Text = $"[b]{finalScore:F0}[/b]";
        tween?.Kill();
        currentValue = 150;
        TweenText((int)HitType.NewHit, 0.3f);
    }
    void UpdateScoreText(float oldScore, float newScore) {
        Text = $"[b]{newScore:F2}[/b]";
    }
    void TweenText(int type) => TweenText(type, 0.1f);
    void TweenText(int type, float delay) {
        var hitType = (HitType)type;
        tween?.Kill();
        tween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Back)
            .SetParallel();
        var fontSize = hitType switch {
            HitType.NewHit => 10,
            _ => 5,
        };
        Color color = hitType switch {
            HitType.NewHit => new(0.5f, 1f, 0.5f),
            _ => new(1, 1, 1),
        };
        const int POSITION_OFFSET = 20;
        currentValue += fontSize;
        ChangeFontSize(currentValue);
        tween.TweenMethod(Callable.From<int>(ChangeFontSize), currentValue, DEFAULT_FONT_SIZE, 0.5f).SetDelay(delay);
        tween.TweenProperty(this, "position", Vector2.Zero, 0.75f)
            .From(new Vector2(random.Next(-POSITION_OFFSET, POSITION_OFFSET), random.Next(-POSITION_OFFSET, POSITION_OFFSET)));
        Modulate = color;
        tween.TweenProperty(this, "modulate", startColor,  0.75).SetDelay(0.1f);
        tween.TweenCallback(Callable.From(() => { currentValue = DEFAULT_FONT_SIZE; })).SetDelay(0.5f);
    }
    void ChangeFontSize(int value) {
        AddThemeFontSizeOverride("bold_font_size", value);
    }
}
