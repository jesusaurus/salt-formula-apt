# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
reprepro:
  pkg:
    - latest

{% set path = salt['pillar.get']('apt:repo:path', '/var/cache/apt') %}

{% for dir in [ 'conf', 'dists', 'pool' ] %}
{{ path }}/{{ dir }}:
  file.directory:
    - makedirs: True
{% endfor %}

{% if salt['pillar.get']('apt:repo:distros', false) %}
{{ path }}/conf/distributions:
  file.managed:
    - source: salt://apt/repo/distro
    - template: jinja
    - require:
      - file: {{ path }}/conf
{% endif %}

{{ path }}/conf/options:
  file.managed:
    - source: salt://apt/repo/options
    - template: jinja
    - require:
      - file: {{ path }}/conf

{% if salt['pillar.get']('apt:repo:pulls', false) %}
{{ path }}/conf/pulls:
  file.managed:
    - source: salt://apt/repo/pulls
    - template: jinja
    - require:
      - file: {{ path }}/conf
{% endif %}

{% if salt['pillar.get']('apt:repo:updates', false) %}
{{ path }}/conf/updates:
  file.managed:
    - source: salt://apt/repo/updates
    - template: jinja
    - require:
      - file: {{ path }}/conf

{% for update_name, update in salt['pillar.get']('apt:repo:updates').iteritems() %}

{% set key = update.get('verify', false) %}
{% if key != 'blindtrust' %}
{{ update_name }}_gpg_recv_{{ key }}:
  cmd.run:
    - name: gpg --recv-key {{ key }}
    - unless: gpg --list-key {{ key }}
{% endif %}

{% endfor %}

{% endif %}

'reprepro --silent --basedir {{ path }} update ; reprepro --silent --basedir {{ path }} pull ; reprepro --silent --basedir {{ path }} export':
  cron.present:
    - minute: 0
    - hour: 0

{% if salt['pillar.get']('apt:repo:filter', false) %}
{{ path }}/conf/filter.list:
  file.managed:
    - source: salt://apt/repo/filter.list
    - template: jinja
{% endif %}

