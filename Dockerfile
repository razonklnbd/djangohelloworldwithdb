FROM python:3.12.11

WORKDIR /
RUN pip install --upgrade pip
RUN pip install setuptools
RUN pip install -U setuptools

RUN echo "Django==5.2.4" >> requirements.txt
RUN echo "uWSGI==2.0.30" >> requirements.txt
RUN echo "PyMySQL==1.1.0" >> requirements.txt
RUN pip install -r requirements.txt

RUN django-admin startproject djangohelloworldwithdb
WORKDIR /djangohelloworldwithdb


RUN echo "ALLOWED_HOSTS = ['127.0.0.1', 'localhost', 'djangohelloworldwithdb.shahadathossain.com']" >> /djangohelloworldwithdb/settings.py

RUN echo "DATABASES = {'default': {'ENGINE': 'django.db.backends.mysql'," >> /djangohelloworldwithdb/settings.py
RUN echo "    'NAME': 'your_database_name'," >> /djangohelloworldwithdb/settings.py
RUN echo "    'USER': 'your_database_user'," >> /djangohelloworldwithdb/settings.py
RUN echo "    'PASSWORD': 'your_database_password'," >> /djangohelloworldwithdb/settings.py
RUN echo "    'HOST': 'localhost'," >> /djangohelloworldwithdb/settings.py
RUN echo "    'PORT': '3306'," >> /djangohelloworldwithdb/settings.py
RUN echo "    'OPTIONS': {'charset': 'utf8mb4', 'use_pure': True}," >> /djangohelloworldwithdb/settings.py
RUN echo "}}" >> /djangohelloworldwithdb/settings.py


RUN echo "from django.urls import path" > /djangohelloworldwithdb/urls.py
RUN echo "from django.shortcuts import HttpResponse" >> /djangohelloworldwithdb/urls.py
RUN echo "from django.db import connection" >> /djangohelloworldwithdb/urls.py
RUN echo "from django.db.utils import OperationalError" >> /djangohelloworldwithdb/urls.py
RUN echo "def home_page_view_hello_world(request):" >> /djangohelloworldwithdb/urls.py
RUN echo "    db_status = 'Unknown'" >> /djangohelloworldwithdb/urls.py
RUN echo "    db_error_message = None" >> /djangohelloworldwithdb/urls.py
RUN echo "    try:" >> /djangohelloworldwithdb/urls.py
RUN echo "        connection.ensure_connection()" >> /djangohelloworldwithdb/urls.py
RUN echo "        db_status = 'Connected'" >> /djangohelloworldwithdb/urls.py
RUN echo "    except OperationalError as e:" >> /djangohelloworldwithdb/urls.py
RUN echo "        db_status = 'Disconnected'" >> /djangohelloworldwithdb/urls.py
RUN echo "        db_error_message = str(e)" >> /djangohelloworldwithdb/urls.py
RUN echo "    return HttpResponse('Hello World. Database '+db_status+('' if db_error_message is None else db_error_message))" >> /djangohelloworldwithdb/urls.py
RUN echo "urlpatterns = [path('', home_page_view_hello_world, name='helloworld'),]" >> /djangohelloworldwithdb/urls.py

RUN adduser --disabled-password --no-create-home django
USER django

ENTRYPOINT ["uwsgi", "--http", ":9000", "--workers", "4", "--master", "--enable-threads", "--module", "djangohelloworldwithdb.wsgi"]

