FROM python:3.11-slim-buster AS development_build

LABEL maintainer="AstralJaeger <astraljaeger@pm.me>"

ARG UID=1000
ARG GID=1000

ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PYTHONDONTWRITEBYTECODE=1 \
  # pip:
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  PIP_DEFAULT_TIMEOUT=100 \
  # tini:
  TINI_VERSION=v0.19.0 \
  # poetry:
  POETRY_VERSION=1.3.1 \
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  POETRY_CACHE_DIR='/var/cache/pypoetry' \
  POETRY_HOME='/usr/local'

RUN apt update && \
    apt upgrade -y && \
    apt install --no-install-recommends -y build-essential curl git && \
    curl -sSL 'https://install.python-poetry.org' | python - && \
    poetry config virtualenvs.create false && \
    apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt clean -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN groupadd -g "${GID}" -r app && \
    useradd -d '/app' -g app -l -r -u "${UID}" app && \
    chown app:app -R '/app' && \
    cd /app/

COPY --chown=app:app ./poetry.lock ./pyproject.toml ./main.py ./
#  --chown=app:app ./example/ ./

# Project initialization:
RUN --mount=type=cache,target="$POETRY_CACHE_DIR" \
    poetry run pip install -U pip && \
    poetry install --only main --no-interaction --no-ansi --no-root

# Running as non-root user:
USER app

ENTRYPOINT ["python3", "main.py"]

FROM development_build AS production_build
COPY --chown=app:app . /app
