# Space Force X - Team Disaster Strikes

## Overview
**Space Force X** is a Verilog-based video game created using Vivado for the Basys3 Artix-7 FPGA with VGA output. Players control a tank using a PS/2 keyboard to shoot descending aliens. The game features dynamic levels, progressive difficulty, score tracking, and Game Over/Win screens.

---

## Team Members (Disaster Strikes):
- **Syed Amn Abbas Naqvi**
- **Mahnoor Nauman Shaikh**
- **Aneeza Khan**
- **Syeda Seerat Zahra**

*Habib University CS 2027*

---

## Gameplay Summary
- **Controls:**
  - `A` - Move Left  
  - `D` - Move Right  
  - `W` - Shoot  
  - `P` - Pause
  - U18 push button on FPGA - Reset Game (Start Screen)

- **Game Progression:**
  - **Level 1:** Aliens descend in vertical columns; destroying one alien destroys the entire column.
  - **Level 2:** Aliens descend in staggered columns; each bullet destroys only one alien.

- **Winning Condition:** Destroy all aliens.
- **Losing Condition:** An alien collides with the tank.

---

## System Design

### Key Modules:
1. **Input Block:**
   - **Keyboard:** PS/2 interface for key detection.
   - **Basys3 FPGA:** U18 push button for reset.

2. **Control Block:**
   - **Aliens Movement (FSM):** Manages alien movement and collision detection.
   - **Bullet Movement (FSM):** Handles shooting, movement, and collision detection.
   - **Tank Control:** Manages left/right tank movement.
   - **Game State FSM:** Manages game states (start, play, win, game over).
   - **Text Generation and ASCII ROM:** Displays score and game messages.

3. **Output Block:**
   - **VGA Display:** Renders game objects, scores, and screens (Start, Level Win, Game Over).

---

## References
- [Keyboard Module Guide - Lucario2319](https://github.com/amnnaqvi/Disaster-Strikes-Digital-Logic-Design)
- [FPGA Text Generation Example](https://github.com/klam20/FPGAProjects/tree/main/VGATextGeneration)

---

## GitHub Repository
[Disaster Strikes - Digital Logic Design Project](https://github.com/amnnaqvi/Disaster-Strikes-Digital-Logic-Design) (`SpaceForceX` folder)

---

## How to Run
1. Connect the Basys3 Artix-7 FPGA.
2. Connect a PS/2 keyboard to the FPGA.
3. Connect a VGA cable to the FPGA.
4. Open the "SpaceForceX" folder and generate bitstream.
5. Program device and enjoy the game!

---

**Note:** For detailed implementation specifics, FSM diagrams, and module descriptions, refer to the project report PDF in the repository.
