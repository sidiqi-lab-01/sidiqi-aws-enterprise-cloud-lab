FROM python:3.12-slim

LABEL org.opencontainers.image.title="Sidiqi AWS Enterprise Cloud Lab"
LABEL org.opencontainers.image.description="AWS infrastructure and DevSecOps demonstration platform"
LABEL org.opencontainers.image.source="https://github.com/sidiqi-lab-01/sidiqi-aws-enterprise-cloud-lab"

ARG APP_VERSION=development

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080 \
    APP_VERSION=${APP_VERSION}

WORKDIR /app

RUN groupadd --gid 10001 appgroup \
    && useradd \
       --uid 10001 \
       --gid appgroup \
       --no-create-home \
       --shell /usr/sbin/nologin \
       appuser

COPY --chown=appuser:appgroup server.py /app/server.py
COPY --chown=appuser:appgroup static/ /app/static/

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=2)" || exit 1

CMD ["python", "/app/server.py"]
