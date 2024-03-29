statemachine class W3GuidingWindWatcher extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		AddTimer('wait_for_player', 0.00001f , true);
		CreateAttachment ( thePlayer );

		this.PushState('RunningState');
	}

	timer function wait_for_player( deltaTime : float , id : int)
	{	
		if ( GetWitcherPlayer() )
		{
			GuidingWindEntitySpawn();

			RemoveTimer( 'wait_for_player' );
		}
	}

	timer function guiding_wind_sound_delay( deltaTime : float , id : int)
	{	
		if ( FactsQuerySum("guiding_wind_delay") > 0 )
		{
			if (GuidingWindSoundEnabled())
			{
				thePlayer.SoundEvent("magic_man_tornado_loop_start");

   				FactsAdd("guiding_wind_sound_playing", 1);
			}
		}
	}

	timer function guiding_wind_reset( deltaTime : float , id : int)
	{	
		if (GetGuidingWindMarker().IsEffectActive('guiding_wind_player_marker', false))
		{
			GetGuidingWindMarker().StopEffect('guiding_wind_player_marker');
		}

		if (GetGuidingWindQuestMarker().IsEffectActive('guiding_wind_quest_marker', false))
		{
			GetGuidingWindQuestMarker().StopEffect('guiding_wind_quest_marker');
		}

		WindRemove();
	}

	function WindRemove()
	{
		if ( FactsQuerySum("guiding_wind_delay") > 0 )
		{
			GetGuidingWindEnt().StopEffect('wind');
			GetGuidingWindEnt().StopEffect('wind_less_particles');
			GetGuidingWindEnt().StopEffect('wind_slow');
			GetGuidingWindEnt().StopEffect('wind_slow_less_particles');
			GetGuidingWindEnt().StopEffect('wind_fast');
			GetGuidingWindEnt().StopEffect('wind_fast_less_particles');

			GetGuidingWindEnt().StopEffect('ripple_force');

			GetGuidingWindEnt().StopEffect('embers');
			GetGuidingWindEnt().StopEffect('embers_less_particles');
			GetGuidingWindEnt().StopEffect('embers_slow');
			GetGuidingWindEnt().StopEffect('embers_slow_less_particles');
			GetGuidingWindEnt().StopEffect('embers_fast');
			GetGuidingWindEnt().StopEffect('embers_fast_less_particles');

			if ( FactsQuerySum("guiding_wind_sound_playing") > 0 )
			{
				thePlayer.SoundEvent("magic_man_tornado_loop_stop");

				FactsRemove("guiding_wind_sound_playing");
			}

			FactsRemove("guiding_wind_delay");
		}
	}

	function GuidingWind_InitializeSettings() 
	{
		theGame.GetInGameConfigWrapper().ApplyGroupPreset('modGuidingWind', 0);

		theGame.SaveUserSettings();
	}
	
	function GuidingWindEntitySpawn()
	{
		var ent, ent_2		       											: CEntity;
		var rot			                        						 	: EulerAngles;
		var pos, pos2														: Vector;
		var animcomp 														: CAnimatedComponent;

		GetGuidingWindEnt().Destroy();

		GetGuidingWindMarker().Destroy();

		if ( !theSound.SoundIsBankLoaded("magic_man_mage.bnk") )
		{
			theSound.SoundLoadBank( "magic_man_mage.bnk", false );
		}

		if (!GuidingWind_IsInitialized())
		{
			GuidingWind_InitializeSettings();
		}

		rot = thePlayer.GetWorldRotation();

		pos = thePlayer.GetWorldPosition() + Vector( 0, 0, -200 );

		pos2 = thePlayer.GetWorldPosition() + Vector( 0, 0, 0 );

		ent = theGame.CreateEntity( (CEntityTemplate)LoadResource( 

		"dlc\dlc_guiding_wind\data\fx\guiding_wind_ent_old.w2ent"

		, true ), pos, rot );

		ent.AddTag('Guiding_Wind_Entity');

		((CNewNPC)ent).EnableCharacterCollisions(false);
		((CNewNPC)ent).EnableCollisions(false);

		((CActor)ent).AddBuffImmunity_AllNegative('Guiding_Wind_Entity', true);

		((CActor)ent).AddBuffImmunity_AllCritical('Guiding_Wind_Entity', true);

		((CActor)ent).SetUnpushableTarget(thePlayer);

		((CActor)ent).SetImmortalityMode( AIM_Invulnerable, AIC_Combat ); 
		((CActor)ent).SetCanPlayHitAnim(false); 

		((CNewNPC)ent).SetTemporaryAttitudeGroup( 'q104_avallach_friendly_to_all', AGP_Default );	

		animcomp = (CAnimatedComponent)ent.GetComponentByClassName('CAnimatedComponent');
		animcomp.FreezePose();




		ent_2 = theGame.CreateEntity( (CEntityTemplate)LoadResource( 

		"dlc\dlc_guiding_wind\data\fx\guiding_wind_ent_old.w2ent"

		, true ), pos, thePlayer.GetWorldRotation() );

		ent_2.AddTag('Guiding_Wind_Marker');

		((CNewNPC)ent_2).EnableCharacterCollisions(false);
		((CNewNPC)ent_2).EnableCollisions(false);

		((CActor)ent_2).AddBuffImmunity_AllNegative('Guiding_Wind_Entity', true);

		((CActor)ent_2).AddBuffImmunity_AllCritical('Guiding_Wind_Entity', true);

		((CActor)ent_2).SetUnpushableTarget(thePlayer);

		((CActor)ent_2).SetImmortalityMode( AIM_Invulnerable, AIC_Combat ); 
		((CActor)ent_2).SetCanPlayHitAnim(false); 

		((CNewNPC)ent_2).SetTemporaryAttitudeGroup( 'q104_avallach_friendly_to_all', AGP_Default );

		animcomp = (CAnimatedComponent)ent_2.GetComponentByClassName('CAnimatedComponent');
		animcomp.FreezePose();
	}

	event OnCommSheatheAny( action : SInputAction )
	{
		if( IsPressed(action) )
		{
			if (FactsQuerySum("GuidingWindQuestMarkerActive") <= 0)
			{
				GetWitcherPlayer().DisplayHudMessage( GetLocStringById(2117945011) );

				thePlayer.PlayLine( 1054181, true);

				FactsAdd("GuidingWindQuestMarkerActive", 1, -1);
			}
			else if (FactsQuerySum("GuidingWindQuestMarkerActive") > 0)
			{
				GetWitcherPlayer().DisplayHudMessage( GetLocStringById(2117945012) );

				thePlayer.PlayLine( 1054175, true);

				FactsRemove("GuidingWindQuestMarkerActive");
			}
		}
		
		if ( IsReleased( action ) )
		{
			
		}
	}
}

