"""Post diario «La gasolina más barata hoy» para redes (Facebook/Instagram).

Uso: python3 store/redes/generar_diario.py
Cada mañana a las 8:30 lo lanza una tarea de macOS (store/redes/instalar_diario.sh),
que deja el resultado en ~/GasoCan/posts/AAAA-MM-DD/ y avisa con una notificación.
Descarga los precios de hoy de la misma API que usa la app (api.precioil.es,
datos del Ministerio) y deja en store/redes/diario/AAAA-MM-DD/:
  precios.png   1080x1350 (4:5, feed de Instagram y Facebook)
  historia.png  1080x1920 (historias y estados de WhatsApp)
  texto.txt     texto listo para pegar, con el detalle y los enlaces

Por isla: la gasolinera más barata en Gasolina 95 y en Diésel. Solo cuenta
las de venta al público (tipoVenta P) y con precio comunicado en los
últimos 14 días: las gasolineras solo lo comunican cuando cambia, y en
La Gomera y El Hierro puede pasar casi una semana.
No publica nada: eso lo hace Joshua (o se programa en Meta Business Suite).
"""
import json
import os
import re
import sys
import urllib.request
from collections import defaultdict
from datetime import date, datetime, timedelta
from pathlib import Path

from PIL import Image, ImageDraw

RAIZ = Path(__file__).resolve().parent
# En el repo, generar_capturas.py está un nivel arriba; instalado (ver
# instalar_diario.sh) está al lado.
sys.path.insert(0, str(RAIZ.parent))
sys.path.insert(0, str(RAIZ))
import generar_capturas as g  # noqa: E402

API = (
    "https://api.precioil.es/estaciones/radio?latitud=28.5&longitud=-15.8"
    "&radio=300&limite=2000&pagina=1&fields=current"
)
ISLAS = [
    "Tenerife", "Gran Canaria", "Lanzarote", "Fuerteventura",
    "La Palma", "La Gomera", "El Hierro",
]
COMBUSTIBLES = [("Gasolina95", "Gasolina 95"), ("Diesel", "Diésel")]
APP_STORE = "https://apps.apple.com/es/app/id6832509598"
PLAY = "https://play.google.com/store/apps/details?id=com.jadrdev.gasolinera"
MESES = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
         "agosto", "septiembre", "octubre", "noviembre", "diciembre"]


def isla(lat, lng):
    """Las islas están bien separadas: basta con las coordenadas."""
    if lng < -17.7:
        return "El Hierro" if lat < 28.0 else "La Palma"
    if lng < -17.0:
        if lat > 28.4:
            return "La Palma"
        return "La Gomera"
    if lng < -16.0:
        return "Tenerife"
    if lng < -15.2:
        return "Gran Canaria"
    return "Lanzarote" if lat > 28.75 else "Fuerteventura"


def nombre_propio(texto):
    """«REPSOL» → «Repsol», «PALMAS DE GRAN CANARIA (LAS)» → «Las Palmas…»."""
    t = (texto or "").strip()
    if t.endswith(")") and "(" in t:  # «Orotava (La)» → «La Orotava»
        base, art = t[:-1].rsplit("(", 1)
        t = f"{art.strip()} {base.strip()}"
    # Sin la forma jurídica: «Del Valle Combustibles, S.L.» → «Del Valle Combustibles».
    t = re.sub(r",?\s+S\.?\s?[LA]\.?(\s?U\.?)?$", "", t, flags=re.I).strip()
    if t.isupper():
        t = " ".join(p.capitalize() if len(p) > 2 else p.lower() for p in t.split())
        t = t[0].upper() + t[1:]
    return t


def descargar():
    with urllib.request.urlopen(API, timeout=30) as r:
        return json.load(r)


def mas_baratas(estaciones, hoy):
    limite = hoy - timedelta(days=14)
    mejores = defaultdict(dict)
    for e in estaciones:
        if e.get("tipoVenta") not in (None, "P"):
            continue
        try:
            dia = datetime.strptime(e["lastUpdate"][:10], "%Y-%m-%d").date()
        except (KeyError, ValueError):
            continue
        if dia < limite:
            continue
        i = isla(e["latitud"], e["longitud"])
        for clave, _ in COMBUSTIBLES:
            precio = e.get(clave)
            if not precio:
                continue
            actual = mejores[i].get(clave)
            if actual is None or precio < actual["precio"]:
                mejores[i][clave] = {
                    "precio": precio,
                    "nombre": nombre_propio(e.get("nombreEstacion") or e.get("marca")),
                    "municipio": nombre_propio(e.get("nombreMunicipio")),
                }
    return mejores


