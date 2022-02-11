with open("test_dessert_map.csv", "r") as f:
    dessert_csv_lines = f.readlines()

desserts = [
    int(split[1]) for split in [
        csv_line.strip().split(',')
        for csv_line in dessert_csv_lines
    ]
]

offset = 200

offseted_desserts = [
    desserts[i] for i in range(offset, len(desserts))
] + (desserts[:offset])

content = "\n".join([f"{i+1},{d}" for i, d in enumerate(offseted_desserts)])

with open("clarke.csv", "w") as f:
    f.write(content)