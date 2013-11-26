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

# Use some custom package repositories
{%- for name, repo in salt['pillar.get']('apt_client_repos', {}).iteritems() %}
{{ name }}:
  pkgrepo.managed:
    - name: {{ repo['line'] }}
    - file: {{ repo['file'] }}
{%- if 'keyid' in repo %}
    - keyid: {{ repo['keyid'] }}
    - keyserver: {{ repo['keyserver'] |default('keyserver.ubuntu.com') }}
{%- elif 'keyurl' in repo %}
    - key_url: {{ repo['keyurl'] }}
{%- endif %}
{%- endfor %}

