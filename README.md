# CDTool

> [!NOTE]
> Simple CD tool for CS3604

## Dependencies

- go
- bash
- Optional: proxy server(nginx, caddy, etc...)
- And more depends on your CD project...

## Usage

Edit cdtools.service first.
```bash
# set the path to your own dir
Environment="CD_SCRIPT_PATH=/root/dev/gocd/cd.sh"
# set your port
Environment="PORT=30002"
# set CD_TOKEN="<YOUR_TOEKN>" in the following path
EnvironmentFile=-/etc/environment
```

Then simply run `bash deploy.sh` or `chmod +x deploy.sh && ./deploy.sh`

To use in github action, here is an example

```yaml
jobs:
  backend-test:
  frontend-test:
  MY-CD:
    runs-on: ubuntu-latest
    needs: [backend-test, frontend-test]
    steps:
    - name: Send CD notification
      run: |
        curl -X POST \
          -H "Authorization: Bearer ${{ secrets.CD_TOKEN }}" \
          "${{ secrets.CD_ENDPOINT }}"
```