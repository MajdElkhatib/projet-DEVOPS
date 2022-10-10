FROM alpine:3.6

ENV ODOO_URL=""
ENV PGADMIN_URL=""

# Install python, pip and module Flask
RUN apk add --no-cache --update python3 py3-pip bash \
    && pip3 install Flask

# Add our code
COPY ic-webapp /opt/ic-webapp/
COPY releases.txt /opt/ic-webapp/releases.txt
WORKDIR /opt/ic-webapp

EXPOSE 8080

CMD [ "bash -c", "ODOO_URL=$(cat releases.txt | grep ODOO_URL |awk -F\: '{print $2}'|xargs);PGADMIN_URL=$(cat releases.txt | grep PGADMIN_URL |awk -F\: '{print $2}' |xargs);python3 app.py" ]
