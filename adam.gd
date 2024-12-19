extends Node3D

@onready var interactable: Interactable = %Interactable

var player: Player

func _ready() -> void:
	interactable.interact = Callable(self, "_on_interact")

func _on_interact(player: Player) -> void:
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start("adam")
	self.player = player
	player.is_interacting = true
	
func _on_timeline_ended() -> void:
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	if player:
		player.is_interacting = false
