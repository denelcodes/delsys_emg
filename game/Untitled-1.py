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
# Load Sprites
# --------------------------
# Dinosaur frames
try:
    dino_frame1 = pygame.image.load("dino1.png").convert_alpha()
    dino_frame2 = pygame.image.load("dino2.png").convert_alpha()
except:
    dino_frame1 = pygame.Surface((40, 40))
    dino_frame1.fill((0, 150, 0))
    dino_frame2 = pygame.Surface((40, 40))
    dino_frame2.fill((0, 200, 0))

dino_width, dino_height = 120, 80
dino_frame1 = pygame.transform.scale(dino_frame1, (dino_width, dino_height))
dino_frame2 = pygame.transform.scale(dino_frame2, (dino_width, dino_height))
dino_frames = [dino_frame1, dino_frame2]
dino_frame_index = 0
dino_anim_timer = 0
dino_anim_delay = 200  # milliseconds between frames

# Define a vertical offset (in pixels) for the dino.
dino_offset = 20

# Dinosaur physics (initial y includes the offset)
dino_x = 50
dino_y = GROUND_LEVEL - dino_height + dino_offset
dino_velocity_y = 0
base_jump_strength = -10
base_gravity = 0.5
jump_count = 0  # allows up to 2 jumps

# --------------------------
# Obstacle Sprites (Collision Hit Box Sizes)
# --------------------------
# These base sizes define the collision hit box.
base_obstacle_width = 20
base_obstacle_height = 35

try:
    cactus_sprite = pygame.image.load("cactus.png").convert_alpha()
except:
    cactus_sprite = pygame.Surface((base_obstacle_width, base_obstacle_height))
    cactus_sprite.fill((150, 0, 0))
# We'll keep cactus_sprite at its original (collision) size;
# we will change the drawn dimensions later.
cactus_sprite = pygame.transform.scale(cactus_sprite, (base_obstacle_width, base_obstacle_height))

try:
    bush_sprite = pygame.image.load("bush.png").convert_alpha()
except:
    bush_sprite = pygame.Surface((30, 20))
    bush_sprite.fill((0, 100, 0))
try:
    bird_sprite = pygame.image.load("bird.png").convert_alpha()
except:
    bird_sprite = pygame.Surface((30, 20))
    bird_sprite.fill((0, 0, 150))

bush_sprite = pygame.transform.scale(bush_sprite, (30, 20))
bird_sprite = pygame.transform.scale(bird_sprite, (30, 20))

# Define a vertical offset for obstacles (to align with ground, if needed)
obstacle_offset = 40

# Now, specify the drawn dimensions for each obstacle type.
# These values can be changed independently of the collision hit box.
cactus_draw_width = 100
cactus_draw_height = 100

bush_draw_width = 60
bush_draw_height = 40

bird_draw_width = 60
bird_draw_height = 40

def spawn_obstacle(level):
    if level < 2:
        obstacle_type = "cactus"
    else:
        obstacle_type = random.choice(["cactus", "bush", "bird"])
    if obstacle_type == "cactus":
        width = base_obstacle_width
        height = base_obstacle_height + level * 2
        x = WIDTH
        y = GROUND_LEVEL - height + obstacle_offset
    elif obstacle_type == "bush":
        width = 30
        height = 20
        x = WIDTH
        y = GROUND_LEVEL - height + obstacle_offset
    elif obstacle_type == "bird":
        width = 30
        height = 20
        x = WIDTH
        y = random.randint(150, 250) + obstacle_offset
    return {"type": obstacle_type, "x": x, "y": y, "width": width, "height": height}

current_obstacle = spawn_obstacle(0)

# --------------------------
# Load Multiple Tree Sprites for Parallax Background (Cyclic Assignment)
# --------------------------
tree_images = []
for i in range(1, 5):
    try:
        img = pygame.image.load(f"tree{i}.png").convert_alpha()
    except:
        img = pygame.Surface((50, 100))
        img.fill((34, 139, 34))
    orig_width, orig_height = img.get_size()
    target_width = 100
    target_height = int(orig_height * (target_width / orig_width))
    img = pygame.transform.scale(img, (target_width, target_height))
    tree_images.append(img)

# --------------------------
# Load Sand Texture for the Ground
# --------------------------
try:
    sand_texture = pygame.image.load("sand.png").convert_alpha()
except:
    sand_texture = pygame.Surface((50, 50))
    sand_texture.fill((194, 178, 128))

