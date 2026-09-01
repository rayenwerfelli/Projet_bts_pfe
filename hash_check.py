import hashlib

codes = {
    1: "Illetre",
    2: "Primaire",
    3: "Enseignement de Base",
    4: "Enseignement Moyen",
    5: "Secondaire Long",
    6: "Secondaire Professionnel",
    7: "Enseignement Superieur",
    8: "Universitaire Cycle Non Accompli",
    99: "Autre Niveau",
}

for k, v in codes.items():
    h = hashlib.md5(str(k).encode()).hexdigest()
    print(f"{h} = {v}")