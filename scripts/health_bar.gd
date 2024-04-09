extends ProgressBar

var maxHealth = 100
var currentPlayerHealth = 100

func _ready():
	# Set the maximum value of the progress bar
	max_value = maxHealth
	# Set the current value of the progress bar
	value = currentPlayerHealth

# Function to update the health bar
func update_health(health):
	# Update the current player health
	currentPlayerHealth = health
	# Clamp the health to make sure it doesn't go below 0 or above maxHealth
	currentPlayerHealth = clamp(currentPlayerHealth, 0, maxHealth)
	# Update the value of the progress bar
	value = currentPlayerHealth
