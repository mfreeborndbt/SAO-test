{% macro make_fresh_selector(allow_warnings=false, selector_name=None) %}
  {# Name defaults to env-specific to avoid collisions across jobs #}
  {% if selector_name is none %}
    {% set selector_name = "fresh_sources_" ~ (env_var("DBT_ENV_NAME", "default")) %}
  {% endif %}

  {# Read the freshness artifact from Step 1 #}
  {% set raw = load_file('target/sources.json') %}
  {% set data = fromjson(raw) %}

  {# Allowed statuses #}
  {% set ok = ['pass'] %}
  {% if allow_warnings %}{% do ok.append('warn') %}{% endif %}

  {# Collect fresh sources and include their children via '+' #}
  {% set ids = [] %}
  {% for r in data.get('results', []) %}
    {% if r.status in ok %}{% do ids.append(r.unique_id ~ '+') %}{% endif %}
  {% endfor %}

  {# Build a selectors.yml for *this run workspace only* #}
  {% set definition = (' '.join(ids)) if ids else 'fqn:__no_match__' %}
  {% set selectors_yaml = {'selectors': [{'name': selector_name, 'definition': definition}]} | toyaml %}
  {% do write_file('selectors.yml', selectors_yaml, true) %}

  {{ log("Selector '" ~ selector_name ~ "' written with " ~ (ids|length) ~ " fresh source(s).", info=true) }}
{% endmacro %}
