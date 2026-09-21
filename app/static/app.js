async function loadApplicationStatus() {
  const healthElement = document.getElementById("health");
  const versionElement = document.getElementById("version");
  const heroHealth = document.getElementById("hero-health");
  const heroVersion = document.getElementById("hero-version");
  const pulse = document.getElementById("operations-pulse");
  const refreshState = document.getElementById("operations-refresh-state");
  const refreshButton = document.getElementById("refresh-status");

  refreshButton.disabled = true;
  refreshState.textContent = "Refreshing live status...";

  try {
    const response = await fetch("/api/status", {
      cache: "no-store"
    });

    if (!response.ok) {
      throw new Error("Operations API unavailable");
    }

    const status = await response.json();
    const application = status.application;
    const deployment = status.deployment;
    const architecture = status.architecture;
    const healthy = application.status === "healthy";

    healthElement.textContent = healthy
      ? "Application Healthy"
      : "Application Degraded";

    versionElement.textContent = application.version;
    heroHealth.textContent = healthy ? "Healthy" : "Degraded";
    heroVersion.textContent = application.version;

    document.getElementById("operations-name").textContent =
      application.name;

    document.getElementById("operations-environment").textContent =
      deployment.environment;

    document.getElementById("operations-platform").textContent =
      deployment.platform;

    document.getElementById("operations-region").textContent =
      deployment.region;

    document.getElementById("operations-runtime").textContent =
      deployment.runtime;

    document.getElementById("operations-runtime-detail").textContent =
      deployment.runtime;

    document.getElementById("operations-dns").textContent =
      architecture.dns;

    document.getElementById("operations-tls").textContent =
      architecture.tls;

    document.getElementById("operations-alb").textContent =
      architecture.load_balancer;

    document.getElementById("operations-compute").textContent =
      architecture.compute;

    document.getElementById("operations-registry").textContent =
      architecture.container_registry;

    document.getElementById("operations-iac").textContent =
      architecture.infrastructure_as_code;

    pulse.classList.toggle("unavailable", !healthy);

    refreshState.textContent =
      `Live API · ${new Date().toLocaleTimeString()}`;
  } catch (error) {
    healthElement.textContent = "Status Unavailable";
    versionElement.textContent = "Unavailable";
    heroHealth.textContent = "Unavailable";
    heroVersion.textContent = "Unavailable";
    pulse.classList.add("unavailable");
    refreshState.textContent = "Operations API unavailable";
  } finally {
    refreshButton.disabled = false;
  }
}

function initializeStatusRefresh() {
  const refreshButton = document.getElementById("refresh-status");

  refreshButton.addEventListener("click", loadApplicationStatus);
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
initializeStatusRefresh();
initializePageSearch();
