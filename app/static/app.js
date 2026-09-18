async function loadApplicationStatus() {
  const healthElement = document.getElementById("health");
  const versionElement = document.getElementById("version");

  try {
    const [healthResponse, versionResponse] = await Promise.all([
      fetch("/health"),
      fetch("/api/version")
    ]);

    if (!healthResponse.ok || !versionResponse.ok) {
      throw new Error("Application API unavailable");
    }

    const health = await healthResponse.json();
    const version = await versionResponse.json();

    healthElement.textContent =
      health.status === "healthy"
        ? "Application Healthy"
        : "Application Degraded";

    versionElement.textContent =
      `Version ${version.version}`;
  } catch (error) {
    healthElement.textContent = "Status Unavailable";
    versionElement.textContent = "Version unavailable";
  }
}

loadApplicationStatus();
