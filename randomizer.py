# Lista/array delle persone che partecipano all'estrazione
fortunati_vincitori= ["Alessandro Alvisi","Alessia Urru","Alessio Pedrotti","Alice Innocenti","Brayan Peña Velasquez","Christine Nicole Castillo Rivera","Clair Goncalves Ramalho","Claudia Rivelli","Dimitri Papadoulis","Giorgio Bettini","Giuditta Coffari di Gilferraro","Giulia Marchesi","Hamza El Mahi","Johanny Rosario Ordonez","Luca Brida","Miguel Angel Vera","Rafael Valentini Taufer","Roberta Zorzi","Enrico Fanizzi","Vittorio Parnolfi"]

import random   

def scegli_vincitore(lista_partecipanti):
    return random.choice(lista_partecipanti)

if __name__ == "__main__":
    vincitore = scegli_vincitore(fortunati_vincitori)
    print(f"Il vincitore è {vincitore}")