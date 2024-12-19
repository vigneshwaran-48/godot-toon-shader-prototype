extends CSGBox3D

@onready var interactable: Interactable = %BuildingInteractable

var interacted: bool

func _ready() -> void:
	interactable.interact = Callable(self, "_on_interact")
	
func _on_interact(player: Player) -> void:
	Dialogic.start("building", "interacted_already" if interacted else "interact")
	if !interacted:
		interacted = true
