export const API_BASE_URL = 'https://aws.sidiqilab.com';

export async function getHealth() {
  const response = await fetch(`${API_BASE_URL}/health`);

  if (!response.ok) {
    throw new Error(`Health API returned ${response.status}`);
  }

  return response.json();
}

export async function getVersion() {
  const response = await fetch(`${API_BASE_URL}/api/version`);

  if (!response.ok) {
    throw new Error(`Version API returned ${response.status}`);
  }

  return response.json();
}

export async function getStatus() {
  const response = await fetch(`${API_BASE_URL}/api/status`);

  if (!response.ok) {
    throw new Error(`Status API returned ${response.status}`);
  }

  return response.json();
}
