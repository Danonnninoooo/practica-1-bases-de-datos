FROM python:3.12-slim
WORKDIR /app
COPY web/requirements.txt /app/web/requirements.txt
RUN pip install --no-cache-dir -r /app/web/requirements.txt \
    && useradd --create-home --uid 10001 appuser
COPY index.html /app/index.html
COPY web/app.py /app/web/app.py
USER appuser
EXPOSE 8081
CMD ["gunicorn", "--bind", "0.0.0.0:8081", "--workers", "2", "web.app:app"]
