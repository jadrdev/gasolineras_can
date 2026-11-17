"""Imágenes para redes del lanzamiento de coches eléctricos (noviembre 2026).

Uso: python3 store/redes/generar_redes.py
Reutiliza el estilo de store/generar_capturas.py con fondo verde (el color
de los puntos de carga en la app) y deja en store/redes/electricos/:
  post-cuadrado.png   1080x1080 (Instagram/Facebook/X)
  historia.png        1080x1920 (historias y estados)
  carrusel-1..3.png   1080x1350 (carrusel 4:5 de Instagram)
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent
sys.path.insert(0, str(RAIZ.parent))
import generar_capturas as g  # noqa: E402

g.AZUL = (14, 159, 110)
g.AZUL_OSCURO = (5, 92, 66)
PANT = RAIZ / "pantallas"
SALIDA = RAIZ / "electricos"


def cuadrado():
    w = h = 1080
    lienzo = g.fondo(w, h)
    d = ImageDraw.Draw(lienzo)
    f_tit = g.fuente(78, "Bold")
    f_sub = g.fuente(36, "Medium")
    y = 70
    for linea in ("GasoCan ya es para", "coches eléctricos"):
        tw = d.textlength(linea, font=f_tit)
        d.text(((w - tw) / 2, y), linea, font=f_tit, fill=(255, 255, 255))
        y += 88
    sub = "Puntos de recarga de Canarias, por precio"
    d.text(((w - d.textlength(sub, font=f_sub)) / 2, y + 14), sub, font=f_sub, fill=(214, 245, 232))
    # Dos móviles, cortados por abajo.
    for archivo, cx, top in (("01-rapida.png", 330, 345), ("03-calculadora.png", 750, 395)):
        tel = g.movil(Image.open(PANT / archivo), 380)
        tx = cx - tel.width // 2
        lienzo.alpha_composite(g.sombra(tel, 16, 26), (tx - 52, top - 52))
        lienzo.alpha_composite(tel, (tx, top))
    return lienzo.convert("RGB")


def main():
    SALIDA.mkdir(parents=True, exist_ok=True)
    cuadrado().save(SALIDA / "post-cuadrado.png", optimize=True)
    g.componer(PANT, "01-rapida.png", "Ahora también\npara eléctricos",
               "Elige «Eléctrico» y verás los cargadores de Canarias ordenados por precio",
               None, 1080, 1920).save(SALIDA / "historia.png", optimize=True)
    carrusel = [
        ("01-rapida.png", "Cargadores ordenados\npor precio", "Con su conector y su potencia"),
        ("02-mapa.png", "Todos los puntos\nde Canarias", "En el mapa, cerca de ti o en cualquier isla"),
        ("03b-calculadora.png", "Calcula cuánto\nte cuesta cargar", "Con el precio por kWh de cada punto"),
    ]
    for i, (archivo, tit, sub) in enumerate(carrusel, 1):
        g.componer(PANT, archivo, tit, sub, None, 1080, 1350).save(SALIDA / f"carrusel-{i}.png", optimize=True)
    for p in sorted(SALIDA.glob("*.png")):
        print(p.name, Image.open(p).size)


if __name__ == "__main__":
    main()
