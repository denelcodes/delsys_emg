import pygame
import random
import os
import math

pygame.init()

# --------------------------
# Window and Basic Settings
# --------------------------
WIDTH, HEIGHT = 800, 400
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Enhanced Dino Game with Scrolling Sand")
clock = pygame.time.Clock()
FPS = 60

# --------------------------
# Colors and Day/Night Cycle
# --------------------------
BLACK = (0, 0, 0)
DAY_COLOR = (135, 206, 235)  # light sky blue
NIGHT_COLOR = (20, 24, 82)   # dark blue
CYCLE_DURATION = 30000  # full cycle duration in milliseconds

def get_background_color():
    time_ms = pygame.time.get_ticks() % CYCLE_DURATION
    brightness = (math.sin(2 * math.pi * time_ms / CYCLE_DURATION - math.pi / 2) + 1) / 2
    bg_color = tuple(int(DAY_COLOR[i] * brightness + NIGHT_COLOR[i] * (1 - brightness)) for i in range(3))
    return bg_color

# --------------------------
# Font
# --------------------------
FONT = pygame.font.SysFont(None, 30)

# --------------------------
# Ground and Game States
# --------------------------
GROUND_LEVEL = 340  # y-coordinate where the ground starts
game_state = "menu"
score = 0
player_name = ""

# --------------------------
# High Score Management
# --------------------------
high_scores = []
HIGH_SCORE_FILE = "highscores.txt"

def load_high_scores():
    global high_scores
    high_scores = []
    if os.path.exists(HIGH_SCORE_FILE):
        with open(HIGH_SCORE_FILE, "r") as f:
            for line in f:
                parts = line.strip().split(",")
                if len(parts) == 2:
                    name = parts[0]
                    try:
                        sc = int(parts[1])
                        high_scores.append((name, sc))
                    except:
                        continue
        high_scores.sort(key=lambda x: x[1], reverse=True)

def save_high_scores():
    with open(HIGH_SCORE_FILE, "w") as f:
        for name, sc in high_scores:
            f.write(f"{name},{sc}\n")

def add_high_score(name, score_val):
    global high_scores
    high_scores.append((name, score_val))
    high_scores.sort(key=lambda x: x[1], reverse=True)
    high_scores[:] = high_scores[:5]
    save_high_scores()

load_high_scores()

# --------------------------
# Load Sprites, Obstacles, Background, etc.
# (Unchanged code for sprites, obstacles, parallax, etc.)
# --------------------------
# [Code omitted for brevity: dino_frames, obstacle spawn, parallax updates, etc.]

# --------------------------
# New: Function to Read Finger Value from Text File
# --------------------------
def read_finger_from_file():
    finger = ""
    try:
        # Open the file in read-plus mode, then clear its contents after reading.
        with open("finger_log.txt", "r+") as f:
            finger = f.read().strip()
            f.seek(0)
            f.truncate()
    except Exception as e:
        pass  # In case the file doesn't exist yet
    return finger

# --------------------------
# Main Game Loop
# --------------------------
running = True
while running:
    dt = clock.tick(FPS)
    
    if game_state == "menu":
        # Draw menu screen (unchanged)
        # [Menu drawing code omitted for brevity]
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_s:
                    # Reset game variables as needed
                    # [Reset code omitted for brevity]
                    game_state = "playing"
                elif event.key == pygame.K_q:
                    running = False
                elif event.key == pygame.K_h:
                    game_state = "high_scores"
                    
    elif game_state == "high_scores":
        # High score screen code (unchanged)
        # [High score code omitted for brevity]
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_b:
                    game_state = "menu"
                    
    elif game_state == "playing":
        level = score // 5
        obstacle_speed = 5 + level
        current_gravity = 0.5 + level * 0.05  # base_gravity modified if needed
        
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                # Still allow pause via keyboard
                if event.key == pygame.K_p:
                    game_state = "paused"
                # Removed the space bar jump event to rely solely on finger input
                # if event.key == pygame.K_SPACE and jump_count < 2:
                #    dino_velocity_y = base_jump_strength
                #    jump_count += 1
        
        # Check for finger input from file
        finger_input = read_finger_from_file()
        if finger_input:
            # 'I' triggers a normal jump (only when no jump is active)
            if finger_input.lower() == "i" and jump_count == 0:
                dino_velocity_y = -10  # base_jump_strength (adjust as needed)
                jump_count += 1
            # 'r' triggers a double jump (only allowed if one jump has been performed)
            elif finger_input.lower() == "r" and jump_count == 1:
                dino_velocity_y = -10  # base_jump_strength (adjust as needed)
                jump_count += 1
        
        # Update dino animation and physics (unchanged)
        dino_anim_timer += dt
        if dino_anim_timer > 200:
            dino_frame_index = (dino_frame_index + 1) % len(dino_frames)
            dino_anim_timer = 0
        
        dino_y += dino_velocity_y
        dino_velocity_y += current_gravity
        
        if dino_y >= GROUND_LEVEL - 80 + 20:  # Adjusted to dino_y resets at ground level
            dino_y = GROUND_LEVEL - 80 + 20
            jump_count = 0
            dino_velocity_y = 0
        
        # Obstacle movement and collision detection (unchanged)
        current_obstacle["x"] -= obstacle_speed
        if current_obstacle["x"] < -current_obstacle["width"]:
            score += 1
            current_obstacle = spawn_obstacle(score // 5)
        
        # Update parallax and ground scrolling (unchanged)
        # [Code omitted for brevity]
        
        dino_rect = pygame.Rect(50, dino_y, 120, 80)  # dino collision box based on updated variables
        obs = current_obstacle
        obs_rect = pygame.Rect(obs["x"], obs["y"], obs["width"], obs["height"])
        if dino_rect.colliderect(obs_rect):
            game_state = "gameover"
        
        # Draw the game (unchanged)
        # [Game drawing code omitted for brevity]
        pygame.display.update()
        
    elif game_state == "paused":
        # Pause screen code (unchanged)
        # [Pause screen code omitted for brevity]
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:
                    game_state = "playing"
                    
    elif game_state == "gameover":
        # Game over screen code (unchanged)
        # [Game over code omitted for brevity]
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                qualifies = len(high_scores) < 5 or score > high_scores[-1][1]
                if qualifies:
                    game_state = "enter_name"
                    player_name = ""
                else:
                    if event.key == pygame.K_r:
                        game_state = "menu"
                    elif event.key == pygame.K_q:
                        running = False
                        
    elif game_state == "enter_name":
        # Enter name screen code (unchanged)
        # [Enter name code omitted for brevity]
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_BACKSPACE:
                    player_name = player_name[:-1]
                elif event.key == pygame.K_RETURN:
                    if player_name != "":
                        add_high_score(player_name, score)
                        game_state = "menu"
                else:
                    if len(player_name) < 10:
                        player_name += event.unicode
                        
pygame.quit()
