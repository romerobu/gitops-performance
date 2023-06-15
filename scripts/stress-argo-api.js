import http from 'k6/http';
import { sleep } from 'k6';
export const options = {
  
  vus: 10,
  duration: '1h',
  insecureSkipTLSVerify: true

};

export default function () {
  http.get('https://argocd-server-gitops-test.apps.cluster-j2d2t.j2d2t.sandbox545.opentlc.com/api/v1/projects');
  sleep(1);
  
  const params = {
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJ0ZXN0OmFwaUtleSIsIm5iZiI6MTY4NjczNDIyNCwiaWF0IjoxNjg2NzM0MjI0LCJqdGkiOiJlYzQ1ODg5Yi1mMTc1LTQ1MmItOGQ3ZS05MTI1YTUwYTEyYTAifQ.hYRNQN2EWrrguB0-4tJ86LUx6HSNMDwWnOQvYPt0Mfw',
    },
  };
}