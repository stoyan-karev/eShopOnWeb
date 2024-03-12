import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  // A number specifying the number of VUs to run concurrently.
  vus: 1000,
  // A string specifying the total duration of the test run.
  duration: '15m'
};

const BASE_URL = 'https://sk-app-api-dev.azurewebsites.net/api/';

// The function that defines VU logic.
//
// See https://grafana.com/docs/k6/latest/examples/get-started-with-k6/ to learn more
// about authoring k6 scripts.
//
export default function() {
  const response = http.get(`${BASE_URL}catalog-items`);
  check(response, { 'status was 200': (r) => r.status == 200 });
  sleep(1);
}
