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
