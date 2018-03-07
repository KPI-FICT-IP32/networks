## Prerequisites

Docker and docker-compose installation required

## Running

```
docker-compose up
```

## Testing

```
docker ps # to get test_host's container id

docker exec -ti <container id> /bin/bash
```

You will start bash process inside the container, that allows you to run dns diagnostics tools (`dig`, `nslookup`) within test host's container
