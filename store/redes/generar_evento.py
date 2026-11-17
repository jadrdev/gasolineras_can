"""Imágenes del evento dentro de la app de Apple «Puntos de recarga en Canarias».

Uso: python3 store/redes/generar_evento.py
Deja en store/redes/evento/:
  tarjeta.png   1920x1080 (tarjeta del evento, 16:9)
  ficha.png     1080x1920 (página de detalles del evento, 9:16)

Sin texto a propósito: el App Store pinta encima el nombre y la descripción
del evento abajo a la izquierda, así que esa zona se deja despejada.
"""
import sys
from pathlib import Path

from PIL import Image

RAIZ = Path(__file__).resolve().parent
sys.path.insert(0, str(RAIZ.parent))
import generar_capturas as g  # noqa: E402

g.AZUL = (14, 159, 110)
g.AZUL_OSCURO = (5, 92, 66)
PANT = RAIZ / "pantallas"
SALIDA = RAIZ / "evento"


def poner(lienzo, archivo, ancho, cx, top):
    tel = g.movil(Image.open(PANT / archivo), ancho)
    tx = cx - tel.width // 2
    lienzo.alpha_composite(g.sombra(tel, 18, 30), (tx - 60, top - 60))
    lienzo.alpha_composite(tel, (tx, top))


def tarjeta():
    # Móviles a la derecha y arriba; abajo a la izquierda va el texto de Apple.
    w, h = 1920, 1080
    lienzo = g.fondo(w, h)
    poner(lienzo, "02-mapa.png", 400, 1080, 170)
    poner(lienzo, "03-calculadora.png", 400, 1660, 170)
    poner(lienzo, "01-rapida.png", 460, 1370, 80)
    return lienzo.convert("RGB")


def ficha():
    # Un móvil en la parte de arriba; el tercio de abajo, despejado.
    w, h = 1080, 1920
    lienzo = g.fondo(w, h)
    poner(lienzo, "01-rapida.png", 620, w // 2, 150)
    return lienzo.convert("RGB")


def main():
    SALIDA.mkdir(parents=True, exist_ok=True)
    tarjeta().save(SALIDA / "tarjeta.png", optimize=True)
    ficha().save(SALIDA / "ficha.png", optimize=True)
    for p in sorted(SALIDA.glob("*.png")):
        print(p.name, Image.open(p).size)


if __name__ == "__main__":
    main()
