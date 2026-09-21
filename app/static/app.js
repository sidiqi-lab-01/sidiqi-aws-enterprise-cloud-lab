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


const architectureDomains = {
  networking: {
    title: "Networking",
    description:
      "A segmented AWS network provides controlled ingress, private application placement, outbound access, and load-balanced delivery.",
    services: [
      "Amazon VPC",
      "Public Subnets",
      "Private Subnets",
      "Internet Gateway",
      "NAT Gateway",
      "Route Tables",
      "Security Groups",
      "Application Load Balancer",
      "Route 53"
    ],
    responsibility:
      "Routes client traffic into the environment while keeping application workloads inside private subnets.",
    value:
      "Demonstrates subnet segmentation, controlled traffic flow, high availability, DNS, and load-balanced application delivery."
  },

  security: {
    title: "IAM & Security",
    description:
      "Identity, encryption, network controls, TLS, metadata protection, and audit visibility are integrated throughout the platform.",
    services: [
      "AWS IAM",
      "IAM Roles",
      "Instance Profiles",
      "IMDSv2",
      "Security Groups",
      "AWS Certificate Manager",
      "Encrypted EBS",
      "VPC Flow Logs"
    ],
    responsibility:
      "Controls workload permissions, protects credentials and metadata, encrypts traffic and storage, and records network activity.",
    value:
      "Applies least privilege and layered security controls instead of treating security as a separate deployment phase."
  },

  compute: {
    title: "Compute",
    description:
      "Application capacity is delivered through reusable EC2 launch templates and an Auto Scaling Group spanning private subnets.",
    services: [
      "Amazon EC2",
      "Launch Templates",
      "Auto Scaling Groups",
      "Target Groups",
      "Rolling Instance Refresh"
    ],
    responsibility:
      "Provides repeatable application hosts and replaces instances during versioned application deployments.",
    value:
      "Demonstrates immutable-style releases, horizontal capacity management, and automated rolling replacement."
  },

  storage: {
    title: "Storage",
    description:
      "The environment uses multiple AWS storage services for object, block, and shared file storage requirements.",
    services: [
      "Amazon S3",
      "Amazon EBS",
      "Amazon EFS",
      "Encrypted Volumes",
      "Snapshots"
    ],
    responsibility:
      "Provides durable object storage, EC2 block storage, and shared filesystem capabilities.",
    value:
      "Shows how storage is selected according to workload access patterns rather than using a single storage technology."
  },

  database: {
    title: "Database",
    description:
      "Relational and key-value data services demonstrate managed database patterns for different application requirements.",
    services: [
      "Amazon RDS",
      "PostgreSQL",
      "Amazon DynamoDB",
      "Private DB Subnets",
      "Managed Credentials"
    ],
    responsibility:
      "Provides managed relational and application-state data services inside controlled network boundaries.",
    value:
      "Demonstrates choosing data platforms based on consistency, access pattern, operational overhead, and workload design."
  },

  containers: {
    title: "Containers",
    description:
      "The web application is packaged as a non-root Docker image and deployed from an immutable Amazon ECR digest.",
    services: [
      "Docker",
      "Amazon ECR",
      "Immutable Digests",
      "Non-root Runtime",
      "Container Healthcheck"
    ],
    responsibility:
      "Packages the application consistently from validation through production deployment.",
    value:
      "Reduces environment differences and makes application releases versioned, repeatable, and traceable."
  },

  devsecops: {
    title: "DevSecOps",
    description:
      "Source changes move through feature branches, pull requests, automated validation, container builds, and infrastructure-as-code.",
    services: [
      "Git",
      "GitHub",
      "GitHub Actions",
      "Pull Requests",
      "Terraform",
      "ShellCheck",
      "Container Validation"
    ],
    responsibility:
      "Validates software and infrastructure changes before they are merged and promoted.",
    value:
      "Creates an auditable engineering workflow where application and infrastructure changes are reviewed and reproducible."
  },

  operations: {
    title: "Operations",
    description:
      "Runtime health and deployment identity are exposed through application endpoints and the production operations dashboard.",
    services: [
      "/health",
      "/api/version",
      "/api/status",
      "Application Load Balancer",
      "Auto Scaling",
      "Deployment Metadata"
    ],
    responsibility:
      "Provides operators with health, version, environment, runtime, and architecture visibility.",
    value:
      "Supports rapid verification of what is running without presenting fabricated performance or monitoring metrics."
  }
};

function renderArchitectureDomain(domainName) {
  const domain = architectureDomains[domainName];

  if (!domain) {
    return;
  }

  const title = document.getElementById("architecture-title");
  const description =
    document.getElementById("architecture-description");
  const services =
    document.getElementById("architecture-services");
  const responsibility =
    document.getElementById("architecture-responsibility");
  const value =
    document.getElementById("architecture-value");

  if (!title || !description || !services ||
      !responsibility || !value) {
    return;
  }

  title.textContent = domain.title;
  description.textContent = domain.description;
  responsibility.textContent = domain.responsibility;
  value.textContent = domain.value;

  services.replaceChildren();

  domain.services.forEach((serviceName) => {
    const service = document.createElement("span");
    service.className = "architecture-service";
    service.textContent = serviceName;
    services.appendChild(service);
  });

  document
    .querySelectorAll(".architecture-tab")
    .forEach((tab) => {
      const active =
        tab.dataset.architecture === domainName;

      tab.classList.toggle("active", active);
      tab.setAttribute(
        "aria-pressed",
        active ? "true" : "false"
      );
    });
}

function initializeArchitectureExplorer() {
  const tabs =
    document.querySelectorAll(".architecture-tab");

  if (!tabs.length) {
    return;
  }

  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      renderArchitectureDomain(
        tab.dataset.architecture
      );
    });
  });

  renderArchitectureDomain("networking");
}

document.addEventListener(
  "DOMContentLoaded",
  initializeArchitectureExplorer
);
