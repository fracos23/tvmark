// Risposte JSON finte, ridotte ai campi che usiamo, con la stessa forma
// delle risposte reali di TVmaze.

const searchChicagoFireJson = '''
[
  {
    "score": 0.91,
    "show": {
      "id": 1316,
      "name": "Chicago Fire",
      "status": "Running",
      "premiered": "2012-10-10",
      "updated": 1763000000,
      "network": {"id": 1, "name": "NBC"},
      "webChannel": null,
      "image": {"medium": "https://static.tvmaze.com/medium.jpg", "original": "https://static.tvmaze.com/original.jpg"}
    }
  },
  {
    "score": 0.5,
    "show": {
      "id": 99999,
      "name": "Serie streaming senza immagine",
      "status": "Ended",
      "premiered": null,
      "updated": 1700000000,
      "network": null,
      "webChannel": {"id": 1, "name": "Netflix"},
      "image": null
    }
  }
]
''';

const showWithEpisodesJson = '''
{
  "id": 1316,
  "name": "Chicago Fire",
  "status": "Running",
  "updated": 1763000000,
  "network": {"id": 1, "name": "NBC"},
  "webChannel": null,
  "image": {"medium": "https://static.tvmaze.com/medium.jpg"},
  "_embedded": {
    "episodes": [
      {"id": 100, "season": 1, "number": 1, "name": "Pilot", "airstamp": "2012-10-11T02:00:00+00:00", "runtime": 60},
      {"id": 101, "season": 14, "number": 8, "name": "Episodio futuro", "airstamp": "2026-12-04T02:00:00+00:00", "runtime": 60},
      {"id": 102, "season": 14, "number": 9, "name": "TBA", "airstamp": null, "runtime": null},
      {"id": 103, "season": 14, "number": null, "name": "Speciale", "airstamp": "", "runtime": 30},
      {"id": 104, "season": 14, "number": 10, "name": null, "airstamp": "2026-12-11T02:00:00+00:00", "runtime": 60}
    ]
  }
}
''';
