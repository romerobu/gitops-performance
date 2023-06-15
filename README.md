# GitOps performance tests



## Prepare app for testing

- Install yq and jq
- Oc login 
- Replace prometheus and server url
- Replace namespace for argo deployment and amount of pods
- Verify test user for argo exists and generate token for API testing
- Verify Argo deployment configuration is correct


## Prepare test plan

```bash
vim tests.txt
```

## Review data output format and metrics

## Run tests

```bash
sh run-test.sh
```