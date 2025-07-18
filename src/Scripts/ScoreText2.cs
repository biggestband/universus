using Godot;
using System;

public partial class ScoreText2 : Label3D {
	public override void _EnterTree() {
		Pachinko.Events.OnScore += SetText;
		Pachinko.Events.OnFinalScore += SetFinalScore;
	}
	
	public override void _ExitTree() {
		Pachinko.Events.OnScore -= SetText;
		Pachinko.Events.OnFinalScore -= SetFinalScore;
	}
	
	void SetText(float oldScore, float newScore) {
		Text = $"{newScore:F1}";
	}
	
	void SetFinalScore(float @base, float mult) {
		var score = (int)(@base * mult);
		Text = $"{score}";
	}
}
