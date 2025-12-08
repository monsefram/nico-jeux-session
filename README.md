# HyperClimb
Créé par : Monsef Ramhane

## Introduction

HyperClimb est un jeu de plateforme 2D basé sur la physique. Le joueur contrôle une voiture qui doit grimper des pentes, franchir des bosses et atteindre le drapeau de fin de niveau sans se retourner .  
Le jeu mélange contrôle du véhicule, gestion de la vitesse et lecture du terrain. Une mécanique de rewind permet aussi de remonter le temps pour corriger une erreur de conduite.

---

## Concepts utilisés

### 1. Physique du véhicule (RigidBody2D + roues)

Le cœur du jeu repose sur une voiture entièrement gérée par la physique de Godot (RigidBody2D) avec des roues indépendantes.

Dans le script `car.gd` :
- Le châssis est un `RigidBody2D`.
- Les roues sont aussi des `RigidBody2D` ajoutées dans un groupe `wheel`.
- Le joueur n’applique jamais directement une position, mais seulement des forces et des torques.

Exemple (extrait simplifié) :

```gdscript
if Input.is_action_pressed("ui_right"):
	apply_torque_impulse(body_torque * s)
	for w in wheels:
		if w.angular_velocity < max_speed:
			w.apply_torque_impulse(speed * s)
```

La voiture réagit donc :
- Aux collisions avec le terrain.
- À la gravité.
- Aux variations de pente et de relief.

**Sources d’information :**
- Documentation officielle Godot 4 (PhysicsBody2D, RigidBody2D).
- Notes de cours sur la physique 2D.

![alt text](image-1.png)

---

### 2. Algorithme 1 : Système de rewind (remonter le temps)

Le rewind est une mécanique importante d’HyperClimb. Elle permet au joueur de remonter quelques secondes en arrière au lieu de recommencer complètement le niveau.

Dans `car.gd`, à chaque frame, l’état de la voiture est enregistré dans un tampon :

- Position (`global_position`)
- Rotation (`global_rotation`)
- Vitesse linéaire (`linear_velocity`)
- Vitesse angulaire (`angular_velocity`)

Exemple d’enregistrement :

```gdscript
func _record_state():
	buffer.append({
		"pos": global_position,
		"rot": global_rotation,
		"vel": linear_velocity,
		"ang": angular_velocity
	})
	if buffer.size() > max_frames:
		buffer.pop_front()
```

Quand le joueur maintient la touche de rewind (`back`) :
- Le jeu bascule dans un mode spécial.
- Les états sont relus à l’envers.

```gdscript
func _rewind(delta):
	if buffer.size() == 0:
		_stop_rewind()
		return

	var state = buffer.pop_back()
	global_position = state["pos"]
	global_rotation = state["rot"]
	linear_velocity = state["vel"]
	angular_velocity = state["ang"]
```

Pour limiter l’abus, il y a :
- Une durée maximale d’historique (`max_frames`).
- Un délai de récupération (`rewind_delay = 10.0`) avant de pouvoir réutiliser la mécanique.

Un son spécial de rewind est aussi joué lors de l’activation pour renforcer le feedback.

**Sources d’information :**
- Tutoriels et exemples de “replay system” / “rewind mechanic” dans Godot.
- Ces videoa : https://youtu.be/u53sQD-gg6A?si=gYmnExxJawlIDwKK
- https://youtu.be/HP3dvmKjEa8?si=DMDJWBxC-K85FnHP
- Et je me suis aider avec chatgpt car c'etais pour une ancienne version de godot sur la video .



---

### 3. Algorithme 2 : Machine à état fini (Finite State Machine)

Pour organiser la logique du jeu, une petite machine à état fini (FSM) est utilisée.  
L’objectif est de séparer clairement les deux modes principaux de la voiture :

- `STATE_NORMAL` : conduite normale.
- `STATE_REWIND` : lecture inverse de l’historique.

La FSM est définie dans un script autoload `StateMachine.gd` :

```gdscript
extends Node

enum {
	STATE_NORMAL,
	STATE_REWIND,
}

var current_state: int = STATE_NORMAL

func set_state(new_state: int) -> void:
	current_state = new_state

func is_state(test_state: int) -> bool:
	return current_state == test_state
```

Dans `car.gd`, la FSM est utilisée pour décider du comportement à chaque frame :

```gdscript
if StateMachine.is_state(StateMachine.STATE_REWIND):
	_rewind(delta)
	return
else:
	_record_state()
```

Lors du début et de la fin du rewind :

```gdscript
func _start_rewind():
	if rewind_cooldown > 0:
		return
	rewinding = true
	rewind_cooldown = rewind_delay
	StateMachine.set_state(StateMachine.STATE_REWIND)
	if rewind_fx:
		rewind_fx.play()

func _stop_rewind():
	rewinding = false
	StateMachine.set_state(StateMachine.STATE_NORMAL)
```

Cette approche rend le code plus clair.

**Sources d’information :**
- Cette video: https://youtu.be/ow_Lum-Agbs?si=bIeUZZlDPm--6G5I
- Notes de cours .


---


### 4. Aide intégrée au projet

Le jeu contient un menu d’options qui sert d’aide intégrée. On peut y retrouver notamment :

- La liste des touches utilisées (clavier, manette, arcade).
- Une explication du but du jeu.
- Des réglages de volume pour la musique et les effets.

L’aide n’est pas dans le menu principal, mais bien dans un sous-menu dédié, comme demandé dans l’énoncé.

![alt text](image-2.png)

![alt text](image-3.png)

---

## Conclusion

HyperClimb est un projet qui combine :

- Une physique de véhicule basée sur des `RigidBody2D`.
- Une mécanique de rewind originale qui donne une deuxième chance au joueur.
- Une machine à état fini simple mais efficace pour structurer les modes du jeu.
