FROM alpine:3.6

ENV ODOO_URL=""
ENV PGADMIN_URL=""

# Install python and pip
RUN apk add --no-cache --update python3 py3-pip bash && \
        # Install dependencies
        pip3 install Flask && \
        # Add a Group and user icwebapp
        addgroup -S icwebapp && \
        adduser -S icwebapp -G icwebapp

# Add our code
COPY --chown=icwebapp:icwebapp ic-webapp /opt/ic-webapp/
COPY --chown=icwebapp:icwebapp releases.txt /opt/ic-webapp/releases.txt

USER icwebapp
# Create the entry point script
RUN echo -e "#!/bin/bash\nexport ODOO_URL=$(cat /opt/ic-webapp/releases.txt | grep ODOO_URL |sed -e 's/^ODOO_URL: \(.*\)$/\1/') && export PGADMIN_URL=$(cat /opt/ic-webapp/releases.txt | grep PGADMIN_URL |sed -e 's/^PGADMIN_URL: \(.*\)$/\1/') && python3 app.py" > /opt/ic-webapp/start.sh \
    && chmod +x /opt/ic-webapp/start.sh


WORKDIR /opt/ic-webapp
EXPOSE 8080

ENTRYPOINT [ "./start.sh" ]
