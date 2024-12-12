# Create a state diagram for the GameManagerFSM using graphviz
from graphviz import Digraph

# Define the FSM states and transitions
fsm = Digraph('GameManagerFSM', format='png')
fsm.attr(rankdir='LR', size='12')

# Define states with labels
states = {
    'STATE_MAIN_MENU': 'Main Menu',
    'STATE_LEVEL1': 'Level 1',
    'STATE_LEVEL1_LOSE': 'Level 1 Lose',
    'STATE_LEVEL1_WIN': 'Level 1 Win',
    'STATE_LEVEL2': 'Level 2',
    'STATE_LEVEL2_LOSE': 'Level 2 Lose',
    'STATE_LEVEL2_WIN': 'Level 2 Win'
}

# Add states to the FSM diagram
for state, label in states.items():
    fsm.node(state, label, shape='ellipse')

# Define state transitions
transitions = [
    ('STATE_MAIN_MENU', 'STATE_LEVEL1', 'Spacebar Pressed'),
    ('STATE_LEVEL1', 'STATE_LEVEL1', 'Continue Level 1 (00)'),
    ('STATE_LEVEL1', 'STATE_LEVEL1_LOSE', 'Lose (01)'),
    ('STATE_LEVEL1', 'STATE_LEVEL1_WIN', 'Win (10)'),
    ('STATE_LEVEL1_LOSE', 'STATE_MAIN_MENU', 'Spacebar Pressed'),
    ('STATE_LEVEL1_WIN', 'STATE_LEVEL2', 'Spacebar Pressed'),
    ('STATE_LEVEL2', 'STATE_LEVEL2', 'Continue Level 2 (00)'),
    ('STATE_LEVEL2', 'STATE_LEVEL2_LOSE', 'Lose (01)'),
    ('STATE_LEVEL2', 'STATE_LEVEL2_WIN', 'Win (10)'),
    ('STATE_LEVEL2_LOSE', 'STATE_MAIN_MENU', 'Spacebar Pressed'),
    ('STATE_LEVEL2_WIN', 'STATE_MAIN_MENU', 'Spacebar Pressed')
]

# Add transitions to the FSM diagram
for src, dest, label in transitions:
    fsm.edge(src, dest, label)

# Render and display the FSM
fsm.render('GameManagerFSM')
fsm.view('GameManagerFSM.png')
