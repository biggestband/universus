using System;
using Godot;

public partial class ScoreManager : Node {
    [Export]
    float newHitScore = 0.2f, reHitScore = 0.1f;
    public static float Score { get; private set; }
    public static float HighScore { get; private set; }

    public static float NewHitScore, ReHitScore;

    public override void _Ready() {
        Score = 0;
        NewHitScore = newHitScore;
        ReHitScore = reHitScore;

        PachinkoEventManager.Instance.OnHit += IncreaseScore;
    }

    public static void IncreaseScore(int type) {
        var amount = (HitType)type switch {
            HitType.NewHit => NewHitScore,
            HitType.ReHit =>  ReHitScore,
            _ => 0,
        };
        var oldScore = Score;
        Score += amount;
        EvaluateHighScore();
        PachinkoEventManager.Instance.Score(oldScore, Score);
    }

    public static void EvaluateHighScore() {
        HighScore = Mathf.Max(Score, HighScore);
    }
}

public enum HitType : byte {
    NewHit,
    ReHit,
    NoHit,
}
