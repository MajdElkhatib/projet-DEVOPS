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

# Create the entry point script
RUN echo -e "#!/bin/bash\nexport ODOO_URL=$(cat releases.txt | grep ODOO_URL |sed -e 's/^ODOO_URL: \(.*\)$/\1/') && export PGADMIN_URL=$(cat releases.txt | grep PGADMIN_URL |sed -e 's/^PGADMIN_URL: \(.*\)$/\1/') && python3 app.py" > /opt/ic-webapp/start.sh \
    && chmod +x /opt/ic-webapp/start.sh

EXPOSE 8080

ENTRYPOINT [ "./start.sh" ]