def euros(p):
    return f"{p:.3f}".replace(".", ",") + " €"


def fecha_larga(d):
    return f"{d.day} de {MESES[d.month - 1]}"


def imagen(mejores, hoy, w, h):
    lienzo = g.fondo(w, h)
    d = ImageDraw.Draw(lienzo)
    blanco = (255, 255, 255)
    suave = (214, 232, 252)
    f_tit = g.fuente(66, "Bold")
    f_fecha = g.fuente(36, "Medium")
    f_isla = g.fuente(40, "Bold")
    f_comb = g.fuente(26, "Medium")
    f_precio = g.fuente(44, "Bold")
    f_sitio = g.fuente(25, "Regular")
    f_pie = g.fuente(30, "Medium")

    alto_extra = (h - 1350) // 2  # la historia es más alta: centra el bloque
    y = 70 + alto_extra
    for linea in ("La gasolina más", "barata hoy en Canarias"):
        d.text(((w - d.textlength(linea, font=f_tit)) / 2, y), linea, font=f_tit, fill=blanco)
        y += 76
    fecha = fecha_larga(hoy).capitalize()
    d.text(((w - d.textlength(fecha, font=f_fecha)) / 2, y + 6), fecha, font=f_fecha, fill=suave)
    y += 80

    fila = 132
    caja = (255, 255, 255)
    for nombre in ISLAS:
        datos = mejores.get(nombre, {})
        x0, x1 = 50, w - 50
        d.rounded_rectangle((x0, y, x1, y + fila - 14), radius=26, fill=caja)
        d.text((x0 + 28, y + 36), nombre, font=f_isla, fill=(20, 40, 70))
        col = 390
        for k, (clave, etiqueta) in enumerate(COMBUSTIBLES):
            cx = col + k * 330
            info = datos.get(clave)
            d.text((cx, y + 8), etiqueta, font=f_comb, fill=(90, 105, 130))
            if info:
                d.text((cx, y + 34), euros(info["precio"]), font=f_precio, fill=g.AZUL_OSCURO)
                sitio = info["municipio"]
                while d.textlength(sitio, font=f_sitio) > 300 and len(sitio) > 4:
                    sitio = sitio[:-2]
                if sitio != info["municipio"]:
                    sitio = sitio.rstrip() + "…"
                d.text((cx, y + 80), sitio, font=f_sitio, fill=(90, 105, 130))
            else:
                d.text((cx, y + 34), "—", font=f_precio, fill=(150, 160, 175))
        y += fila

    pie = "Todas las gasolineras, en la app GasoCan"
    d.text(((w - d.textlength(pie, font=f_pie)) / 2, y + 18), pie, font=f_pie, fill=blanco)
    return lienzo.convert("RGB")


def texto(mejores, hoy):
    lineas = [f"⛽ La gasolina más barata hoy en Canarias ({fecha_larga(hoy)})", ""]
    for nombre in ISLAS:
        datos = mejores.get(nombre)
        if not datos:
            continue
        partes = []
        for clave, etiqueta in COMBUSTIBLES:
            info = datos.get(clave)
            if info:
                partes.append(f"{etiqueta} {euros(info['precio'])} en {info['nombre']} ({info['municipio']})")
        lineas.append(f"📍 {nombre}: " + " · ".join(partes))
    lineas += [
        "",
        "Precios oficiales del Ministerio, actualizados cada día. Compruébalos siempre en el surtidor.",
        "",
        "Busca la más barata cerca de ti con GasoCan, gratis y sin anuncios:",
        f"🍎 {APP_STORE}",
        f"🤖 {PLAY}",
        "",
        "#Canarias #Tenerife #GranCanaria #Lanzarote #Fuerteventura #LaPalma #gasolina #ahorro",
    ]
    return "\n".join(lineas) + "\n"


def main():
    hoy = date.today()
    mejores = mas_baratas(descargar(), hoy)
    base = Path(os.environ.get("GASOCAN_DIARIO", RAIZ / "diario"))
    salida = base / hoy.isoformat()
    salida.mkdir(parents=True, exist_ok=True)
    imagen(mejores, hoy, 1080, 1350).save(salida / "precios.png", optimize=True)
    imagen(mejores, hoy, 1080, 1920).save(salida / "historia.png", optimize=True)
    (salida / "texto.txt").write_text(texto(mejores, hoy), encoding="utf-8")
    print(salida)


if __name__ == "__main__":
    main()
