FROM wha/galaxy

MAINTAINER Cameron Smith

#required for bootstrapping the tool shed
RUN apt-get -qq update && apt-get install --no-install-recommends -y curl

ADD user_info.xml /galaxy-central/scripts/tool_shed/bootstrap_tool_shed/

ADD strap_empty_tool_shed.sh /galaxy-central/
RUN chmod +x /galaxy-central/strap_empty_tool_shed.sh

ADD toolshed.conf_snippet /tmp/
RUN cat /tmp/toolshed.conf_snippet >> /etc/supervisor/conf.d/galaxy.conf

ADD setup_basic_toolshed.py /galaxy-central/


RUN sed -i 's|#host = 0.0.0.0|host = 0.0.0.0|g' config/tool_shed.ini.sample
RUN sed -i 's|host = 127.0.0.1|#host = 127.0.0.1|g' config/tool_shed.ini.sample
RUN sed -i 's|^#admin_users.*$|admin_users = toolshed@galaxy.org|' config/tool_shed.ini.sample
RUN sed -i 's|^#database_connection|database_connection|g' config/tool_shed.ini.sample
RUN sed -i 's|^#file_path|file_path|g' config/tool_shed.ini.sample
RUN cp config/tool_shed.ini.sample config/tool_shed.ini

RUN cp config/tool_sheds_conf.xml.sample config/tool_sheds_conf.xml
RUN sed -i '/<tool_sheds>/ a\    <tool_shed name="Local Test Shed" url="http://localhost:9009/"/>' config/tool_sheds_conf.xml

RUN ./strap_empty_tool_shed.sh
EXPOSE :9009
CMD /usr/bin/startup



