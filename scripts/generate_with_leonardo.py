import os
import time
import requests
import subprocess

# ==============================================================================
# SCRIPT GENERATOR OTOMATIS LEONARDO.AI
# ==============================================================================
# Dapatkan API Key gratis di: https://app.leonardo.ai/api-access
# ==============================================================================

API_KEY = os.environ.get("LEONARDO_API_KEY", "")

# Daftar prompt aset yang BELUM ADA
MISSING_PROMPTS = {
    # 1. BOARD
    "board_base": "Isometric game board for Indonesian Monopoly board game, top-down 45-degree angle view, square board with 10 tiles on each side, lush green center area with Indonesian landmark illustrations (Monas tower, Borobudur temple, Komodo dragon, Raja Ampat ocean), warm colorful cartoon style, batik pattern border decoration, gold and red color scheme, high detail game board texture, vibrant tropical colors, clean game art style, white background, transparent background, 4K resolution",
    
    # 2. CORNER TILES
    "tile_go": "Isometric game tile for GO space in Indonesian Monopoly, cartoon style, bold red arrow pointing right with MULAI text in Indonesian, gold coin decorations, festive Indonesian batik border, 3D cartoon style, vibrant colors, white background, clean game asset style",
    "tile_jail": "Isometric game tile for jail/prison space, Indonesian cartoon style, cute cartoon jail bars with small character peeking through, blue color scheme, PENJARA text, playful not scary, Indonesian game art style, vibrant colors, white background",
    "tile_freeparking": "Isometric game tile for free parking, Indonesian cartoon style, cute warung street food stall with umbrella, relaxing tropical vibe, green color scheme, palm trees, PARKIR GRATIS text, warm colors, game asset style",
    "tile_gotojail": "Isometric game tile for Go to Jail space, Indonesian cartoon style, friendly police officer satpol PP pointing finger, red warning colors, KE PENJARA text, cute cartoon style, clean white background",

    # 3. MISSING PROPERTY
    "prop_asia_afrika": "Isometric cartoon illustration of Asia Afrika Street Bandung, historic colonial buildings, Gedung Merdeka Independence Hall in background, classic cars, flags, warm afternoon lighting, Indonesian game art style, cartoon isometric",

    # 4. BUILDINGS
    "house_2": "Small cute 3D isometric cluster of 2 Indonesian traditional houses with joglo roofs, green roofs, white walls, cartoon game art style, vibrant colors, transparent background",
    "house_3": "Small cute 3D isometric cluster of 3 Indonesian traditional houses, green roofs, white walls, cartoon game art style, vibrant colors, transparent background",

    # 5. DICE FACES
    "dice_face_1": "3D cartoon game dice face showing 1 dot in center, white dice with red dot, glossy rounded cube face, Indonesian batik motif, cartoon game art style, transparent background, high quality",
    "dice_face_2": "3D cartoon game dice face showing 2 dots, white dice with red dots, glossy rounded cube face, Indonesian batik motif, cartoon game art style, transparent background",
    "dice_face_3": "3D cartoon game dice face showing 3 dots, white dice with red dots, glossy rounded cube face, Indonesian batik motif, cartoon game art style, transparent background",
    "dice_face_4": "3D cartoon game dice face showing 4 dots, white dice with red dots, glossy rounded cube face, Indonesian batik motif, cartoon game art style, transparent background",
    "dice_face_5": "3D cartoon game dice face showing 5 dots, white dice with red dots, glossy rounded cube face, Indonesian batik motif, cartoon game art style, transparent background",
    "dice_complete_3d": "3D cartoon game dice isometric angle view, white glossy cube with red dots showing multiple sides, shiny reflective, cartoon game art style, transparent background",
    "dice_shadow": "Drop shadow for a 3D cartoon dice, oval soft dark transparent shadow for game piece",

    # 6. CHARACTERS
    "token_red_idle": "Cute cartoon game character, small adorable Komodo dragon standing upright, wearing red bandana and batik vest, confident pose, big expressive eyes, chubby cartoon style, transparent background",
    "token_red_walk": "Cute cartoon game character, small adorable Komodo dragon walking pose, red bandana, batik vest, animated frame cartoon style, transparent background",
    "token_red_celebrate": "Cute cartoon game character, small adorable Komodo dragon celebrating victory, jumping with joy, confetti, transparent background",

    "token_blue_idle": "Cute cartoon game character, small adorable Indonesian warrior pendekar with blue traditional headband ikat kepala, batik sarong, holding small keris dagger, transparent background",
    "token_blue_walk": "Cute cartoon game character, small Indonesian warrior walking pose, blue theme, transparent background",
    "token_blue_celebrate": "Cute cartoon game character, small Indonesian warrior celebrating victory, raising keris, transparent background",

    "token_green_idle": "Cute cartoon game character, small adorable Indonesian farmer wearing green traditional hat caping, batik shirt, holding small hoe, cheerful pose, transparent background",
    "token_green_walk": "Cute cartoon game character, small Indonesian farmer walking pose, green theme, transparent background",
    "token_green_celebrate": "Cute cartoon game character, small Indonesian farmer celebrating with harvest, transparent background",

    "token_yellow_idle": "Cute cartoon game character, small adorable Indonesian merchant saudagar wearing yellow songkok hat, batik outfit, holding money bag, transparent background",
    "token_yellow_walk": "Cute cartoon game character, small Indonesian merchant walking pose, yellow gold theme, transparent background",
    "token_yellow_celebrate": "Cute cartoon game character, small Indonesian merchant celebrating with gold coins raining, transparent background",

    # 7. BACKGROUND
    "bg_mountains_layer": "Wide panoramic Indonesian mountain silhouette for game background, volcano Merapi Bromo in misty purple-blue hues, tropical forest at base, 2D game background art, transparent top",

    # 8. PARTICLES
    "particle_star": "Single sparkle star particle for game effects, golden four-point star with glowing trails, cartoon style, transparent background",
    "particle_money_rain": "Single paper money bill particle IDR Rupiah, falling motion cartoon style, transparent background",
    "particle_confetti_red": "Single red and gold festive confetti ribbon particle, cartoon game VFX, transparent background",
    "particle_confetti_gold": "Single golden sparkling confetti particle, cartoon game VFX, transparent background",
    "particle_star_sparkle": "Single bright sparkle flare particle, glowing game asset, transparent background",

    # 9. UI ELEMENTS
    "money_stack": "Cute cartoon stack of Indonesian Rupiah bills IDR 100k notes with gold band, fan arrangement, transparent background",
    "bankruptcy_banner": "Game over banner for bankruptcy in Indonesian board game, dramatic BANGKRUT text, torn money effect, cartoon style, transparent background",
    "winner_crown": "Victory crown for winner in Indonesian board game, golden royal crown with garuda motif, sparkling gems, MENANG text, transparent background",
    "ui_money_panel": "HUD money display panel for Indonesian mobile game, dark glass card, gold border, batik pattern, premium mobile game UI",
    "onboarding_board": "Hero illustration of Indonesian Monopoly board game in 3D isometric view, landmarks visible, cartoon characters playing around board, vibrant colors",
    "onboarding_multiplayer": "Cartoon illustration of 4 diverse Indonesian friends playing board game together, laughing, cozy living room, warm lighting"
}

