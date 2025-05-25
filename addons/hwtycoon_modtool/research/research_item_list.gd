@tool
extends ItemList

@onready var research_graph_edit = %ResearchGraphEdit

func _ready():
	item_selected.connect(_on_item_selected)


func update_research_item_list():
	self.clear()
	for node: GraphNode in research_graph_edit.nodes:
		self.add_item(node.title)


func _on_item_selected(index):
	research_graph_edit.set_selected(research_graph_edit.nodes[index])
