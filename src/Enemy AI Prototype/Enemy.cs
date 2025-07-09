using Godot;
using System;

public partial class Enemy : Node
{
	private enum HealthStates { Healthy, Dazed, Injured}
	private HealthStates _currentState;

	// Increments the health state every time method is called
	public void UpdateState()
	{
		if (_currentState == HealthStates.Healthy)
		{
			_currentState = HealthStates.Dazed;
			// Update enemy visuals
		}
		
		if (_currentState == HealthStates.Dazed)
		{
			_currentState = HealthStates.Injured;
			// Update enemy visuals
		}

		if (_currentState == HealthStates.Injured)
		{
			// Death logic
		}
	}
}
