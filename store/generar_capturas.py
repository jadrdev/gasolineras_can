"""Capturas de tienda con título y marco de móvil.

Uso: python3 store/generar_capturas.py
Lee las pantallas reales de store/pantallas/ (simulador iPhone 6,9") y genera:
  store/marketing/app-store-6.9/  (1320x2868, iPhone 6,9")
  store/marketing/app-store-6.3/  (1206x2622, iPhone 6,3")
  store/marketing/google-play/    (1080x2160, máximo 2:1 que admite Play)
  store/marketing/google-play-tablet/ (1080x1920, 9:16 para tablets de 7" y 10")
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAIZ = Path(__file__).resolve().parent
PANTALLAS = RAIZ / "pantallas"
ICONO = RAIZ.parent / "assets" / "icon" / "app_icon.png"
SALIDA = RAIZ / "marketing"
FUENTE = "/System/Library/Fonts/SFNS.ttf"
EMOJI = "/System/Library/Fonts/Apple Color Emoji.ttc"

AZUL = (8, 123, 232)
AZUL_OSCURO = (4, 70, 150)

CAPTURAS = [
    ("01-lista.png", "Encuentra la gasolina\nmás barata", "Precios de hoy, ordenados de menor a mayor", None),
    ("03-mapa.png", "Todas las gasolineras\nde Canarias", "En el mapa, cerca de ti o en cualquier isla", None),
    ("02-detalle.png", "Calcula cuánto pagas\ny cuánto ahorras", "Con los litros de tu depósito", None),
    (
        "01-lista.png",
        "Te avisamos cuando\nbaje el precio",
        "En tus gasolineras favoritas",
        ("⛽ ¡Bajó el precio!", "E.S. Océano Santa Cruz (Santa Cruz de Tenerife): Gasolina 95 a 1,360 €/L (bajó 0,025 €)"),
    ),
    ("04-oscuro.png", "También en\nmodo oscuro", "Se adapta a tu iPhone", None),
]

SALIDAS = {
    "app-store-6.9": (1320, 2868),
    "app-store-6.3": (1206, 2622),
    "google-play": (1080, 2160),
    "google-play-tablet": (1080, 1920),
}


def fuente(tam, peso="Bold"):
    f = ImageFont.truetype(FUENTE, tam)
    f.set_variation_by_name(peso)
    return f


def fondo(w, h):
    img = Image.new("RGB", (w, h), AZUL)
    px = img.load()
    for y in range(h):
        t = y / h
        c = tuple(round(AZUL[i] + (AZUL_OSCURO[i] - AZUL[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = c
    # Un par de círculos suaves para que no sea plano.
    capa = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(capa)
    d.ellipse((-w * 0.35, h * 0.30, w * 0.55, h * 0.30 + w * 0.9), fill=(255, 255, 255, 18))
    d.ellipse((w * 0.55, -w * 0.25, w * 1.35, w * 0.55), fill=(255, 255, 255, 14))
    return Image.alpha_composite(img.convert("RGBA"), capa)


def esquinas(img, radio):
    mascara = Image.new("L", img.size, 0)
    ImageDraw.Draw(mascara).rounded_rectangle((0, 0, *img.size), radio, fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mascara)
    return out


def movil(pantalla, ancho):
    """Pantalla real dentro de un marco negro con isla dinámica."""
    escala = ancho / pantalla.width
    pant = pantalla.convert("RGBA").resize((ancho, round(pantalla.height * escala)), Image.LANCZOS)
    radio = round(ancho * 0.115)
    pant = esquinas(pant, radio)
    borde = round(ancho * 0.028)
    w, h = pant.width + borde * 2, pant.height + borde * 2
    marco = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(marco)
    d.rounded_rectangle((0, 0, w - 1, h - 1), radio + borde, fill=(18, 18, 20, 255))
    d.rounded_rectangle((2, 2, w - 3, h - 3), radio + borde - 2, outline=(70, 70, 75, 255), width=3)
    marco.alpha_composite(pant, (borde, borde))
    # Isla dinámica.
    iw, ih = round(ancho * 0.30), round(ancho * 0.085)
    ix, iy = (w - iw) // 2, borde + round(ancho * 0.03)
    d = ImageDraw.Draw(marco)
    d.rounded_rectangle((ix, iy, ix + iw, iy + ih), ih // 2, fill=(0, 0, 0, 255))
    return marco


def sombra(img, desp, difuminado, opacidad=90):
    s = Image.new("RGBA", (img.width + difuminado * 4, img.height + difuminado * 4), (0, 0, 0, 0))
    alfa = img.split()[3].point(lambda a: opacidad if a else 0)
    s.paste((0, 0, 0, 255), (difuminado * 2, difuminado * 2 + desp), alfa)
    return s.filter(ImageFilter.GaussianBlur(difuminado))


def envolver(texto, f, ancho, draw):
    lineas, actual = [], ""
    for palabra in texto.split():
        prueba = f"{actual} {palabra}".strip()
        if draw.textlength(prueba, font=f) <= ancho:
            actual = prueba
        else:
            lineas.append(actual)
            actual = palabra
    lineas.append(actual)
    return lineas


def notificacion(ancho, titulo, cuerpo):
    """Banner de notificación de iOS (claro)."""
    pad = round(ancho * 0.045)
    icono_t = round(ancho * 0.095)
    f_app = fuente(round(ancho * 0.032), "Semibold")
    f_tit = fuente(round(ancho * 0.040), "Semibold")
    f_cue = fuente(round(ancho * 0.037), "Regular")
    tmp = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    texto_x = pad + icono_t + round(pad * 0.7)
    texto_w = ancho - texto_x - pad
    lineas = envolver(cuerpo, f_cue, texto_w, tmp)[:3]
    alto_linea = round(f_cue.size * 1.28)
    alto = pad + f_tit.size + round(pad * 0.3) + alto_linea * len(lineas) + pad
    banner = Image.new("RGBA", (ancho, alto), (0, 0, 0, 0))
    d = ImageDraw.Draw(banner)
    d.rounded_rectangle((0, 0, ancho - 1, alto - 1), round(ancho * 0.065), fill=(246, 246, 248, 250))
    icono = Image.open(ICONO).convert("RGBA").resize((icono_t, icono_t), Image.LANCZOS)
    banner.alpha_composite(esquinas(icono, round(icono_t * 0.23)), (pad, (alto - icono_t) // 2))
    y = pad - round(f_tit.size * 0.12)
    x = texto_x
    if titulo.startswith("⛽"):
        # El emoji va con la fuente de color de Apple (solo existe a 160 px).
        emoji = Image.new("RGBA", (180, 180), (0, 0, 0, 0))
        ImageDraw.Draw(emoji).text((0, 0), "⛽", font=ImageFont.truetype(EMOJI, 160), embedded_color=True)
        emoji = emoji.crop(emoji.getbbox()).resize((round(f_tit.size * 1.05),) * 2, Image.LANCZOS)
        banner.alpha_composite(emoji, (x, y + round(f_tit.size * 0.12)))
        x += emoji.width + round(f_tit.size * 0.3)
        titulo = titulo[1:].strip()
    d.text((x, y), titulo, font=f_tit, fill=(0, 0, 0))
    ahora = "ahora"
    d.text((ancho - pad - d.textlength(ahora, font=f_app), y + 4), ahora, font=f_app, fill=(130, 130, 136))
    y += f_tit.size + round(pad * 0.3)
    for linea in lineas:
        d.text((texto_x, y), linea, font=f_cue, fill=(30, 30, 32))
        y += alto_linea
    return banner


def componer(archivo, titulo, subtitulo, aviso, w, h):
    lienzo = fondo(w, h)
    d = ImageDraw.Draw(lienzo)
    margen = round(w * 0.07)
    f_tit = fuente(round(w * 0.085), "Bold")
    f_sub = fuente(round(w * 0.040), "Medium")
    y = round(h * 0.065)
    for linea in titulo.split("\n"):
        tw = d.textlength(linea, font=f_tit)
        d.text(((w - tw) / 2, y), linea, font=f_tit, fill=(255, 255, 255))
        y += round(f_tit.size * 1.12)
    y += round(f_sub.size * 0.5)
    for linea in envolver(subtitulo, f_sub, w - margen * 2, d):
        tw = d.textlength(linea, font=f_sub)
        d.text(((w - tw) / 2, y), linea, font=f_sub, fill=(220, 236, 255))
        y += round(f_sub.size * 1.3)

    tel = movil(Image.open(PANTALLAS / archivo), round(w * 0.78))
    tx = (w - tel.width) // 2
    ty = y + round(h * 0.035)
    sm = sombra(tel, round(w * 0.02), round(w * 0.03))
    lienzo.alpha_composite(sm, (tx - round(w * 0.06), ty - round(w * 0.06)))
    lienzo.alpha_composite(tel, (tx, ty))

    if aviso:
        banner = notificacion(round(w * 0.86), *aviso)
        bx = (w - banner.width) // 2
        by = ty + round(tel.height * 0.20)
        lienzo.alpha_composite(sombra(banner, round(w * 0.012), round(w * 0.025), 110), (bx - round(w * 0.05), by - round(w * 0.05)))
        lienzo.alpha_composite(banner, (bx, by))
    return lienzo.convert("RGB")


def grafico_destacado():
    """Gráfico destacado de Google Play (1024x500)."""
    w, h = 1024, 500
    lienzo = fondo(w, h)
    d = ImageDraw.Draw(lienzo)
    # Icono y textos a la izquierda.
    x = 64
    icono_t = 120
    icono = Image.open(ICONO).convert("RGBA").resize((icono_t, icono_t), Image.LANCZOS)
    iy = 92
    lienzo.alpha_composite(sombra(esquinas(icono, 27), 6, 10, 80), (x - 20, iy - 20))
    lienzo.alpha_composite(esquinas(icono, 27), (x, iy))
    y = iy + icono_t + 30
    f_nom = fuente(50, "Bold")
    for linea in ("Gasolineras", "de Canarias"):
        d.text((x, y), linea, font=f_nom, fill=(255, 255, 255))
        y += 58
    y += 14
    d.text((x, y), "La gasolina más barata cerca de ti", font=fuente(26, "Medium"), fill=(220, 236, 255))
    # Móvil a la derecha, cortado por abajo.
    tel = movil(Image.open(PANTALLAS / "01-lista.png"), 300)
    tx, ty = w - tel.width - 70, 48
    lienzo.alpha_composite(sombra(tel, 8, 14), (tx - 28, ty - 28))
    lienzo.alpha_composite(tel, (tx, ty))
    destino = SALIDA / "google-play" / "grafico-destacado.png"
    lienzo.convert("RGB").save(destino, optimize=True)
    print(destino, (w, h))


def main():
    grafico_destacado()
    for carpeta, (w, h) in SALIDAS.items():
        destino = SALIDA / carpeta
        destino.mkdir(parents=True, exist_ok=True)
        for i, (archivo, titulo, subtitulo, aviso) in enumerate(CAPTURAS, 1):
            if carpeta.startswith("google-play"):
                subtitulo = subtitulo.replace("tu iPhone", "tu móvil")
            img = componer(archivo, titulo, subtitulo, aviso, w, h)
            nombre = f"{i:02d}-{Path(archivo).stem.split('-', 1)[1]}{'-aviso' if aviso else ''}.png"
            img.save(destino / nombre, optimize=True)
            print(destino / nombre, img.size)


if __name__ == "__main__":
    main()
