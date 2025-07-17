using Godot;

public partial class Peg : StaticBody3D {
    Color startColor;
    Tween punchTween;

    const string BRIGHTNESS = "peg_brightness";
    const string EMISSION = "peg_emission";
    const string SIZE = "peg_size";

    bool alreadyHit;

    [Export]
    MeshInstance3D mesh;

    [Export]
    float hitEmission,
          initialEmission = 0.1f;

    [Export]
    float hitScale = 1.5f,
          unHitScale = 1.2f,
          reHitScale = 1.0f;

    [Export]
    float hitDuration = 0.25f,
          hitDelay = 0.05f;

    public void Setup() {
        punchTween?.Kill();
        alreadyHit = false;
        mesh.SetInstanceShaderParameter(BRIGHTNESS, initialEmission);
        mesh.SetInstanceShaderParameter(SIZE, unHitScale);
    }

    public void Punch() {
        punchTween?.Kill();
        punchTween = CreateTween()
            .SetEase(Tween.EaseType.Out)
            .SetTrans(Tween.TransitionType.Back)
            .SetParallel();

        mesh.SetInstanceShaderParameter(SIZE, hitScale);
        mesh.SetInstanceShaderParameter(BRIGHTNESS, hitEmission);

        punchTween.TweenMethod(Callable.From<float>(x => {
            mesh.SetInstanceShaderParameter(SIZE, x);
        }), hitScale, reHitScale, hitDuration);
        punchTween.TweenMethod(Callable.From<float>(x => {
            mesh.SetInstanceShaderParameter(BRIGHTNESS, x);
        }), hitEmission, initialEmission, hitDuration).SetDelay(hitDelay);

        PachinkoEventManager.Instance.Hit(alreadyHit ? HitType.ReHit : HitType.NewHit);
        alreadyHit = true;
    }
}
