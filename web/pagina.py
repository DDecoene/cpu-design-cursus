"""Leest een stuk HTML van de site: kopjes, ids, links en de tekst per kopje (zonder code)."""
from html.parser import HTMLParser

KOPPEN = ("h1", "h2", "h3", "h4")


class Pagina(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.kopjes = []    # (niveau, id, titel)
        self.ids = set()
        self.links = []     # href van elke <a>
        self.secties = []   # {"id", "kop", "tekst"}: de tekst onder elk kopje
        self._kop = None    # (niveau, id, [tekststukken]) zolang we in een kop zitten
        self._code = 0
        self.geneste_links = 0   # <a> binnen een <a>: een browser splitst die en de tekst valt uit de link
        self._in_a = False
        self._sectie = {"id": "", "kop": "", "tekst": []}

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if "id" in a:
            self.ids.add(a["id"])
        if tag == "a":
            self.geneste_links += self._in_a
            self._in_a = True
            if "href" in a:
                self.links.append(a["href"])
        if tag == "pre":
            self._code += 1
        if tag in KOPPEN:
            self._kop = (int(tag[1]), a.get("id", ""), [])

    def handle_endtag(self, tag):
        if tag == "a":
            self._in_a = False
        if tag == "pre":
            self._code -= 1
        if tag in KOPPEN and self._kop:
            niveau, id_, delen = self._kop
            titel = "".join(delen).strip()
            self.kopjes.append((niveau, id_, titel))
            self._sluit()
            self._sectie = {"id": id_, "kop": titel, "tekst": []}
            self._kop = None

    def handle_data(self, data):
        if self._code:
            return
        (self._kop[2] if self._kop else self._sectie["tekst"]).append(data)

    def _sluit(self):
        tekst = " ".join("".join(self._sectie["tekst"]).split())
        if tekst or self._sectie["kop"]:
            self.secties.append({"id": self._sectie["id"], "kop": self._sectie["kop"], "tekst": tekst})

    def close(self):
        super().close()
        self._sluit()


def lees(html):
    p = Pagina()
    p.feed(html)
    p.close()
    return p
