import pygame
import random
import os
import math

pygame.init()

WIDTH, HEIGHT = 800, 400
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Dino Game with Finger Selection")
clock = pygame.time.Clock()
FPS = 60

BLACK = (0, 0, 0)
DAY_COLOR = (135, 206, 235)
NIGHT_COLOR = (20, 24, 82)
CYCLE_DURATION = 30000

def get_background_color():
    time_ms = pygame.time.get_ticks() % CYCLE_DURATION
    brightness = (math.sin(2 * math.pi * time_ms / CYCLE_DURATION - math.pi / 2) + 1) / 2
    return tuple(int(DAY_COLOR[i] * brightness + NIGHT_COLOR[i] * (1 - brightness)) for i in range(3))

FONT = pygame.font.SysFont(None, 30)
GROUND_LEVEL = 340
game_state = "menu"
score = 0
player_name = ""

jump_finger = "i"
double_jump_finger = "r"

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
dino_anim_delay = 200

dino_offset = 20
dino_x = 50
dino_y = GROUND_LEVEL - dino_height + dino_offset
dino_velocity_y = 0
base_jump_strength = -10
base_gravity = 0.5
jump_count = 0

try:
    cactus_sprite = pygame.image.load("cactus.png").convert_alpha()
except:
    cactus_sprite = pygame.Surface((20, 35))
    cactus_sprite.fill((150, 0, 0))
cactus_sprite = pygame.transform.scale(cactus_sprite, (20, 35))

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

def spawn_obstacle(level):
    if level < 2:
        obstacle_type = "cactus"
    else:
        obstacle_type = random.choice(["cactus", "bush", "bird"])
    if obstacle_type == "cactus":
        width = 14  
        height = 28  + level 
        x = WIDTH
        y = GROUND_LEVEL - height + 40
    elif obstacle_type == "bush":
        width = 30
        height = 20
        x = WIDTH
        y = GROUND_LEVEL - height + 40
    elif obstacle_type == "bird":
        width = 30
        height = 20
        x = WIDTH
        y = random.randint(150, 250) + 40
    return {"type": obstacle_type, "x": x, "y": y, "width": width, "height": height}

current_obstacle = spawn_obstacle(0)

try:
    sand_texture = pygame.image.load("sand.png").convert_alpha()
except:
    sand_texture = pygame.Surface((50, 50))
    sand_texture.fill((194, 178, 128))

tree_images = []
for i in range(1, 5):
    try:
        img = pygame.image.load(f"tree{i}.png").convert_alpha()
    except:
        img = pygame.Surface((50, 100))
        img.fill((34, 139, 34))
    img = pygame.transform.scale(img, (100, int(img.get_height() * 100 / img.get_width())))
    tree_images.append(img)

cloud_images = []
for name in ["cloud1.png", "cloud2.png", "cloud3.png"]:
    try:
        img = pygame.image.load(name).convert_alpha()
        img = pygame.transform.scale(img, (190, 120))
    except:
        img = pygame.Surface((190, 120))
        img.fill((200, 200, 200))
    cloud_images.append(img)

sand_offset = 0
sand_speed = 2

def draw_ground():
    sw, sh = sand_texture.get_size()
    for x in range(-sand_offset, WIDTH, sw):
        for y in range(GROUND_LEVEL, HEIGHT, sh):
            screen.blit(sand_texture, (x, y))

def update_ground():
    global sand_offset
    sw = sand_texture.get_width()
    sand_offset += sand_speed
    if sand_offset >= sw:
        sand_offset -= sw

clouds = [[random.randint(0, WIDTH), random.randint(20, 100), random.randint(0, 2)] for _ in range(5)]
trees = [[random.randint(0, WIDTH), i % 4] for i in range(7)]

