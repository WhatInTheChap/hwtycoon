@tool
extends GraphEdit

@onready var research = %Research
@onready var research_item_list = %ResearchItemList
@onready var menu_hbox = get_menu_hbox()
@onready var graph_node: GraphNode = GraphNode.new()
@onready var popup_menu: PopupMenu = PopupMenu.new()

## Array of all nodes in the graph.
var nodes = []
var selected_nodes: Array = []

var popup_menu_buttons: Dictionary = {
	"Add Node" = popup_menu_button.new(popup_menu_button.types.Button, "Add Node", "_on_popup_menu_add_node_button_pressed"),
	"Seperator" = popup_menu_button.new(popup_menu_button.types.Separator),
	"Rename" = popup_menu_button.new(popup_menu_button.types.Button, "Rename", "_on_popup_menu_rename_button_pressed"),
	"Delete" = popup_menu_button.new(popup_menu_button.types.Button, "Delete", "_on_popup_menu_delete_button_pressed"),
}


class popup_menu_button:
	enum types {Button, Separator}
	var type: types = types.Separator
	var text: String = "Unnamed Button"
	var on_pressed: String = "printerr(\"Invalid Callable\")"
	
	func _init(_type = types.Separator, _text = "Unnamed Button", _on_pressed = "printerr(\"Invalid Callable\")"):
		type = _type
		text = _text
		on_pressed = _on_pressed


func _ready():
	# Initialize research_graph_edit
	var button: Button = Button.new()
	button.text = "Add Node"
	
	button.pressed.connect(_on_add_node_button_pressed)
	child_entered_tree.connect(_on_child_added)
	node_selected.connect(_on_Graph_node_selected)
	node_deselected.connect(_on_Graph_node_deselected)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	popup_request.connect(_on_popup_request)
	
	menu_hbox.add_spacer(true)
	menu_hbox.add_child(button)
	# Move child to beginning
	menu_hbox.move_child(menu_hbox.get_child(-1),0)
	
	# TODO: replace with custom class
	# Initialize graph_node
	var category = OptionButton.new()
	
	for item in research.categories:
		category.add_item(item)
	
	graph_node.title = "New Node"
	graph_node.add_child(category)
	graph_node.set_slot_enabled_left(0, true)
	graph_node.set_slot_color_left(0, Color(0.549, 0.549, 0.549))
	graph_node.set_slot_type_left(0, 0)
	graph_node.set_slot_enabled_right(0, true)
	graph_node.set_slot_color_right(0, Color(0.549, 0.549, 0.549))
	graph_node.set_slot_type_right(0, 0)
	
	# Initialize popup_menu
	for key in popup_menu_buttons:
		var item = popup_menu_buttons[key]
		match item.type:
			popup_menu_button.types.Button:
				popup_menu.add_item(item.text)
			popup_menu_button.types.Separator:
				popup_menu.add_separator()
	
	popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	
	popup_menu.visible = false
	add_child(popup_menu)


func _on_child_added(node):
	node.ready.connect(research_item_list.update_research_item_list, CONNECT_ONE_SHOT)


func _on_add_node_button_pressed():
	var node: GraphNode = graph_node.duplicate()
	nodes.append(node)
	add_child(node)
	if (snapping_enabled == true):
		var pos: Vector2 = (self.scroll_offset + self.size / 2) / self.zoom - node.size / 2;
		node.position_offset = pos.snapped(Vector2(snapping_distance,snapping_distance))
	else:
		node.position_offset = (self.scroll_offset + self.size / 2) / self.zoom - node.size / 2;


func _on_Graph_node_selected(node):
	selected_nodes.append(node)
	update_popup_menu()


func _on_Graph_node_deselected(node):
	selected_nodes.erase(node)
	update_popup_menu()


# TODO: Tell nodes they've been connected
func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)


# TODO: Tell nodes they've been disconnected
func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)


func _on_popup_request(pos):
	popup_menu.position = get_global_mouse_position()
	popup_menu.visible = true


func _on_popup_menu_index_pressed(index):
	call(popup_menu_buttons[popup_menu.get_item_text(index)].on_pressed)
	


func _on_popup_menu_add_node_button_pressed():
	var node: GraphNode = graph_node.duplicate()
	nodes.append(node)
	add_child(node)
	if (snapping_enabled == true):
		var pos: Vector2 = get_local_mouse_position() - node.size / 2;
		node.position_offset = pos.snapped(Vector2(snapping_distance,snapping_distance))
	else:
		node.position_offset = get_local_mouse_position()

# TODO: Create rename dialog box
func _on_popup_menu_rename_button_pressed():
	for node: GraphNode in selected_nodes:
		node.title = "Renamed"
	research_item_list.update_research_item_list()

func _on_popup_menu_delete_button_pressed():
	for node: GraphNode in selected_nodes:
		nodes.erase(node)
		self.remove_child(node)
	research_item_list.update_research_item_list()
