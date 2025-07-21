FROM python:3.12.11

WORKDIR /code
RUN pip install --upgrade pip
RUN pip install setuptools
RUN pip install -U setuptools

RUN echo "Django==5.2.4" >> requirements.txt
RUN echo "uWSGI==2.0.30" >> requirements.txt
RUN echo "PyMySQL==1.1.0" >> requirements.txt
RUN pip install -r requirements.txt

RUN django-admin startproject djangohelloworldwithdb .
#WORKDIR /code

RUN sed -i "/^ALLOWED_HOSTS = \[\]/a ALLOWED_HOSTS = ['127.0.0.1', 'localhost', 'djangohelloworldwithdb.shahadathossain.com']" /code/djangohelloworldwithdb/settings.py
#RUN echo "ALLOWED_HOSTS = ['127.0.0.1', 'localhost', 'djangohelloworldwithdb.shahadathossain.com']" >> /djangohelloworldwithdb/settings.py

RUN echo "DATABASES = {'default': {'ENGINE': 'django.db.backends.mysql'," >> /code/djangohelloworldwithdb/settings.py
RUN echo "    'NAME': 'your_database_name'," >> /code/djangohelloworldwithdb/settings.py
RUN echo "    'USER': 'your_database_user'," >> /code/djangohelloworldwithdb/settings.py
RUN echo "    'PASSWORD': 'your_database_password'," >> /code/djangohelloworldwithdb/settings.py
RUN echo "    'HOST': 'localhost'," >> /code/djangohelloworldwithdb/settings.py
RUN echo "    'PORT': '3306'," >> /code/djangohelloworldwithdb/settings.py
RUN echo "    'OPTIONS': {'charset': 'utf8mb4', 'use_pure': True}," >> /code/djangohelloworldwithdb/settings.py
RUN echo "}}" >> /code/djangohelloworldwithdb/settings.py

RUN python manage.py startapp dbtestapp

RUN echo "from django.shortcuts import HttpResponse" > /code/dbtestapp/views.py
RUN echo "from django.db import connection" >> /code/dbtestapp/views.py
RUN echo "from django.db.utils import OperationalError" >> /code/dbtestapp/views.py
RUN echo "def home_page_view_hello_world(request):" >> /code/dbtestapp/views.py
RUN echo "    db_status = 'Unknown'" >> /code/dbtestapp/views.py
RUN echo "    db_error_message = None" >> /code/dbtestapp/views.py
RUN echo "    try:" >> /code/dbtestapp/views.py
RUN echo "        connection.ensure_connection()" >> /code/dbtestapp/views.py
RUN echo "        db_status = 'Connected'" >> /code/dbtestapp/views.py
RUN echo "    except OperationalError as e:" >> /code/dbtestapp/views.py
RUN echo "        db_status = 'Disconnected'" >> /code/dbtestapp/views.py
RUN echo "        db_error_message = str(e)" >> /code/dbtestapp/views.py
RUN echo "    return HttpResponse('Hello World. Database '+db_status+('' if db_error_message is None else ' ERR: '+db_error_message))" >> /code/dbtestapp/views.py

# Create urls.py for dbtestapp
RUN echo "from django.urls import path" > /code/dbtestapp/urls.py
RUN echo "from . import views" >> /code/dbtestapp/urls.py
RUN echo "urlpatterns = [path('', home_page_view_hello_world, name='helloworld'),]" >> /code/dbtestapp/urls.py

# Safely append to the project's urls.py
RUN sed -i "/from django.urls import path/a from django.urls import include" /code/djangohelloworldwithdb/urls.py
RUN sed -i "/urlpatterns = \[/a     path('', include('dbtestapp.urls'))," /code/djangohelloworldwithdb/urls.py

# Find the INSTALLED_APPS list and insert 'dbtestapp'
RUN sed -i "/'django.contrib.staticfiles',/a \ \ \ \ 'dbtestapp'," /code/djangohelloworldwithdb/settings.py

RUN adduser --disabled-password --no-create-home django
USER django

ENTRYPOINT ["uwsgi", "--http", ":9000", "--workers", "4", "--master", "--enable-threads", "--module", "djangohelloworldwithdb.wsgi"]

