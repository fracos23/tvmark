/// Stato di visione di un singolo episodio, deciso dall'utente.
enum WatchStatus {
  /// Default per ogni episodio appena scaricato.
  toWatch,

  /// Visto (con data di visione salvata a parte).
  watched,

  /// Non verrà guardato (recap, serie mollata...): esce dalle liste "da vedere".
  skipped,
}

/// Stato della serie lato TVmaze.
enum ShowStatus {
  running,
  ended,
  toBeDetermined,
  inDevelopment,
  unknown;

  /// Converte il campo "status" di TVmaze (es. "Running", "Ended").
  static ShowStatus fromTvmaze(String? value) => switch (value) {
        'Running' => running,
        'Ended' => ended,
        'To Be Determined' => toBeDetermined,
        'In Development' => inDevelopment,
        _ => unknown,
      };
}

/// Da quale API arriva una serie.
///
/// Gli id di TVmaze e TMDB sono numerazioni indipendenti e potrebbero
/// coincidere. Per non scontrarsi nella stessa colonna, le serie e gli
/// episodi TMDB sono salvati con id NEGATIVO (TMDB 226680 -> -226680).
enum ShowSource {
  tvmaze,
  tmdb;

  /// Fonte dedotta dall'id locale.
  static ShowSource ofLocalId(int localId) => localId < 0 ? tmdb : tvmaze;
}

/// Id TMDB -> id locale (negativo).
int tmdbToLocalId(int tmdbId) => -tmdbId;

/// Id locale (negativo) -> id TMDB.
int localToTmdbId(int localId) => -localId;