def update_parallax():
    for cloud in clouds:
        cloud[0] -= 1
        if cloud[0] < -190:
            cloud[0] = WIDTH
            cloud[1] = random.randint(20, 100)
            cloud[2] = random.randint(0, 2)
    for tree in trees:
        tree[0] -= 3
        if tree[0] < -100:
            tree[0] = WIDTH

def draw_parallax():
    screen.fill(get_background_color())
    draw_ground()
    for x, y, idx in clouds:
        screen.blit(cloud_images[idx], (x, y))
    for x, idx in trees:
        y = GROUND_LEVEL - tree_images[idx].get_height() + 15
        screen.blit(tree_images[idx], (x, y))

def draw_game():
    draw_parallax()
    screen.blit(dino_frames[dino_frame_index], (dino_x, dino_y))

    obs = current_obstacle
    # Choose drawn dimensions based on obstacle type
    if obs["type"] == "cactus":
        drawn_width = 100
        drawn_height = 100
        sprite = cactus_sprite
    elif obs["type"] == "bush":
        drawn_width = 60
        drawn_height = 40
        sprite = bush_sprite
    elif obs["type"] == "bird":
        drawn_width = 60
        drawn_height = 40
        sprite = bird_sprite

    # Adjust Y so the sprite's bottom matches the collision box
    draw_y = obs["y"] - (drawn_height - obs["height"])
    scaled_sprite = pygame.transform.scale(sprite, (drawn_width, drawn_height))
    screen.blit(scaled_sprite, (obs["x"], draw_y))

    score_text = FONT.render("Score: " + str(score), True, BLACK)
    screen.blit(score_text, (10, 10))
    pygame.display.update()


def read_finger_from_file():
    try:
        with open("finger_log.txt", "r+") as f:
            value = f.read().strip()
            f.seek(0)
            f.truncate()
            return value
    except:
        return ""

