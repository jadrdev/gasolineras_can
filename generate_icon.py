#!/usr/bin/env python3
"""Genera un icono de app moderno para Gasolineras CAN."""

from PIL import Image, ImageDraw, ImageFilter, ImageChops

SIZE = 1024
RADIUS = int(SIZE * 0.22)  # esquinas redondeadas tipo iOS
CENTER = SIZE // 2
SUPERSAMPLE = 4  # factor anti-aliasing
SS_SIZE = SIZE * SUPERSAMPLE
SS_CENTER = SS_SIZE // 2

# Paleta: azul vibrante a cyan
TOP_COLOR = (10, 132, 255)      # #0A84FF
BOTTOM_COLOR = (0, 184, 212)    # #00B8D4


def linear_gradient(size, top, bottom):
    """Crea una imagen con degradado vertical."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    for y in range(size):
        ratio = y / (size - 1)
        r = int(top[0] * (1 - ratio) + bottom[0] * ratio)
        g = int(top[1] * (1 - ratio) + bottom[1] * ratio)
        b = int(top[2] * (1 - ratio) + bottom[2] * ratio)
        for x in range(size):
            img.putpixel((x, y), (r, g, b, 255))
    return img


def make_background():
    """Fondo con degradado completo (sin esquinas redondeadas para iOS)."""
    return linear_gradient(SIZE, TOP_COLOR, BOTTOM_COLOR)


def make_pump_shape(ss_size, scale, color, include_shadow=False, shadow_offset=(0, 0), shadow_blur=0, screen_transparent=False):
    """Genera la forma de la bomba en resolución supermuestreada."""
    img = Image.new("RGBA", (ss_size, ss_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    center = ss_size // 2
    sx, sy = shadow_offset
    sx *= SUPERSAMPLE
    sy *= SUPERSAMPLE
    sscale = scale * SUPERSAMPLE

    # Cuerpo principal de la bomba
    body_w = int(340 * sscale)
    body_h = int(420 * sscale)
    body_x = center - body_w // 2 + sx
    body_y = center - body_h // 2 + sy
    body_radius = int(60 * sscale)

    # Pantalla/display
    screen_w = int(220 * sscale)
    screen_h = int(110 * sscale)
    screen_x = body_x + (body_w - screen_w) // 2
    screen_y = body_y + int(40 * sscale)
    screen_radius = int(24 * sscale)

    # Base
    base_w = int(400 * sscale)
    base_h = int(50 * sscale)
    base_x = center - base_w // 2 + sx
    base_y = body_y + body_h - int(10 * sscale)
    base_radius = int(24 * sscale)

    # Manguera (curva bezier)
    hose_thick = int(32 * sscale)
    nozzle_w = int(60 * sscale)
    nozzle_h = int(110 * sscale)

    start_x = body_x + body_w - int(20 * sscale)
    start_y = body_y + int(130 * sscale)
    control_x = body_x + body_w + int(120 * sscale)
    control_y = body_y + int(180 * sscale)
    end_x = body_x + body_w + int(60 * sscale)
    end_y = body_y + int(360 * sscale)

    if include_shadow:
        shadow_color = color
        # Cuerpo y base
        draw.rounded_rectangle(
            (body_x, body_y, body_x + body_w, body_y + body_h),
            radius=body_radius, fill=shadow_color
        )
        draw.rounded_rectangle(
            (base_x, base_y, base_x + base_w, base_y + base_h),
            radius=base_radius, fill=shadow_color
        )
        # Manguera suavizada como círculos superpuestos
        points = []
        for t in range(0, 1001):
            t = t / 1000.0
            x = (1 - t) ** 2 * start_x + 2 * (1 - t) * t * control_x + t ** 2 * end_x
            y = (1 - t) ** 2 * start_y + 2 * (1 - t) * t * control_y + t ** 2 * end_y
            points.append((x, y))
        for x, y in points:
            draw.ellipse([
                x - hose_thick // 2, y - hose_thick // 2,
                x + hose_thick // 2, y + hose_thick // 2
            ], fill=shadow_color)
        # Pistola
        nozzle_x = end_x - nozzle_w // 2
        nozzle_y = end_y - int(10 * sscale)
        draw.rounded_rectangle(
            (nozzle_x, nozzle_y, nozzle_x + nozzle_w, nozzle_y + nozzle_h),
            radius=int(16 * sscale), fill=shadow_color
        )
        spout_x = nozzle_x + nozzle_w // 2 - int(12 * sscale)
        spout_y = nozzle_y - int(25 * sscale)
        spout_w = int(24 * sscale)
        spout_h = int(35 * sscale)
        draw.rounded_rectangle(
            (spout_x, spout_y, spout_x + spout_w, spout_y + spout_h),
            radius=int(8 * sscale), fill=shadow_color
        )
        img = img.filter(ImageFilter.GaussianBlur(radius=shadow_blur * SUPERSAMPLE))
        return img.resize((SIZE, SIZE), Image.Resampling.LANCZOS)

    # Cuerpo
    draw.rounded_rectangle(
        (body_x, body_y, body_x + body_w, body_y + body_h),
        radius=body_radius, fill=color
    )

    # Base
    draw.rounded_rectangle(
        (base_x, base_y, base_x + base_w, base_y + base_h),
        radius=base_radius, fill=color
    )

    # Manguera
    points = []
    for t in range(0, 1001):
        t = t / 1000.0
        x = (1 - t) ** 2 * start_x + 2 * (1 - t) * t * control_x + t ** 2 * end_x
        y = (1 - t) ** 2 * start_y + 2 * (1 - t) * t * control_y + t ** 2 * end_y
        points.append((x, y))
    for x, y in points:
        draw.ellipse([
            x - hose_thick // 2, y - hose_thick // 2,
            x + hose_thick // 2, y + hose_thick // 2
        ], fill=color)

    # Pistola
    nozzle_x = end_x - nozzle_w // 2
    nozzle_y = end_y - int(10 * sscale)
    draw.rounded_rectangle(
        (nozzle_x, nozzle_y, nozzle_x + nozzle_w, nozzle_y + nozzle_h),
        radius=int(16 * sscale), fill=color
    )
    spout_x = nozzle_x + nozzle_w // 2 - int(12 * sscale)
    spout_y = nozzle_y - int(25 * sscale)
    spout_w = int(24 * sscale)
    spout_h = int(35 * sscale)
    draw.rounded_rectangle(
        (spout_x, spout_y, spout_x + spout_w, spout_y + spout_h),
        radius=int(8 * sscale), fill=color
    )

    # Pantalla: si es transparente, cortar un agujero; si no, rellenar con TOP_COLOR
    if screen_transparent:
        # Máscara blanca en toda la imagen excepto la pantalla
        mask = Image.new("L", (ss_size, ss_size), 255)
        mdraw = ImageDraw.Draw(mask)
        mdraw.rounded_rectangle(
            (screen_x, screen_y, screen_x + screen_w, screen_y + screen_h),
            radius=screen_radius, fill=0
        )
        # Aplicar máscara al canal alfa de la imagen
        r, g, b, a = img.split()
        a = ImageChops.multiply(a, mask)
        img = Image.merge("RGBA", (r, g, b, a))
    else:
        draw.rounded_rectangle(
            (screen_x, screen_y, screen_x + screen_w, screen_y + screen_h),
            radius=screen_radius, fill=TOP_COLOR
        )

    return img.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def add_highlight(img):
    """Añade un reflejo sutil en la parte superior."""
    overlay = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 0))
    draw = ImageDraw.Draw(overlay)
    for y in range(0, RADIUS):
        alpha = int(40 * (1 - y / RADIUS))
        draw.line([(0, y), (SIZE, y)], fill=(255, 255, 255, alpha), width=1)
    return Image.alpha_composite(img, overlay)


def make_icon():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    # Fondo
    bg = make_background()
    img = Image.alpha_composite(img, bg)

    # Sombra suave del icono
    shadow = make_pump_shape(SS_SIZE, 1.0, (0, 0, 0, 80), include_shadow=True, shadow_offset=(10, 16), shadow_blur=16)
    img = Image.alpha_composite(img, shadow)

    # Icono blanco
    pump = make_pump_shape(SS_SIZE, 1.0, (255, 255, 255, 255), screen_transparent=False)
    img = Image.alpha_composite(img, pump)

    # Reflejo sutil
    img = add_highlight(img)

    return img


def make_adaptive_foreground():
    """Versión transparente del icono para Android adaptive."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shadow = make_pump_shape(SS_SIZE, 1.0, (0, 0, 0, 60), include_shadow=True, shadow_offset=(10, 16), shadow_blur=16, screen_transparent=True)
    img = Image.alpha_composite(img, shadow)
    pump = make_pump_shape(SS_SIZE, 1.0, (255, 255, 255, 255), screen_transparent=True)
    img = Image.alpha_composite(img, pump)
    return img


if __name__ == "__main__":
    icon = make_icon()
    icon.save("assets/icon/app_icon.png", "PNG")
    print("Icono principal guardado: assets/icon/app_icon.png")

    adaptive = make_adaptive_foreground()
    adaptive.save("assets/icon/app_icon_foreground.png", "PNG")
    print("Foreground adaptativo guardado: assets/icon/app_icon_foreground.png")
