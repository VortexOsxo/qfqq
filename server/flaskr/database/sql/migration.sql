-- qfqq-161 : Adding reports configs
CREATE TABLE IF NOT EXISTS
  reportsConfigs (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    encodedColumns TEXT NOT NULL,
    encodedFilters TEXT NOT NULL,
    showReviews BOOLEAN NOT NULL
  );