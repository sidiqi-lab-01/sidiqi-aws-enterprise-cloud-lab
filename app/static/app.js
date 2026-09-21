async function loadApplicationStatus() {
  const healthElement = document.getElementById("health");
  const versionElement = document.getElementById("version");
  const heroHealth = document.getElementById("hero-health");
  const heroVersion = document.getElementById("hero-version");

  try {
    const [healthResponse, versionResponse] = await Promise.all([
      fetch("/health", { cache: "no-store" }),
      fetch("/api/version", { cache: "no-store" })
    ]);

    if (!healthResponse.ok || !versionResponse.ok) {
      throw new Error("Application API unavailable");
    }

    const health = await healthResponse.json();
    const version = await versionResponse.json();

    const healthy = health.status === "healthy";
    const healthText = healthy
      ? "Application Healthy"
      : "Application Degraded";

    healthElement.textContent = healthText;
    versionElement.textContent = version.version;

    heroHealth.textContent = healthy ? "Healthy" : "Degraded";
    heroVersion.textContent = version.version;
  } catch (error) {
    healthElement.textContent = "Status Unavailable";
    versionElement.textContent = "Unavailable";
    heroHealth.textContent = "Unavailable";
    heroVersion.textContent = "Unavailable";
  }
}


function initializePageSearch() {
  const toggle = document.getElementById("search-toggle");
  const panel = document.getElementById("search-panel");
  const input = document.getElementById("page-search");
  const close = document.getElementById("search-close");
  const results = document.getElementById("search-results");
  const count = document.getElementById("search-count");

  const searchableSections = [
    ...document.querySelectorAll("main section")
  ];

  function openSearch() {
    panel.hidden = false;
    toggle.setAttribute("aria-expanded", "true");
    input.focus();
  }

  function closeSearch() {
    panel.hidden = true;
    toggle.setAttribute("aria-expanded", "false");
    input.value = "";
    results.innerHTML = "";
    count.textContent = "";
  }

  function sectionTitle(section) {
    const heading = section.querySelector("h1, h2, h3");
    return heading
      ? heading.textContent.trim()
      : "AWS Enterprise Cloud Lab";
  }

  function searchPage() {
    const query = input.value.trim().toLowerCase();

    results.innerHTML = "";
    count.textContent = "";

    if (query.length < 2) {
      return;
    }

    const matches = searchableSections.filter((section) =>
      section.textContent.toLowerCase().includes(query)
    );

    count.textContent =
      `${matches.length} ${matches.length === 1 ? "section" : "sections"}`;

    if (matches.length === 0) {
      results.innerHTML =
        '<div class="search-empty">No matching content found.</div>';
      return;
    }

    matches.forEach((section) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "search-result";

      const title = sectionTitle(section);

      button.innerHTML =
        `<strong>${title}</strong>` +
        `<span>Contains "${input.value.trim()}"</span>`;

      button.addEventListener("click", () => {
        section.scrollIntoView({
          behavior: "smooth",
          block: "start"
        });

        section.classList.remove("search-target");
        void section.offsetWidth;
        section.classList.add("search-target");

        closeSearch();
      });

      results.appendChild(button);
    });
  }

  toggle.addEventListener("click", () => {
    if (panel.hidden) {
      openSearch();
    } else {
      closeSearch();
    }
  });

  close.addEventListener("click", closeSearch);
  input.addEventListener("input", searchPage);

  document.addEventListener("keydown", (event) => {
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      openSearch();
    }

    if (event.key === "Escape" && !panel.hidden) {
      closeSearch();
    }
  });
}


loadApplicationStatus();
initializePageSearch();