HEADERS = {
    "accept": "application/json",
    "content-type": "application/json",
    "authorization": f"Bearer {API_KEY}"
}

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "3d")
os.makedirs(OUT_DIR, exist_ok=True)

def generate_image(name, prompt):
    print(f"\n🎨 Requesting generation for: [{name}]...")
    
    url = "https://cloud.leonardo.ai/api/rest/v1/generations"
    payload = {
        "prompt": prompt + ", cartoon game asset style, vibrant colors, clean outline",
        "modelId": "e31634d7-5576-4788-b4b9-8739cf243640", # Leonardo Kino XL / Diffusion
        "width": 1024,
        "height": 1024,
        "num_images": 1,
        "transparency": "foreground_only" # Automatic background removal
    }
    
    res = requests.post(url, json=payload, headers=HEADERS)
    if res.status_code != 200:
        print(f"❌ Error request: {res.status_code} - {res.text}")
        return False
        
    gen_id = res.json().get("sdGenerationJob", {}).get("generationId")
    if not gen_id:
        print("❌ Gagal mendapatkan Generation ID")
        return False
        
    print(f"⏳ Menunggu rendering (ID: {gen_id})...")
    
    # Polling status
    check_url = f"https://cloud.leonardo.ai/api/rest/v1/generations/{gen_id}"
    for _ in range(30):
        time.sleep(4)
        check_res = requests.get(check_url, headers=HEADERS)
        if check_res.status_code == 200:
            data = check_res.json()
            status = data.get("generations_by_pk", {}).get("status")
            if status == "COMPLETE":
                images = data.get("generations_by_pk", {}).get("generated_images", [])
                if images:
                    img_url = images[0].get("url")
                    download_image(img_url, name)
                    return True
            elif status == "FAILED":
                print("❌ Generation failed on Leonardo server.")
                return False
                
    print("⚠️ Timeout menunggu hasil render.")
    return False

def download_image(url, name):
    dest = os.path.join(OUT_DIR, f"{name}.png")
    r = requests.get(url, stream=True)
    if r.status_code == 200:
        with open(dest, 'wb') as f:
            for chunk in r.iter_content(1024):
                f.write(chunk)
        print(f"✅ Berhasil di-download: 3d/{name}.png")
    else:
        print(f"❌ Gagal download gambar dari {url}")

def main():
    if not API_KEY:
        print("="*60)
        print("❌ API KEY BELUM DI-SET!")
        print("Silakan dapatkan API Key gratis di: https://app.leonardo.ai/api-access")
        print("Lalu jalankan script dengan:")
        print("  export LEONARDO_API_KEY='your_api_key_here'")
        print("  python3 scripts/generate_with_leonardo.py")
        print("="*60)
        return

    total = len(MISSING_PROMPTS)
    print(f"🚀 Memulai generate {total} aset via Leonardo.ai API...")
    
    success = 0
    for idx, (name, prompt) in enumerate(MISSING_PROMPTS.items(), 1):
        print(f"\n[{idx}/{total}] Processing: {name}")
        
        # Cek jika sudah pernah ada
        if os.path.exists(os.path.join(OUT_DIR, f"{name}.png")) or os.path.exists(os.path.join(OUT_DIR, f"{name}.jpg")):
            print(f"⏩ Sudah ada di folder 3d/, lewati...")
            continue
            
        if generate_image(name, prompt):
            success += 1
        time.sleep(2) # rate limit prevention

    print(f"\n🎉 Selesai! {success} gambar baru berhasil di-generate ke folder 3d/.")
    print("🔄 Menjalankan script konversi & resize otomatis...")
    subprocess.run(["bash", os.path.join(os.path.dirname(__file__), "process_assets.sh")])

if __name__ == "__main__":
    main()
