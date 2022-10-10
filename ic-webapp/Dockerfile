FROM alpine:3.6

ENV ODOO_URL=""
ENV PGADMIN_URL=""

# Install python and pip
RUN apk add --no-cache --update python3 py3-pip bash

# Install dependencies
RUN pip3 install Flask

# Add our code
COPY ic-webapp /opt/ic-webapp/
WORKDIR /opt/ic-webapp

EXPOSE 8080

CMD [ "python3", "app.py" ]
