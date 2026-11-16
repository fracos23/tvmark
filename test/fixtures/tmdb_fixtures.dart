// Risposte JSON finte di TMDB, ridotte ai campi che usiamo.

const tmdbSearchJson = '''
{
  "page": 1,
  "results": [
    {
      "id": 226680,
      "name": "GialappaShow",
      "original_name": "GialappaShow",
      "first_air_date": "2023-05-09",
      "poster_path": "/gialappa.jpg",
      "origin_country": ["IT"]
    },
    {
      "id": 5,
      "name": "",
      "original_name": "Titolo originale",
      "first_air_date": "",
      "poster_path": null,
      "origin_country": []
    }
  ]
}
''';

/// Dettaglio serie con 4 stagioni (0 = speciali) e, quando richieste
/// con append_to_response, le stagioni 1-3. Lo stesso JSON va bene per
/// entrambe le chiamate: le chiavi "season/N" in più vengono ignorate
/// nella prima.
const tmdbShowJson = '''
{
  "id": 226680,
  "name": "GialappaShow",
  "status": "Returning Series",
  "poster_path": "/gialappa.jpg",
  "networks": [{"id": 1, "name": "TV8"}],
  "seasons": [
    {"season_number": 0},
    {"season_number": 1},
    {"season_number": 2},
    {"season_number": 3}
  ],
  "season/1": {"season_number": 1, "episodes": [
    {"id": 1001, "episode_number": 1, "season_number": 1, "name": "Prima puntata", "air_date": "2023-05-09", "runtime": 120}
  ]},
  "season/2": {"season_number": 2, "episodes": [
    {"id": 2001, "episode_number": 1, "season_number": 2, "name": "Puntata 1", "air_date": "2024-01-15", "runtime": 120},
    {"id": 2002, "episode_number": 2, "season_number": 2, "name": "", "air_date": "2024-01-22", "runtime": null}
  ]},
  "season/3": {"season_number": 3, "episodes": [
    {"id": 3001, "episode_number": 1, "season_number": 3, "name": "Annunciata", "air_date": null, "runtime": null}
  ]}
}
''';
