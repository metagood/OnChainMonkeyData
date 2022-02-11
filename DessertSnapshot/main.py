with open("test_dessert_map.csv", "r") as f:
    dessert_csv_lines = f.readlines()

desserts = [
    int(split[1]) for split in [
        csv_line.strip().split(',')
        for csv_line in dessert_csv_lines
    ]
]

OFFSET = 7775

offseted_desserts = desserts[OFFSET:] + (desserts[:OFFSET])

content = "\n".join([f"{i+1},{d}" for i, d in enumerate(offseted_desserts)])

with open("clarke.csv", "w") as f:
    f.write(content)