# --------------------------
# Cloud Sprites: Load Multiple Cloud Images
# --------------------------
cloud_images = []
for cloud_name in ["cloud1.png", "cloud2.png", "cloud3.png"]:
    try:
        img = pygame.image.load(cloud_name).convert_alpha()
        img = pygame.transform.scale(img, (190, 120))
    except:
        img = pygame.Surface((190, 120))
        img.fill((200, 200, 200))
    cloud_images.append(img)

# Variables for scrolling sand
sand_offset = 0
sand_speed = 2

def draw_ground():
    sand_width, sand_height = sand_texture.get_size()
    for x in range(-sand_offset, WIDTH, sand_width):
        for y in range(GROUND_LEVEL, HEIGHT, sand_height):
            screen.blit(sand_texture, (x, y))

def update_ground():
    global sand_offset
    sand_width = sand_texture.get_width()
    sand_offset += sand_speed
    if sand_offset >= sand_width:
        sand_offset -= sand_width

# --------------------------
# Parallax Background Layers
# --------------------------
clouds = []
for i in range(5):
    x = random.randint(0, WIDTH)
    y = random.randint(20, 100)
    cloud_index = random.randint(0, len(cloud_images) - 1)
    clouds.append([x, y, cloud_index])
cloud_speed = 1

trees = []
num_trees = 7
for i in range(num_trees):
    x = random.randint(0, WIDTH)
    tree_index = i % len(tree_images)
    trees.append([x, tree_index])
tree_speed = 3

def update_parallax():
    for cloud in clouds:
        cloud[0] -= cloud_speed
        if cloud[0] < -190:
            cloud[0] = WIDTH
            cloud[1] = random.randint(20, 100)
            cloud[2] = random.randint(0, len(cloud_images) - 1)
    for tree in trees:
        tree[0] -= tree_speed
        if tree[0] < -tree_images[tree[1]].get_width():
            tree[0] = WIDTH

def draw_parallax():
    screen.fill(get_background_color())
    draw_ground()
    for cloud in clouds:
        cloud_index = cloud[2]
        screen.blit(cloud_images[cloud_index], (cloud[0], cloud[1]))
    for tree in trees:
        tree_index = tree[1]
        x = tree[0]
        y = GROUND_LEVEL - tree_images[tree_index].get_height() + 15
        screen.blit(tree_images[tree_index], (x, y))
    pygame.draw.line(screen, BLACK, (0, GROUND_LEVEL), (WIDTH, GROUND_LEVEL), 2)

