import os
from pathlib import Path
from dotenv import load_dotenv
load_dotenv()

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/2.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'so*rai_2(lk7t(yh%de+_kp_c%*r_b9wkga%gyo5tl9_8_r!xx'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = ['127.0.0.1', '.vercel.app']

MEDIA_URL="/media/"
MEDIA_ROOT=os.path.join(BASE_DIR,"media")

# Static files (CSS, JavaScript, Images)
STATIC_URL = 'static/'
STATICFILES_DIRS = [os.path.join(BASE_DIR, "static")]
STATIC_ROOT = os.path.join(BASE_DIR, "staticfiles")

# Application definition

INSTALLED_APPS = [
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'property_management_app',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'plotihub.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': ['property_management_app/templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'plotihub.wsgi.app'


# Database
# https://docs.djangoproject.com/en/2.2/ref/settings/#databases

DATABASES = {
    'default': {
         'ENGINE': 'django.db.backends.sqlite3',
         'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
       
    }
}

#=====Enable Only Making Project Live on Vercel==== NOTE: THIS WILL MAKE CHANGES TO LIVE SERVER
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql_psycopg2',
#         'NAME': os.environ.get("DB_NAME"),
#         'USER': os.environ.get("DB_USER"),
#         'PASSWORD': os.environ.get("DB_PASSWORD"),
#         'HOST': os.environ.get("DB_HOST"),
#         'PORT': os.environ.get("DB_PORT"),
#     }
# }


# Password validation
# https://docs.djangoproject.com/en/2.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/2.2/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/2.2/howto/static-files/

STATIC_URL = '/property_management_app/static/'

AUTH_USER_MODEL="property_management_app.CustomUser"
AUTHENTICATION_BACKENDS = (
    'property_management_app.EmailBackEnd.EmailBackEnd',
    'django.contrib.auth.backends.ModelBackend',
)
EMAIL_BACKEND="django.core.mail.backends.filebased.EmailBackend"
# EMAIL_FILE_PATH=os.path.join(BASE_DIR,"sent_mails")
# EMAIL_HOST="smtp.gmail.com"
# EMAIl_PORT=587
# EMAIL_HOST_USER="GMAIL_EMAIL"
# EMAIL_HOST_PASSWORD="GMAIL PASSWORD"
# EMAIL_USE_TLS=True
# DEFAULT_FROM_EMAIL="tenant management System <GMAIl_EMAIL>"
#
