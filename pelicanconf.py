#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'borgle'
SITENAME = u'\u7f16\uff0c\u7f16\uff0c\u7f16\u82b1\u7bee'
SITEURL = ''


PATH = 'content'

TIMEZONE = 'Asia/Shanghai'

DEFAULT_LANG = u'zh'
DEFAULT_DATE_FORMAT = '%Y/%m/%d %H:%I'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (
        )

# Social widget
SOCIAL = (('github', 'https://github.com/borgle'), 
          ('google', 'https://google.com/yoker'), 
          ('weibo', '#'),)

DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

STATIC_PATHS = ['static','attachments']
DATE_FORMAT = {
    'en': ('en_US','%a, %d %b %Y'),
    'zh': ('zh_CN','%a, %Y-%m-%d %H:%I'),
}


SITETITLE = u"无题"
SITESUBTITLE = u'采用C#,Java,Python,PHP专注于Web后端开发'
SITEDESCRIPTION = u'%s\'s Thoughts and Writings' % AUTHOR
SITELOGO = SITEURL + '/static/logo.png'
FAVICON = SITEURL + '/static/favicon.ico'

ROBOTS = u'index, follow'

GITHUB_URL = "https://github.com/borgle"

THEME = "themes/"

OUTPUT_PATH = 'public/'
OUTPUT_RETENTION = ['.git','CNAME']

ARTICLE_PATHS = ['history','2016']
ARTICLE_SAVE_AS = 'posts/{date:%Y}/{date:%m}/{slug}.html'
ARTICLE_URL = 'posts/{date:%Y}/{date:%m}/{slug}.html'

