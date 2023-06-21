import http from 'k6/http';
import { sleep } from 'k6';
export const options = {
  
  vus: 10,
  duration: '1h',
  insecureSkipTLSVerify: true

};

export default function () {
  http.get('https://argocd-server-gitops-test.apps.cluster-nl29n.nl29n.sandbox1228.opentlc.com/api/v1/projects');
  sleep(1);
  
  const params = {
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJ0ZXN0OmFwaUtleSIsIm5iZiI6MTY4NzE3MDgyNSwiaWF0IjoxNjg3MTcwODI1LCJqdGkiOiI5MDQ1OTEyNS0wNzQ1LTQwOTMtOGMzNi1kZDM3NTUwZmY2MWQifQ.QwMWLCB1qIBJeJqapiHG7vllB9dA8GplE8NyyELX71g',
    },
  };
}