running = True
while running:
    dt = clock.tick(FPS)
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    if game_state == "menu":
        screen.fill(get_background_color())
        title = FONT.render("Dino Game with Sprites", True, BLACK)
        start = FONT.render("Press S to Start", True, BLACK)
        hs = FONT.render("Press H for High Scores", True, BLACK)
        inp = FONT.render("Press F to Set Finger Inputs", True, BLACK)
        quit = FONT.render("Press Q to Quit", True, BLACK)
        screen.blit(title, (WIDTH//2 - title.get_width()//2, 100))
        screen.blit(start, (WIDTH//2 - start.get_width()//2, 150))
        screen.blit(hs, (WIDTH//2 - hs.get_width()//2, 180))
        screen.blit(inp, (WIDTH//2 - inp.get_width()//2, 210))
        screen.blit(quit, (WIDTH//2 - quit.get_width()//2, 240))
        pygame.display.update()
        keys = pygame.key.get_pressed()
        if keys[pygame.K_s]:
            dino_y = GROUND_LEVEL - dino_height + dino_offset
            dino_velocity_y = 0
            jump_count = 0
            score = 0
            current_obstacle = spawn_obstacle(0)
            game_state = "playing"
        elif keys[pygame.K_h]:
            game_state = "high_scores"
        elif keys[pygame.K_f]:
            game_state = "input_select"
        elif keys[pygame.K_q]:
            running = False
            
    elif game_state == "input_select":
        jump_selected = False
        double_selected = False
        selected_jump = ""
        selected_double = ""
        selecting = True

        while selecting:
            screen.fill(get_background_color())

            if not jump_selected:
                title = FONT.render("Choose JUMP finger (p, r, m, i):", True, BLACK)
                screen.blit(title, (WIDTH//2 - title.get_width()//2, 120))
                if selected_jump:
                    chosen = FONT.render(f"Selected: {selected_jump.upper()}", True, BLACK)
                    screen.blit(chosen, (WIDTH//2 - chosen.get_width()//2, 160))
                    enter_prompt = FONT.render("Press ENTER to confirm", True, BLACK)
                    screen.blit(enter_prompt, (WIDTH//2 - enter_prompt.get_width()//2, 200))
            elif not double_selected:
                title = FONT.render("Choose DOUBLE JUMP finger (p, r, m, i):", True, BLACK)
                screen.blit(title, (WIDTH//2 - title.get_width()//2, 120))
                if selected_double:
                    chosen = FONT.render(f"Selected: {selected_double.upper()}", True, BLACK)
                    screen.blit(chosen, (WIDTH//2 - chosen.get_width()//2, 160))
                    enter_prompt = FONT.render("Press ENTER to confirm", True, BLACK)
                    screen.blit(enter_prompt, (WIDTH//2 - enter_prompt.get_width()//2, 200))

            pygame.display.update()

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    selecting = False
                    running = False

                if event.type == pygame.KEYDOWN:
                    key = event.unicode.lower()

                    if not jump_selected:
                        if key in ["p", "r", "m", "i"]:
                            selected_jump = key
                        elif event.key == pygame.K_RETURN and selected_jump:
                            jump_finger = selected_jump
                            jump_selected = True
                            selected_jump = ""
                    elif not double_selected:
                        if key in ["p", "r", "m", "i"]:
                            selected_double = key
                        elif event.key == pygame.K_RETURN and selected_double:
                            double_jump_finger = selected_double
                            double_selected = True
                            selecting = False
                            game_state = "menu"

    elif game_state == "high_scores":
        screen.fill(get_background_color())
        title = FONT.render("High Scores", True, BLACK)
        screen.blit(title, (WIDTH//2 - title.get_width()//2, 50))
        if not high_scores:
            txt = FONT.render("No scores yet", True, BLACK)
            screen.blit(txt, (WIDTH//2 - txt.get_width()//2, 100))
        else:
            for i, (name, sc) in enumerate(high_scores):
                txt = FONT.render(f"{i+1}. {name} - {sc}", True, BLACK)
                screen.blit(txt, (WIDTH//2 - txt.get_width()//2, 90 + i * 30))
        back = FONT.render("Press B to go back", True, BLACK)
        screen.blit(back, (WIDTH//2 - back.get_width()//2, 350))
        pygame.display.update()
        keys = pygame.key.get_pressed()
        if keys[pygame.K_b]:
            game_state = "menu"

    elif game_state == "playing":
        level = score // 5
        obstacle_speed = 5 + level
        gravity = base_gravity + level * 0.05

        keys = pygame.key.get_pressed()
        if keys[pygame.K_p]:
            game_state = "menu"

        finger = read_finger_from_file().lower()
        if finger == jump_finger and jump_count == 0:
            dino_velocity_y = base_jump_strength
            jump_count += 1
        elif finger == double_jump_finger and jump_count == 1:
            dino_velocity_y = base_jump_strength
            jump_count += 1
        if keys[pygame.K_SPACE] and jump_count < 2:
            dino_velocity_y = base_jump_strength
            jump_count += 1

        dino_anim_timer += dt
        if dino_anim_timer > dino_anim_delay:
            dino_frame_index = (dino_frame_index + 1) % len(dino_frames)
            dino_anim_timer = 0

        dino_y += dino_velocity_y
        dino_velocity_y += gravity
        if dino_y >= GROUND_LEVEL - dino_height + dino_offset:
            dino_y = GROUND_LEVEL - dino_height + dino_offset
            dino_velocity_y = 0
            jump_count = 0

        current_obstacle["x"] -= obstacle_speed
        if current_obstacle["x"] < -current_obstacle["width"]:
            score += 1
            current_obstacle = spawn_obstacle(score // 5)

        dino_rect = pygame.Rect(dino_x, dino_y, dino_width, dino_height)
        obs_rect = pygame.Rect(current_obstacle["x"], current_obstacle["y"], current_obstacle["width"], current_obstacle["height"])
        if dino_rect.colliderect(obs_rect):
            game_state = "menu"

        update_parallax()
        update_ground()
        draw_game()

pygame.quit()
