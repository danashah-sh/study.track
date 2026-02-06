-- Lag en tabell for brukere hvis den ikke finnes fra før
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,         -- Unik ID for hver bruker (teller automatisk opp)
    username TEXT UNIQUE NOT NULL, -- Brukernavn må være unikt og kan ikke være tomt
    password TEXT NOT NULL         -- Passord kan ikke være tomt
);

-- Lag en tabell for oppgaver hvis den ikke finnes fra før
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,         -- Unik ID for hver oppgave
    text TEXT NOT NULL,            -- Teksten i oppgaven kan ikke være tom
    completed BOOLEAN DEFAULT false, -- Om oppgaven er ferdig, standard er false
    user_id INTEGER REFERENCES users(id) -- Hvilken bruker som eier oppgaven
);
