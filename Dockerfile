FROM sachioksg/redmine:3.3
MAINTAINER sachioksg <s-kono@nri.co.jp>

RUN mkdir -m 755 /tmp/mysql
COPY setmysql.sh /tmp/mysql/
RUN chmod 755 /tmp/mysql/setmysql.sh
RUN /tmp/mysql/setmysql.sh

COPY database.yml /opt/redmine-3.3/config/

RUN cd /opt/redmine-3.3 && bundle install --without development test postgresql sqlite

RUN cd /opt/redmine-3.3 && bundle exec rake generate_secret_token
RUN /etc/init.d/mysql start && cd /opt/redmine-3.3 && RAILS_ENV=production rake db:migrate
RUN /etc/init.d/mysql start && cd /opt/redmine-3.3 && \
    RAILS_ENV=production REDMINE_LANG=ja rake redmine:load_default_data

CMD /etc/init.d/mysql start  && cd /opt/redmine-3.3 && ruby bin/rails server webrick --bind=0.0.0.0 -p 80 -e production
