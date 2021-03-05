# also include the Docker Compose file of the VSCode config to avoid warnings about orphaned services
dc = docker-compose -f docker-compose.yml -f .devcontainer/docker-compose.yml
user_id:=$(shell id -u)
group_id:=$(shell id -g)

build:
	docker build . -t battleship --build-arg USER_ID=$(user_id) --build-arg GROUP_ID=$(group_id)

setup-db:
	docker-compose run --rm battleship mix ecto.setup

run:
	$(dc) up -d battleship

logs:
	$(dc) logs -f

test:
	$(dc) run --rm battleship mix test

coveralls.html:
	$(dc) run --rm battleship mix coveralls.html

.PHONY: test coveralls.html logs run setup-db build
