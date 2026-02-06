<!DOCTYPE html>
<html lang="no">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>StudyTrack | To-do-liste</title>
  <link rel="stylesheet" href="style.css" />
  <link rel="stylesheet" href="liste.css" />
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>

  <header>
    <h1>To-do-liste</h1>
    <p>Hold styr på alt du skal gjøre — skole, fritid og mål!</p>
    <nav>
      <a href="index.html" class="nav-btn">Hjem</a>
      <a href="kalender.html" class="nav-btn">Kalender</a>
    </nav>
  </header>

  <main class="todo-container">
    <section class="todo-box">
      <h2>Dine oppgaver</h2>

      <!-- Input for nye oppgaver -->
      <div class="input-group">
        <input type="text" id="task-input" placeholder="Skriv en oppgave..." />
        <button id="add-task">➕ Legg til</button>
      </div>

      <!-- Liste hvor oppgavene vises -->
      <ul id="task-list"></ul>

      <!-- Knapper for å slette alt eller logge ut -->
      <button id="clear-all" class="clear-btn">🗑 Slett alt</button>
      <button id="logout" class="clear-btn">⎋ Logg ut</button>
    </section>
  </main>

  <footer>
    <p>© 2025 StudyTrack | Laget av Dana Shahein</p>
  </footer>

  <script>
    // Hent HTML-elementene
    const taskInput = document.getElementById("task-input");
    const addTaskBtn = document.getElementById("add-task");
    const taskList = document.getElementById("task-list");
    const clearAllBtn = document.getElementById("clear-all");
    const logoutBtn = document.getElementById("logout");

    // Backend-endpoint
    const API_URL = "/tasks";

    // Lager headers med token hvis brukeren er logget inn
    function authHeaders() {
      const token = localStorage.getItem("token");
      return {
        "Content-Type": "application/json",
        "Authorization": token ? "Bearer " + token : ""
      };
    }

    // Hent oppgaver fra backend eller localStorage
    async function fetchTasks() {
      const token = localStorage.getItem("token");
      if (!token) {
        // Ikke logget inn → bruk localStorage
        loadFromStorage();
        return;
      }

      try {
        const res = await fetch(API_URL, { headers: authHeaders() });
        if (!res.ok) throw new Error("Feil ved henting");
        const tasks = await res.json();
        renderTasks(tasks);
      } catch (err) {
        // Backend utilgjengelig → fallback til localStorage
        console.log("Backend ikke tilgjengelig, bruker localStorage");
        loadFromStorage();
      }
    }

    // Tegn oppgaver i listen
    function renderTasks(tasks) {
      taskList.innerHTML = ""; // Fjern tidligere oppgaver
      tasks.forEach(task => {
        const li = document.createElement("li");
        li.className = task.completed ? "completed" : "";
        li.innerHTML = `
          <span>${task.text}</span>
          <div class="actions">
            <button class="done">✔</button>
            <button class="delete">❌</button>
          </div>
        `;

        // Marker oppgave som ferdig
        li.querySelector(".done").addEventListener("click", async () => {
          await updateTask(task.id, !task.completed);
          fetchTasks();
        });

        // Slett oppgave
        li.querySelector(".delete").addEventListener("click", async () => {
          await deleteTask(task.id);
          fetchTasks();
        });

        taskList.appendChild(li);
      });
    }

    // Legg til ny oppgave
    addTaskBtn.addEventListener("click", async () => {
      const text = taskInput.value.trim();
      if (!text) return; // Ikke tillat tom tekst

      const token = localStorage.getItem("token");
      if (!token) {
        // Ikke logget inn → lagre i localStorage
        const tasks = JSON.parse(localStorage.getItem("tasks") || "[]");
        tasks.push({ id: Date.now(), text, completed: false });
        localStorage.setItem("tasks", JSON.stringify(tasks));
        renderTasks(tasks);
        taskInput.value = "";
        return;
      }

      // Logget inn → send POST til backend
      await fetch(API_URL, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify({ text }),
      });
      taskInput.value = "";
      fetchTasks();
    });

    // Enter-tast legger til oppgave
    taskInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter") addTaskBtn.click();
    });

    // Slett alle oppgaver
    clearAllBtn.addEventListener("click", async () => {
      if (!confirm("Vil du slette alle oppgaver?")) return;

      const token = localStorage.getItem("token");
      if (!token) {
        localStorage.removeItem("tasks");
        renderTasks([]);
        return;
      }

      try {
        const res = await fetch(API_URL, { headers: authHeaders() });
        const tasks = await res.json();
        for (const task of tasks) {
          await deleteTask(task.id);
        }
        fetchTasks();
      } catch (err) {
        alert("Feil ved sletting: " + err.message);
      }
    });

    // Logg ut brukeren
    logoutBtn.addEventListener("click", () => {
      localStorage.removeItem("token");
      alert("Logget ut");
      fetchTasks();
    });

    // Oppdater oppgave (ferdig/ikke ferdig)
    async function updateTask(id, completed) {
      await fetch(`${API_URL}/${id}`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify({ completed }),
      });
    }

    // Slett enkelt oppgave
    async function deleteTask(id) {
      await fetch(`${API_URL}/${id}`, { method: "DELETE", headers: authHeaders() });
    }

    // Hent oppgaver fra localStorage hvis backend ikke kjører
    function loadFromStorage() {
      let tasks = JSON.parse(localStorage.getItem("tasks")) || [];
      renderTasks(tasks);
    }

    // Last inn oppgaver når siden lastes
    fetchTasks();
  </script>

</body>
</html>