# --------------------------
# Screen Drawing Functions
# --------------------------
def draw_menu():
    screen.fill(get_background_color())
    title_text = FONT.render("Enhanced Dino Game with Sprites", True, BLACK)
    start_text = FONT.render("Press S to Start", True, BLACK)
    hs_text = FONT.render("Press H to View High Scores", True, BLACK)
    quit_text = FONT.render("Press Q to Quit", True, BLACK)
    screen.blit(title_text, (WIDTH // 2 - title_text.get_width() // 2, 100))
    screen.blit(start_text, (WIDTH // 2 - start_text.get_width() // 2, 150))
    screen.blit(hs_text, (WIDTH // 2 - hs_text.get_width() // 2, 200))
    screen.blit(quit_text, (WIDTH // 2 - quit_text.get_width() // 2, 250))
    pygame.display.update()

def draw_high_scores_screen():
    screen.fill(get_background_color())
    title_text = FONT.render("High Scores", True, BLACK)
    screen.blit(title_text, (WIDTH // 2 - title_text.get_width() // 2, 50))
    if not high_scores:
        no_score_text = FONT.render("No high scores yet!", True, BLACK)
        screen.blit(no_score_text, (WIDTH // 2 - no_score_text.get_width() // 2, 100))
    else:
        for i, (name, sc) in enumerate(high_scores):
            score_text = FONT.render(f"{i + 1}. {name} - {sc}", True, BLACK)
            screen.blit(score_text, (WIDTH // 2 - score_text.get_width() // 2, 100 + i * 40))
    back_text = FONT.render("Press B to go back", True, BLACK)
    screen.blit(back_text, (WIDTH // 2 - back_text.get_width() // 2, 350))
    pygame.display.update()

def draw_pause_screen():
    pause_text = FONT.render("Paused. Press P to Resume", True, BLACK)
    screen.blit(pause_text, (WIDTH // 2 - pause_text.get_width() // 2, HEIGHT // 2 - pause_text.get_height() // 2))
    pygame.display.update()

def draw_gameover():
    screen.fill(get_background_color())
    gameover_text = FONT.render("Game Over!", True, BLACK)
    score_text = FONT.render("Your Score: " + str(score), True, BLACK)
    prompt_text = FONT.render("Press R to Restart or Q to Quit", True, BLACK)
    screen.blit(gameover_text, (WIDTH // 2 - gameover_text.get_width() // 2, 100))
    screen.blit(score_text, (WIDTH // 2 - score_text.get_width() // 2, 150))
    screen.blit(prompt_text, (WIDTH // 2 - prompt_text.get_width() // 2, 200))
    pygame.display.update()

def draw_enter_name():
    screen.fill(get_background_color())
    prompt_text = FONT.render("New High Score! Enter your name: " + player_name, True, BLACK)
    screen.blit(prompt_text, (50, HEIGHT // 2 - prompt_text.get_height() // 2))
    pygame.display.update()

def draw_game():
    draw_parallax()
    screen.blit(dino_frames[dino_frame_index], (dino_x, dino_y))
    
    obs = current_obstacle
    # Choose drawn dimensions based on obstacle type
    if obs["type"] == "cactus":
        drawn_width = cactus_draw_width
        drawn_height = cactus_draw_height
        sprite = cactus_sprite
    elif obs["type"] == "bush":
        drawn_width = bush_draw_width
        drawn_height = bush_draw_height
        sprite = bush_sprite
    elif obs["type"] == "bird":
        drawn_width = bird_draw_width
        drawn_height = bird_draw_height
        sprite = bird_sprite

    # Adjust draw_y so that the bottom of the drawn image aligns with the collision hit box bottom.
    draw_y = obs["y"] - (drawn_height - obs["height"])
    drawn_sprite = pygame.transform.scale(sprite, (drawn_width, drawn_height))
    screen.blit(drawn_sprite, (obs["x"], draw_y))
    
    score_text = FONT.render("Score: " + str(score), True, BLACK)
    screen.blit(score_text, (10, 10))
    pygame.display.update()

# --------------------------
# Main Game Loop
# --------------------------
running = True
while running:
    dt = clock.tick(FPS)
    
    if game_state == "menu":
        draw_menu()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_s:
                    dino_y = GROUND_LEVEL - dino_height + dino_offset
                    dino_velocity_y = 0
                    jump_count = 0
                    score = 0
                    current_obstacle = spawn_obstacle(0)
                    for cloud in clouds:
                        cloud[0] = random.randint(0, WIDTH)
                    for tree in trees:
                        tree[0] = random.randint(0, WIDTH)
                    game_state = "playing"
                elif event.key == pygame.K_q:
                    running = False
                elif event.key == pygame.K_h:
                    game_state = "high_scores"
                    
    elif game_state == "high_scores":
        draw_high_scores_screen()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_b:
                    game_state = "menu"
                    
    elif game_state == "playing":
        level = score // 5
        obstacle_speed = 5 + level
        current_gravity = base_gravity + level * 0.05
        
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:
                    game_state = "paused"
                if event.key == pygame.K_SPACE and jump_count < 2:
                    dino_velocity_y = base_jump_strength
                    jump_count += 1
        
        dino_anim_timer += dt
        if dino_anim_timer > dino_anim_delay:
            dino_frame_index = (dino_frame_index + 1) % len(dino_frames)
            dino_anim_timer = 0
        
        dino_y += dino_velocity_y
        dino_velocity_y += current_gravity
        
        if dino_y >= GROUND_LEVEL - dino_height + dino_offset:
            dino_y = GROUND_LEVEL - dino_height + dino_offset
            jump_count = 0
            dino_velocity_y = 0
        
        current_obstacle["x"] -= obstacle_speed
        if current_obstacle["x"] < -current_obstacle["width"]:
            score += 1
            current_obstacle = spawn_obstacle(score // 5)
        
        update_parallax()
        update_ground()
        
        dino_rect = pygame.Rect(dino_x, dino_y, dino_width, dino_height)
        obs = current_obstacle
        obs_rect = pygame.Rect(obs["x"], obs["y"], obs["width"], obs["height"])
        if dino_rect.colliderect(obs_rect):
            game_state = "gameover"
        
        draw_game()
        
    elif game_state == "paused":
        draw_game()
        draw_pause_screen()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:
                    game_state = "playing"
                    
    elif game_state == "gameover":
        draw_gameover()
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
        draw_enter_name()
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
