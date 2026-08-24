#!/usr/bin/env python3
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "playstore" / "assets"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Verdana Bold.ttf"
FONT_REGULAR = "/System/Library/Fonts/Supplemental/Verdana.ttf"


def cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    target_ratio = size[0] / size[1]
    source_ratio = image.width / image.height
    if source_ratio > target_ratio:
        width = round(image.height * target_ratio)
        left = (image.width - width) // 2
        image = image.crop((left, 0, left + width, image.height))
    else:
        height = round(image.width / target_ratio)
        top = (image.height - height) // 2
        image = image.crop((0, top, image.width, top + height))
    return image.resize(size, Image.Resampling.LANCZOS)


def app_icon() -> Image.Image:
    target = OUT / "app-icon-512.png"
    icon = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    draw = ImageDraw.Draw(icon)
    draw.ellipse((16, 16, 496, 496), fill="#b71c1c", outline="#ffd54f", width=10)
    draw.ellipse((38, 38, 474, 474), outline=(255, 213, 79, 130), width=4)
    draw.rounded_rectangle((142, 112, 242, 212), radius=18, fill="white")
    draw.rounded_rectangle((270, 112, 370, 212), radius=18, fill="white")

    def pip(x: int, y: int, r: int = 10) -> None:
        draw.ellipse((x - r, y - r, x + r, y + r), fill="#212121")

    pip(192, 162, 13)
    for x in (295, 345):
        for y in (137, 162, 187):
            pip(x, y, 8)

    gold = "#ffc928"
    buildings = [
        (142, 278, 188, 366),
        (198, 248, 258, 366),
        (270, 290, 314, 366),
        (324, 266, 380, 366),
    ]
    for building in buildings:
        draw.rounded_rectangle(building, radius=5, fill=gold)
    draw.polygon(((256, 220), (276, 252), (236, 252)), fill=gold)

    title = ImageFont.truetype(FONT_BOLD, 43)
    subtitle = ImageFont.truetype(FONT_BOLD, 21)
    draw.text((256, 394), "MONOPOLI", font=title, fill=gold, anchor="mm")
    draw.text((256, 438), "INDONESIA", font=subtitle, fill="white", anchor="mm")
    icon.save(target, optimize=True)
    return icon


def launcher_icons(icon: Image.Image) -> None:
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in sizes.items():
        target = (
            ROOT
            / "android"
            / "app"
            / "src"
            / "main"
            / "res"
            / folder
            / "ic_launcher.png"
        )
        target.parent.mkdir(parents=True, exist_ok=True)
        icon.resize((size, size), Image.Resampling.LANCZOS).save(
            target, optimize=True
        )


def feature_graphic(source: Path) -> None:
    image = cover(Image.open(source).convert("RGB"), (1024, 500))
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    draw.rounded_rectangle(
        (45, 88, 490, 412),
        radius=32,
        fill=(13, 71, 116, 205),
        outline=(255, 213, 79, 220),
        width=4,
    )
    title = ImageFont.truetype(FONT_BOLD, 60)
    subtitle = ImageFont.truetype(FONT_BOLD, 24)
    small = ImageFont.truetype(FONT_REGULAR, 20)
    draw.text(
        (76, 126),
        "MONOPOLI",
        font=title,
        fill=(255, 213, 79, 255),
        stroke_width=2,
        stroke_fill=(95, 22, 22, 255),
    )
    draw.text(
        (78, 199),
        "INDONESIA",
        font=title,
        fill=(255, 255, 255, 255),
        stroke_width=2,
        stroke_fill=(95, 22, 22, 255),
    )
    draw.text(
        (80, 295),
        "Jelajahi Nusantara",
        font=subtitle,
        fill=(255, 255, 255, 255),
    )
    draw.text(
        (80, 335),
        "Bangun properti. Kuasai kota.",
        font=small,
        fill=(225, 245, 254, 255),
    )
    Image.alpha_composite(image.convert("RGBA"), overlay).convert("RGB").save(
        OUT / "feature-graphic-1024x500.jpg",
        quality=94,
        optimize=True,
    )


def screenshot(raw: Path, target_name: str, title: str, subtitle: str) -> None:
    captured = cover(Image.open(raw).convert("RGB"), (1080, 1920))
    canvas = Image.new("RGB", (1080, 1920), "#0d4774")
    canvas.paste(captured.resize((972, 1728), Image.Resampling.LANCZOS), (54, 146))
    draw = ImageDraw.Draw(canvas)
    title_font = ImageFont.truetype(FONT_BOLD, 45)
    sub_font = ImageFont.truetype(FONT_REGULAR, 24)
    draw.text((54, 35), title, font=title_font, fill="#ffd54f")
    draw.text((56, 94), subtitle, font=sub_font, fill="white")
    canvas.save(OUT / target_name, quality=95, optimize=True)


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("Usage: prepare_playstore_assets.py FEATURE_SOURCE [RAW_DIR]")
    OUT.mkdir(parents=True, exist_ok=True)
    icon = app_icon()
    launcher_icons(icon)
    feature_graphic(Path(sys.argv[1]))

    if len(sys.argv) > 2:
        raw = Path(sys.argv[2])
        screenshot(
            raw / "game.png",
            "phone-01-gameplay-1080x1920.jpg",
            "Papan Indonesia",
            "Beli properti dan kelola kekayaanmu",
        )
        screenshot(
            raw / "home.png",
            "phone-02-modes-1080x1920.jpg",
            "Main Bersama",
            "Mode lokal dan multiplayer online",
        )
        screenshot(
            raw / "join.png",
            "phone-03-room-1080x1920.jpg",
            "Gabung Room",
            "Masuk dengan kode dan mulai bermain",
        )


if __name__ == "__main__":
    main()