state RunningState in W3GuidingWindWatcher 
{
	event OnEnterState(previous_state_name: name) 
	{
    	super.OnEnterState(previous_state_name);
	
    	this.RunningEntry();
	}

	entry function RunningEntry() 
	{
		while (true) 
		{
			if (GuidingWind_IsEnabled())
			{
				WindControl();

				QuestMarkerControl();
			}
			else
			{
				if (FactsQuerySum("GuidingWindHijackHorseCall") > 0)
				{
					theInput.UnregisterListener( this.parent, 'SwordSheathe' );

					theInput.RegisterListener( thePlayer.GetInputHandler(), 'OnCommSheatheAny', 'SwordSheathe' );

					FactsRemove("GuidingWindHijackHorseCall");
				}
			}
			
      		Sleep(0.3);
    	}
	}

	latent function QuestMarkerControl()
	{
		if(theGame.GetFocusModeController().CanUseFocusMode()
		&& theGame.IsFocusModeActive()
		&& !thePlayer.IsInCombat()
		)
		{
			if (FactsQuerySum("GuidingWindHijackHorseCall") <= 0)
			{
				theInput.UnregisterListener( thePlayer.GetInputHandler(), 'SwordSheathe' ); 

				theInput.RegisterListener( this.parent, 'OnCommSheatheAny', 'SwordSheathe' );

				FactsAdd("GuidingWindHijackHorseCall", 1, -1);
			}
		}
		else
		{
			if (FactsQuerySum("GuidingWindHijackHorseCall") > 0)
			{
				theInput.UnregisterListener( this.parent, 'SwordSheathe' );

				theInput.RegisterListener( thePlayer.GetInputHandler(), 'OnCommSheatheAny', 'SwordSheathe' );

				FactsRemove("GuidingWindHijackHorseCall");
			}
		}
	}

	latent function WindControl()
	{
		var id																													: int;
		var index																												: int;
		var x																													: float;
		var y																													: float;
		var type																												: int;
		var area																												: int;
		var movementAdjustorGuidingWind																							: CMovementAdjustor; 
		var ticketGuidingWind 																									: SMovementAdjustmentRequestTicket; 
		var position, questMarkerPosition, playerPos																			: Vector;
		var rotation, rot, newRot 																								: EulerAngles;
		var questMarkerEnt																										: CEntity;
		var animcomp 																											: CAnimatedComponent;
		var targetDistanceQuestMarker 																							: float;
		
		targetDistanceQuestMarker = VecDistanceSquared2D( GetWitcherPlayer().GetWorldPosition(), GetGuidingWindQuestMarker().GetWorldPosition() );

		if ( theGame.IsDialogOrCutscenePlaying() 
		|| thePlayer.IsInNonGameplayCutscene() 
		|| thePlayer.IsInGameplayScene() 
		|| theGame.IsCurrentlyPlayingNonGameplayScene()
		|| theGame.IsFading()
		|| theGame.IsBlackscreen()
		|| thePlayer.IsInInterior()
		)
		{
			if (GetGuidingWindMarker().IsEffectActive('guiding_wind_player_marker', false))
			{
				GetGuidingWindMarker().StopEffect('guiding_wind_player_marker');
			}

			if (GetGuidingWindQuestMarker().IsEffectActive('guiding_wind_quest_marker', false))
			{
				GetGuidingWindQuestMarker().StopEffect('guiding_wind_quest_marker');
			}

			if (targetDistanceQuestMarker < 6 * 6
			|| thePlayer.IsInInterior() )
			{
				parent.WindRemove();
			}

			return;
		}

		if (theGame.GetCommonMapManager().GetUserMapPinCount() == 0)
		{
			if (GetGuidingWindMarker().IsEffectActive('guiding_wind_player_marker', false))
			{
				GetGuidingWindMarker().StopEffect('guiding_wind_player_marker');
			}

			if ( !GuidingWindGetQuestPoint()
			|| FactsQuerySum("GuidingWindQuestMarkerActive") <= 0
			|| targetDistanceQuestMarker < 6 * 6
			)
			{
				if(GetGuidingWindQuestMarker())
				{
					GetGuidingWindQuestMarker().Destroy();
				}

				if (GetGuidingWindQuestMarker().IsEffectActive('guiding_wind_quest_marker', false))
				{
					GetGuidingWindQuestMarker().StopEffect('guiding_wind_quest_marker');
				}

				parent.WindRemove();

				return;
			}
			else
			{
				GuidingWindGetQuestPointPosition(questMarkerPosition);	

				rot = thePlayer.GetWorldRotation();

				if(!GetGuidingWindQuestMarker())
				{
					GetGuidingWindQuestMarker().Destroy();

					questMarkerEnt = theGame.CreateEntity( (CEntityTemplate)LoadResourceAsync( 

					"dlc\dlc_guiding_wind\data\fx\guiding_wind_ent_old.w2ent"

					, true ), questMarkerPosition, thePlayer.GetWorldRotation() );

					questMarkerEnt.AddTag('Guiding_Wind_Quest_Marker');

					((CNewNPC)questMarkerEnt).EnableCharacterCollisions(false);
					((CNewNPC)questMarkerEnt).EnableCollisions(false);

					((CActor)questMarkerEnt).AddBuffImmunity_AllNegative('Guiding_Wind_Entity', true);

					((CActor)questMarkerEnt).AddBuffImmunity_AllCritical('Guiding_Wind_Entity', true);

					((CActor)questMarkerEnt).SetUnpushableTarget(thePlayer);

					((CActor)questMarkerEnt).SetImmortalityMode( AIM_Invulnerable, AIC_Combat ); 
					((CActor)questMarkerEnt).SetCanPlayHitAnim(false); 

					((CNewNPC)questMarkerEnt).SetTemporaryAttitudeGroup( 'q104_avallach_friendly_to_all', AGP_Default );

					animcomp = (CAnimatedComponent)questMarkerEnt.GetComponentByClassName('CAnimatedComponent');
					animcomp.FreezePose();

					questMarkerEnt.AddTag('Guiding_Wind_Quest_Marker');
				}
		
				newRot = VecToRotation( theCamera.GetCameraDirection() );

				//newRot.Yaw += 180;

				newRot.Pitch = rot.Pitch;

				newRot.Roll = rot.Roll;

				//playerPos = thePlayer.GetWorldPosition();

				//questMarkerPosition.Z = playerPos.Z;

				//questMarkerPosition.Z += 1.5;

				GetGuidingWindQuestMarker().TeleportWithRotation( TraceFloor(questMarkerPosition), newRot );

				GetGuidingWindEnt().Teleport(  theCamera.GetCameraPosition() + (theCamera.GetCameraUp() * -2) + (theCamera.GetCameraForward() * -4) );

				movementAdjustorGuidingWind = GetGuidingWindEnt().GetMovingAgentComponent().GetMovementAdjustor();
				movementAdjustorGuidingWind.CancelByName( 'ACS_Guiding_Wind_Rotate' );

				movementAdjustorGuidingWind.CancelAll();
				ticketGuidingWind = movementAdjustorGuidingWind.CreateNewRequest( 'ACS_Guiding_Wind_Rotate' );

				//movementAdjustorGuidingWind.AdjustLocationVertically( ticketGuidingWind, true );
				//movementAdjustorGuidingWind.ScaleAnimationLocationVertically( ticketGuidingWind, true );

				movementAdjustorGuidingWind.RotateTowards( ticketGuidingWind, GetGuidingWindQuestMarker() );

				if(theGame.GetFocusModeController().CanUseFocusMode()
				&& theGame.IsFocusModeActive()
				&& GetGuidingWindQuestMarker()
				&& targetDistanceQuestMarker >= 6 * 6
				)
				{
					ParticleSwitch();
				}
				else
				{
					if (GetGuidingWindQuestMarker().IsEffectActive('guiding_wind_quest_marker', false))
					{
						GetGuidingWindQuestMarker().StopEffect('guiding_wind_quest_marker');
					}
				}
			}
		}
		else if (theGame.GetCommonMapManager().GetUserMapPinCount() > 0)
		{
			GetGuidingWindEnt().Teleport(  theCamera.GetCameraPosition() + (theCamera.GetCameraUp() * -2) + (theCamera.GetCameraForward() * -4) );

			theGame.GetCommonMapManager().GetUserMapPinByIndex( 0, id, area, position.X, position.Y, type );	

			playerPos = thePlayer.GetWorldPosition();

			position.Z = playerPos.Z;

			position.Z += 1.5;
			
			GetGuidingWindMarker().Teleport( TraceFloor(position) );

			movementAdjustorGuidingWind = GetGuidingWindEnt().GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustorGuidingWind.CancelByName( 'ACS_Guiding_Wind_Rotate' );

			movementAdjustorGuidingWind.CancelAll();
			ticketGuidingWind = movementAdjustorGuidingWind.CreateNewRequest( 'ACS_Guiding_Wind_Rotate' );

			//movementAdjustorGuidingWind.AdjustLocationVertically( ticketGuidingWind, true );
			//movementAdjustorGuidingWind.ScaleAnimationLocationVertically( ticketGuidingWind, true );

			movementAdjustorGuidingWind.RotateTowards( ticketGuidingWind, GetGuidingWindMarker() );

			if(theGame.GetFocusModeController().CanUseFocusMode()
			&& theGame.IsFocusModeActive())
			{
				ParticleSwitch();
			}
			else
			{
				if (GetGuidingWindMarker().IsEffectActive('guiding_wind_player_marker', false))
				{
					GetGuidingWindMarker().StopEffect('guiding_wind_player_marker');
				}

				if (GetGuidingWindQuestMarker().IsEffectActive('guiding_wind_quest_marker', false))
				{
					GetGuidingWindQuestMarker().StopEffect('guiding_wind_quest_marker');
				}
			}
		}
		else
		{
			parent.WindRemove();
		}
	}

	latent function ParticleSwitch()
	{
		if (GuidingWindParticleType() == 0)
		{
			GetGuidingWindEnt().StopEffect('embers');
			GetGuidingWindEnt().StopEffect('embers_less_particles');
			GetGuidingWindEnt().StopEffect('embers_slow');
			GetGuidingWindEnt().StopEffect('embers_slow_less_particles');
			GetGuidingWindEnt().StopEffect('embers_fast');
			GetGuidingWindEnt().StopEffect('embers_fast_less_particles');

			if (GuidingWindParticleAmount() == 2)
			{
				if (
					GetGuidingWindEnt().IsEffectActive('wind_fast_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('wind_fast_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('wind_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('wind_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('wind_slow_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('wind_slow_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('wind_fast', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('wind_fast');
				}
			}
			else if (GuidingWindParticleAmount() == 1)
			{

				if (
					GetGuidingWindEnt().IsEffectActive('wind_slow_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('wind_slow_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('wind_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('wind_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('wind_fast', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('wind_fast_less_particles');
				}
			}
			else if (GuidingWindParticleAmount() == 0)
			{
				if (
					GetGuidingWindEnt().IsEffectActive('wind_fast', false)
				)
				{
					GetGuidingWindEnt().StopEffect('wind_fast');
				}

				if (
					GetGuidingWindEnt().IsEffectActive('wind_slow_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('wind_slow_less_particles');
				}

				if (
					GetGuidingWindEnt().IsEffectActive('wind_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('wind_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('wind_fast_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('wind_fast_less_particles');
				}
			}
		}
		else if (GuidingWindParticleType() == 1)
		{
			GetGuidingWindEnt().StopEffect('wind');
			GetGuidingWindEnt().StopEffect('wind_less_particles');
			GetGuidingWindEnt().StopEffect('wind_slow');
			GetGuidingWindEnt().StopEffect('wind_slow_less_particles');
			GetGuidingWindEnt().StopEffect('wind_fast');
			GetGuidingWindEnt().StopEffect('wind_fast_less_particles');

			if (GuidingWindParticleAmount() == 2)
			{
				if (
					GetGuidingWindEnt().IsEffectActive('embers_fast_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('embers_fast_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('embers_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('embers_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('embers_slow_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('embers_slow_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('embers_fast', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('embers_fast');
				}
			}
			else if (GuidingWindParticleAmount() == 1)
			{

				if (
					GetGuidingWindEnt().IsEffectActive('embers_slow_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('embers_slow_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('embers_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('embers_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('embers_fast', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('embers_fast_less_particles');
				}
			}
			else if (GuidingWindParticleAmount() == 0)
			{
				if (
					GetGuidingWindEnt().IsEffectActive('embers_fast', false)
				)
				{
					GetGuidingWindEnt().StopEffect('embers_fast');
				}

				if (
					GetGuidingWindEnt().IsEffectActive('embers_slow_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('embers_slow_less_particles');
				}

				if (
					GetGuidingWindEnt().IsEffectActive('embers_less_particles', false)
				)
				{
					GetGuidingWindEnt().StopEffect('embers_less_particles');
				}

				if (
					!GetGuidingWindEnt().IsEffectActive('embers_fast_less_particles', false)
				)
				{
					GetGuidingWindEnt().PlayEffectSingle('embers_fast_less_particles');
				}
			}
		}

		if (!GetGuidingWindEnt().IsEffectActive('ripple_force', false))
		{
			GetGuidingWindEnt().PlayEffectSingle('ripple_force');
		}

		if (!GetGuidingWindMarker().IsEffectActive('guiding_wind_player_marker', false))
		{
			GetGuidingWindMarker().PlayEffectSingle('guiding_wind_player_marker');
		}

		FactsRemove("guiding_wind_delay");
		FactsAdd("guiding_wind_delay", 1);

		parent.RemoveTimer('guiding_wind_sound_delay');
		parent.AddTimer('guiding_wind_sound_delay', 0.3, false);

		parent.RemoveTimer('guiding_wind_reset');
		parent.AddTimer('guiding_wind_reset', GuidingWindResetDelay(), false);
	}
}

function GetGuidingWindWatcher() : W3GuidingWindWatcher
{
	var watcher 			 : W3GuidingWindWatcher;
	
	watcher = (W3GuidingWindWatcher)theGame.GetEntityByTag( 'guidingwindwatcherscripts' );

	return watcher;
}

function GetGuidingWindEnt() : CActor
{
	var entity 			 : CActor;
	
	entity = (CActor)theGame.GetEntityByTag( 'Guiding_Wind_Entity' );
	return entity;
}

function GetGuidingWindMarker() : CActor
{
	var entity 			 : CActor;
	
	entity = (CActor)theGame.GetEntityByTag( 'Guiding_Wind_Marker' );
	return entity;
}

function GetGuidingWindQuestMarker() : CActor
{
	var entity 			 : CActor;
	
	entity = (CActor)theGame.GetEntityByTag( 'Guiding_Wind_Quest_Marker' );
	return entity;
}

function GuidingWindGetConfigValue(nam : name) : string
{
	var conf: CInGameConfigWrapper;
	var value: string;
	
	conf = theGame.GetInGameConfigWrapper();
	
	value = conf.GetVarValue('modGuidingWind', nam);
	return value;
}

function GuidingWind_IsInitialized(): bool 
{
	var configValue :int;
	var configValueString : string;
	
	configValueString = GuidingWindGetConfigValue('modGuidingWindInit');
	configValue =(int) configValueString;
	
	return (bool)configValueString;
}

function GuidingWind_IsEnabled(): bool 
{
	var configValue :int;
	var configValueString : string;
	
	configValueString = GuidingWindGetConfigValue('modGuidingWindEnabled');
	configValue =(int) configValueString;
	
	if(configValueString=="" || configValue<0)
	{
		return true;
	}
	else return (bool)configValueString;
}

function GuidingWindSoundEnabled(): bool 
{
	var configValue :int;
	var configValueString : string;
	
	configValueString = GuidingWindGetConfigValue('modGuidingWindSoundEnabled');
	configValue =(int) configValueString;
	
	if(configValueString=="" || configValue<0)
	{
		return false;
	}
	else return (bool)configValueString;
}

function GuidingWindParticleType(): int 
{
	var configValue :int;
	var configValueString : string;
	
	configValueString = GuidingWindGetConfigValue('modGuidingWindParticleType');
	configValue =(int) configValueString;

	if(configValueString=="" || configValue<0)
	{
		return 0;
	}
	
	else return configValue;
}

function GuidingWindParticleAmount(): int 
{
	var configValue :int;
	var configValueString : string;
	
	configValueString = GuidingWindGetConfigValue('modGuidingWindParticleAmount');
	configValue =(int) configValueString;

	if(configValueString=="" || configValue<0)
	{
		return 2;
	}
	
	else return configValue;
}

function GuidingWindResetDelay(): float
{
	var configValue :float;
	var configValueString : string;
	
	configValueString = GuidingWindGetConfigValue('modGuidingWindResetDelay');
	configValue =(float) configValueString;

	if(configValueString=="" || configValue<0)
	{
		return 10;
	}
	
	else return configValue;
}


function GuidingWindGetQuestPoint() : bool
{
	var i 						: int;
	var pinInstances 			: array<SCommonMapPinInstance>;

	pinInstances = theGame.GetCommonMapManager().GetMapPinInstances(theGame.GetWorld().GetPath());

	for (i = 0; i < pinInstances.Size(); i += 1) 
	{
		if (pinInstances[i].isDiscovered || pinInstances[i].isKnown) 
		{
			if (
			theGame.GetCommonMapManager().IsQuestPinType(pinInstances[i].type)
			)
			{
				if (pinInstances.Size() > 0)
				return true;
			}
		}
	}

	return false;
}

function GuidingWindGetQuestPointPosition( out pinPos : Vector ) : bool
{
	var i 						: int;
	var pinInstances 			: array<SCommonMapPinInstance>;

	pinInstances = theGame.GetCommonMapManager().GetMapPinInstances(theGame.GetWorld().GetPath());

	for (i = 0; i < pinInstances.Size(); i += 1) 
	{
		if (pinInstances[i].isDiscovered || pinInstances[i].isKnown) 
		{
			if (
			theGame.GetCommonMapManager().IsQuestPinType(pinInstances[i].type)
			)
			{
				pinPos = pinInstances[i].position;
				return true;
			}
		}
	}

	return false;
}