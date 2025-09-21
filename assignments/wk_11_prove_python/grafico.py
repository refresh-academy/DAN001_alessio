import matplotlib.pyplot as plt

players = ["Gigi", "Terry", "Alice", "Giuditta", "Enrico", "Roberta", "Johanny", "Alessandro", "Alessia", "Rafael", "Giorgio", "Dimitri"]
wpm = [72, 54, 44, 35, 44, 39, 32, 24, 32, 29, 20, 35]

media_wpm = sum(wpm) / len(wpm)
print("Media wpm:", media_wpm)

bars = plt.bar(players, wpm, label = "Parole al minuto")
plt.axhline(media_wpm, color="m", label='Media')
plt.xlabel("Giocatori")
plt.ylabel("Parole al minuto")
plt.legend()
plt.title("Prestazioni di digitazione dei giocatori")


# Aggiungi il valore sopra ogni barra
for bar, value in zip(bars, wpm):
    plt.text(bar.get_x() + bar.get_width()/2, value + 1, str(value), ha='center', va='bottom')

plt.show()