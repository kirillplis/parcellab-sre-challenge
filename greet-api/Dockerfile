FROM python:3.12-slim
RUN pip install flask
COPY ./app.py ./app.py
ENV GREETING "Hello"
ENTRYPOINT ["python"]
CMD ["./app.py"]